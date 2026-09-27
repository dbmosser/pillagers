# Run on Daniel's PC to take the PILLAGERS work over from the cloud session:
#   powershell -ExecutionPolicy Bypass -File C:\claudecode\dark\tools\handoff\pc-takeover.ps1
# Pulls the latest build, checks the tools the ship flow needs, puts the opening message on the clipboard, and starts a
# Claude Code session on this PC that also shows up in the Claude app (Remote Control).
param([string]$Repo = 'C:\claudecode\dark')
$ErrorActionPreference = 'Stop'
if (-not (Test-Path (Join-Path $Repo 'dark_raiders.html'))) { Write-Host "Game folder not found at $Repo. Run again with -Repo <your folder>."; exit 1 }
Set-Location $Repo
Write-Host '1. Pulling the latest build...'
git pull origin master
if ($LASTEXITCODE -ne 0) { Write-Host 'git pull failed. Fix that first (local changes? run: git status).'; exit 1 }
$ver = (Select-String -Path dark_raiders.html -Pattern "var VER='([0-9.]+)'").Matches[0].Groups[1].Value
Write-Host "   Game is at v$ver ($(git rev-parse --short HEAD))."
Write-Host '2. Checking tools...'
foreach ($t in 'git','node','python','claude') {
  if (Get-Command $t -ErrorAction SilentlyContinue) { Write-Host "   $t ok" } else { Write-Host "   $t MISSING" }
}
$msg = 'Read tools/handoff/PC-HANDOFF.md and then tools/handoff/CLOUD-BRIEF.md in full. You are taking over PILLAGERS on this PC from the cloud session at v' + $ver + '. Keep working the queue in PC-HANDOFF.md, starting with the 4K frame rate measurement on this GPU. My budget rule applies: 10 percent of the weekly allocation per 24 hours, which means use tokens efficiently and never slow down or stop making progress. Push after every ship and give me a play link.'
Set-Clipboard -Value $msg
Write-Host '3. The opening message is on your clipboard. Paste it as the first message once the session starts.'
Write-Host '4. Starting Claude Code with Remote Control (it will also appear in the Claude app)...'
claude remote-control
