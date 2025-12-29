# Git Sync Guide - Keep Your Fork Updated

## Quick Reference

### One-Time Setup (Already Done ✅)
```powershell
# Add the upstream remote to track the official repository
git remote add upstream https://github.com/microsoft/TechWorkshop-L300-AI-Apps-and-agents.git

# Verify setup
git remote -v
```

### Regular Workflow - Get Latest Code

#### Option 1: Fetch → Merge (Recommended)
```powershell
# Step 1: Fetch latest from upstream (doesn't modify your code)
git fetch upstream

# Step 2: Merge upstream/main into your main branch
git merge upstream/main

# Step 3: Push to your fork
git push origin main
```

#### Option 2: Pull (Combine fetch + merge)
```powershell
# One command that does fetch + merge
git pull upstream main

# Push to your fork
git push origin main
```

#### Option 3: Rebase (Cleaner history)
```powershell
# Rebase your changes on top of upstream
git fetch upstream
git rebase upstream/main
git push origin main -f
```

### When You Have Uncommitted Changes

If you have local changes you want to keep:

```powershell
# Stash your changes (save them temporarily)
git stash

# Fetch and merge from upstream
git fetch upstream
git merge upstream/main

# Apply your changes back
git stash pop
```

Or if you want to commit your changes first:

```powershell
# Commit your local changes
git add .
git commit -m "Your commit message"

# Then fetch and merge
git fetch upstream
git merge upstream/main

# Push everything
git push origin main
```

## Current Status

Your repository structure:
- **origin**: Your forked repository (gethiten/TechWorkshop-L300-AI-Apps-and-agents)
- **upstream**: Official Microsoft repository (microsoft/TechWorkshop-L300-AI-Apps-and-agents)

## Check What Changed

```powershell
# See what's different between your code and upstream
git diff upstream/main

# See commits you have that upstream doesn't
git log upstream/main..HEAD --oneline

# See commits upstream has that you don't
git log HEAD..upstream/main --oneline
```

## Common Scenarios

### Scenario 1: You have uncommitted changes
```powershell
git stash
git fetch upstream
git merge upstream/main
git stash pop
```

### Scenario 2: You have commits not in upstream yet
```powershell
git fetch upstream
git merge upstream/main
git push origin main
```

### Scenario 3: Want to see what would change
```powershell
git fetch upstream
git diff upstream/main
```

### Scenario 4: Want to reset to upstream version
```powershell
git fetch upstream
git reset --hard upstream/main
```

## Automate with PowerShell Script

Create `sync-repo.ps1`:

```powershell
param(
    [switch]$Force = $false,
    [switch]$Stash = $false
)

Write-Host "Syncing with upstream..." -ForegroundColor Cyan

if ($Stash) {
    Write-Host "Stashing local changes..." -ForegroundColor Yellow
    git stash
}

Write-Host "Fetching from upstream..." -ForegroundColor Cyan
git fetch upstream

Write-Host "Merging upstream/main..." -ForegroundColor Cyan
git merge upstream/main

if ($Force) {
    Write-Host "Pushing to origin (forced)..." -ForegroundColor Yellow
    git push origin main -f
} else {
    Write-Host "Pushing to origin..." -ForegroundColor Cyan
    git push origin main
}

if ($Stash) {
    Write-Host "Applying stashed changes..." -ForegroundColor Yellow
    git stash pop
}

Write-Host "✅ Sync complete!" -ForegroundColor Green
```

Usage:
```powershell
.\sync-repo.ps1              # Normal sync
.\sync-repo.ps1 -Stash       # Stash local changes first
.\sync-repo.ps1 -Force       # Force push
```
