#!/usr/bin/env pwsh
<#
.SYNOPSIS
Sync your forked repository with the upstream Microsoft repository
.DESCRIPTION
Fetches latest changes from upstream and merges them into your local main branch
.PARAMETER Stash
Automatically stash local changes before syncing
.PARAMETER Force
Force push to origin (use with caution)
.EXAMPLE
.\sync-repo.ps1
Fetches and merges upstream changes

.\sync-repo.ps1 -Stash
Stashes local changes, syncs, then applies them back

.\sync-repo.ps1 -Force
Force pushes changes to your fork
#>

param(
    [switch]$Stash = $false,
    [switch]$Force = $false
)

# Colors
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"

function Write-Status {
    param([string]$Message, [string]$Color = $ColorInfo)
    Write-Host $Message -ForegroundColor $Color
}

function Test-GitRepo {
    $gitFolder = git rev-parse --git-dir 2>$null
    return $LASTEXITCODE -eq 0
}

# Main script
Write-Status "==========================================" $ColorInfo
Write-Status "  Git Repository Sync Tool" $ColorInfo
Write-Status "==========================================" $ColorInfo
Write-Host ""

# Verify git repo
if (-not (Test-GitRepo)) {
    Write-Status "ERROR: Not in a git repository!" $ColorError
    exit 1
}

Write-Status "Repository: $(git rev-parse --show-toplevel)" $ColorInfo
Write-Host ""

# Check for local changes
Write-Status "Checking for local changes..." $ColorInfo
$localChanges = git status --porcelain
if ($localChanges) {
    Write-Host ""
    Write-Status "Local changes detected:" $ColorWarning
    Write-Host $localChanges
    Write-Host ""
    
    if (-not $Stash) {
        Write-Status "Use -Stash to automatically stash these changes" $ColorWarning
        $response = Read-Host "Continue? (y/n)"
        if ($response -ne "y") {
            Write-Status "Cancelled" $ColorInfo
            exit 0
        }
    }
}

# Stash changes if requested
if ($Stash -and $localChanges) {
    Write-Host ""
    Write-Status "Stashing changes..." $ColorWarning
    git stash
    Write-Status "Stashed" $ColorSuccess
    Write-Host ""
}

# Fetch from upstream
Write-Status "Fetching from upstream..." $ColorInfo
git fetch upstream
if ($LASTEXITCODE -ne 0) {
    Write-Status "ERROR: Fetch failed" $ColorError
    exit 1
}
Write-Status "Fetch successful" $ColorSuccess
Write-Host ""

# Show incoming changes
Write-Status "Comparing with upstream/main..." $ColorInfo
$incoming = git log HEAD..upstream/main --oneline
if ($incoming) {
    Write-Host $incoming
} else {
    Write-Status "Already up to date" $ColorSuccess
}
Write-Host ""

# Merge
Write-Status "Merging upstream/main..." $ColorInfo
git merge upstream/main
if ($LASTEXITCODE -ne 0) {
    Write-Status "ERROR: Merge failed. Resolve conflicts and commit." $ColorError
    exit 1
}
Write-Status "Merge successful" $ColorSuccess
Write-Host ""

# Push to origin
Write-Status "Pushing to origin..." $ColorInfo
if ($Force) {
    Write-Status "Force push enabled" $ColorWarning
    git push origin main -f
} else {
    git push origin main
}

if ($LASTEXITCODE -ne 0) {
    Write-Status "WARNING: Push may have failed or required authentication" $ColorWarning
} else {
    Write-Status "Push successful" $ColorSuccess
}
Write-Host ""

# Restore stashed changes
if ($Stash -and $localChanges) {
    Write-Status "Restoring stashed changes..." $ColorInfo
    git stash pop
    if ($LASTEXITCODE -ne 0) {
        Write-Status "WARNING: Stash had conflicts - resolve manually" $ColorWarning
    } else {
        Write-Status "Stash restored" $ColorSuccess
    }
    Write-Host ""
}

# Final status
Write-Status "==========================================" $ColorInfo
Write-Status "  SYNC COMPLETE" $ColorSuccess
Write-Status "==========================================" $ColorInfo
