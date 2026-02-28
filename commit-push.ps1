# Commit and push changes to git repository
# Usage: .\commit-push.ps1 "your commit message"

param(
    [Parameter(Mandatory=$true)]
    [string]$Message
)

# Add all changes
git add .

# Commit with message
git commit -m $Message

# Push to remote
git push

Write-Host "✓ Changes committed and pushed successfully" -ForegroundColor Green
