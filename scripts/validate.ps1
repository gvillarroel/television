$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$env:TELEVISION_CONFIG = $repoRoot
$tvArgs = @("--config-file", "$repoRoot\config.toml", "--cable-dir", "$repoRoot\cable")

Write-Host "Usando TELEVISION_CONFIG=$repoRoot"
Write-Host ""

function Assert-True {
  param(
    [bool]$Condition,
    [string]$Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

function Run-Tv {
  param(
    [string[]]$Arguments
  )

  & tv @tvArgs @Arguments
}

function Test-ReposSelection {
  param(
    [string]$Query
  )

  $cutoff = (Get-Date).AddMonths(-6)
  $fromIso = $cutoff.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  $cutoffDate = $cutoff.ToString("yyyy-MM-dd")
  $login = gh api user --jq .login
  $rows = @()

  $contribQuery = 'query($from: DateTime!) { viewer { contributionsCollection(from: $from) { commitContributionsByRepository(maxRepositories: 100) { repository { nameWithOwner } contributions(first: 100) { nodes { occurredAt } } } pullRequestContributionsByRepository(maxRepositories: 100) { repository { nameWithOwner } contributions(first: 100) { nodes { occurredAt } } } pullRequestReviewContributionsByRepository(maxRepositories: 100) { repository { nameWithOwner } contributions(first: 100) { nodes { occurredAt } } } } } }'
  $contribRows = gh api graphql -F from="$fromIso" -f query="$contribQuery" --jq '[(.data.viewer.contributionsCollection.commitContributionsByRepository[] | select((.contributions.nodes | length) > 0) | [.repository.nameWithOwner, (.contributions.nodes | map(.occurredAt) | max)] | @tsv), (.data.viewer.contributionsCollection.pullRequestContributionsByRepository[] | select((.contributions.nodes | length) > 0) | [.repository.nameWithOwner, (.contributions.nodes | map(.occurredAt) | max)] | @tsv), (.data.viewer.contributionsCollection.pullRequestReviewContributionsByRepository[] | select((.contributions.nodes | length) > 0) | [.repository.nameWithOwner, (.contributions.nodes | map(.occurredAt) | max)] | @tsv)][]'
  if ($contribRows) {
    $rows += ($contribRows -split "`r?`n" | Where-Object { $_ })
  }

  $starQuery = 'query($endCursor: String) { viewer { starredRepositories(first: 100, after: $endCursor, orderBy: { field: STARRED_AT, direction: DESC }) { edges { starredAt node { nameWithOwner } } pageInfo { hasNextPage endCursor } } } }'
  $starRows = gh api graphql --paginate -f query="$starQuery" --jq '.data.viewer.starredRepositories.edges[] | [.node.nameWithOwner, .starredAt] | @tsv'
  if ($starRows) {
    $rows += (($starRows -split "`r?`n" | Where-Object { $_ -and ([datetimeoffset](($_ -split "`t", 2)[1])) -ge $cutoff.ToUniversalTime() }))
  }

  $prRows = gh search prs --commenter "$login" --updated ">=$cutoffDate" --limit 1000 --json repository,updatedAt --jq '.[] | [.repository.nameWithOwner, .updatedAt] | @tsv' 2>$null
  if ($prRows) {
    $rows += ($prRows -split "`r?`n" | Where-Object { $_ })
  }

  $selection = $rows |
    ForEach-Object {
      $parts = $_ -split "`t", 2
      if ($parts.Length -eq 2) {
        [pscustomobject]@{
          Repo = $parts[0]
          At = [datetimeoffset]$parts[1]
        }
      }
    } |
    Group-Object Repo |
    ForEach-Object {
      $latest = $_.Group | Sort-Object At -Descending | Select-Object -First 1
      "{0:yyyy-MM-dd} - {1}`t{1}" -f $latest.At.LocalDateTime, $latest.Repo
    } |
    Sort-Object -Descending |
    Select-String -Pattern $Query |
    Select-Object -First 1 |
    ForEach-Object { $_.Line }

  Assert-True (-not [string]::IsNullOrWhiteSpace($selection)) "repos did not return a selection for query '$Query'"
  return $selection.Trim()
}

function Test-ChannelSelection {
  param(
    [string]$Channel,
    [string]$Repo,
    [string]$Query
  )

  $previousRepo = $env:TV_REPO
  try {
    $env:TV_REPO = $Repo
    switch ($Channel) {
      "repo-issues" {
        $rows = @(gh issue list --repo $env:TV_REPO --state open --limit 200 --json number,title,author,updatedAt,url --jq '.[] | [.number, .title, (.author.login // "unknown"), .updatedAt, .url] | @tsv')
        if ($Query) {
          $selection = $rows | Select-String -Pattern $Query | Select-Object -First 1 | ForEach-Object { $_.Line }
        } else {
          $selection = $rows | Select-Object -First 1
        }
        if (-not $selection) {
          $selection = "0`tNo open issues`t-`t-`thttps://github.com/$env:TV_REPO/issues"
        }
      }
      "repo-prs" {
        $rows = @(gh pr list --repo $env:TV_REPO --state open --limit 200 --json number,title,author,updatedAt,url --jq '.[] | [.number, .title, (.author.login // "unknown"), .updatedAt, .url] | @tsv')
        if ($Query) {
          $selection = $rows | Select-String -Pattern $Query | Select-Object -First 1 | ForEach-Object { $_.Line }
        } else {
          $selection = $rows | Select-Object -First 1
        }
        if (-not $selection) {
          $selection = "0`tNo open pull requests`t-`t-`thttps://github.com/$env:TV_REPO/pulls"
        }
      }
      "repo-discussions" {
        $parts = $env:TV_REPO -split "/", 2
        $discussionQuery = @"
query {
  repository(owner: "$($parts[0])", name: "$($parts[1])") {
    discussions(first: 100, orderBy: {field: UPDATED_AT, direction: DESC}) {
      nodes {
        number
        title
        updatedAt
        url
        author { login }
        category { name }
      }
    }
  }
}
"@
        $rows = @(gh api graphql -f query="$discussionQuery" --jq '.data.repository.discussions.nodes[] | [.number, .title, (.category.name // "Discussion"), (.author.login // "unknown"), .updatedAt, .url] | @tsv')
        if ($Query) {
          $selection = $rows | Select-String -Pattern $Query | Select-Object -First 1 | ForEach-Object { $_.Line }
        } else {
          $selection = $rows | Select-Object -First 1
        }
        if (-not $selection) {
          $selection = "0`tNo discussions`tDiscussion`t-`t-`thttps://github.com/$env:TV_REPO/discussions"
        }
      }
      default {
        throw "Unsupported channel '$Channel'"
      }
    }
    Assert-True (-not [string]::IsNullOrWhiteSpace($selection)) "$Channel did not return a selection for repo '$Repo'"
    return $selection.Trim()
  } finally {
    $env:TV_REPO = $previousRepo
  }
}

function Test-GitReposSource {
  $rows = @(fd -g .git -HL -t d -d 10 --prune 'C:\Users' | ForEach-Object { Split-Path -Parent $_ })
  Assert-True ($rows.Count -gt 0) "git-repos source did not return any repositories"
  Assert-True ([bool]($rows | Where-Object { $_ -eq $repoRoot })) "git-repos source did not include the current repository"
}

function Test-GithubReposSource {
  $owner = gh api user --jq .login
  $rows = @(
    gh repo list $owner --limit 100 --json nameWithOwner,description,updatedAt,isPrivate --jq '.[] | [.nameWithOwner, (if ((.description // "") | length) > 0 then .description else "No description" end), (.updatedAt // ""), (if .isPrivate then "private" else "public" end)] | @tsv'
  )
  Assert-True ($rows.Count -gt 0) "github-repos source did not return any repositories"
  Assert-True ([bool]($rows | Where-Object { $_ -match "^$owner/" })) "github-repos source did not include repositories for '$owner'"
}

Write-Host "Validando carga de canales..."
$channels = (Run-Tv @("list-channels")) -join "`n"
Assert-True ([bool]($channels -match "(?m)^git-repos$")) "git-repos channel is missing"
Assert-True ([bool]($channels -match "(?m)^github-repos$")) "github-repos channel is missing"
Assert-True ([bool]($channels -match "(?m)^repos$")) "repos channel is missing"
Assert-True ([bool]($channels -match "(?m)^repo-issues$")) "repo-issues channel is missing"
Assert-True ([bool]($channels -match "(?m)^repo-prs$")) "repo-prs channel is missing"
Assert-True ([bool]($channels -match "(?m)^repo-discussions$")) "repo-discussions channel is missing"

Write-Host "Validando variantes de repositorios..."
Test-GitReposSource
Test-GithubReposSource

Write-Host "Validando flujo repos -> issues..."
$md2confSelection = Test-ReposSelection "md2conf"
Assert-True ($md2confSelection -match "hunyadi/md2conf") "repos did not resolve md2conf to hunyadi/md2conf"
$md2confIssue = Test-ChannelSelection "repo-issues" "hunyadi/md2conf" "250"
Assert-True ($md2confIssue -match "https://github.com/hunyadi/md2conf/issues/250") "repo-issues did not resolve md2conf issue 250"

Write-Host "Validando flujo repos -> PRs..."
$cliPr = Test-ChannelSelection "repo-prs" "cli/cli" "12990"
Assert-True ($cliPr -match "https://github.com/cli/cli/pull/12990") "repo-prs did not resolve cli/cli PR 12990"

Write-Host "Validando flujo repos -> discussions..."
$cliDiscussion = Test-ChannelSelection "repo-discussions" "cli/cli" "9796"
Assert-True ($cliDiscussion -match "https://github.com/cli/cli/discussions/9796") "repo-discussions did not resolve cli/cli discussion 9796"

Write-Host "Validando fallbacks vacios..."
$emptyIssue = Test-ChannelSelection "repo-issues" "gvillarroel/pi-extensions" ""
Assert-True ($emptyIssue -match "https://github.com/gvillarroel/pi-extensions/issues") "repo-issues fallback URL is incorrect"
$emptyDiscussion = Test-ChannelSelection "repo-discussions" "gvillarroel/pi-extensions" ""
Assert-True ($emptyDiscussion -match "https://github.com/gvillarroel/pi-extensions/discussions") "repo-discussions fallback URL is incorrect"

Write-Host ""
Write-Host "Validacion completada."
