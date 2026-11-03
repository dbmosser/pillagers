# main-helper-signin.ps1 : HE runs this once on the main PC, from the desktop shortcut "Pillagers helper sign-in" (main-dev-setup.ps1 makes it). It signs the
# Pillagers helpers in to his personal Claude account in their own folder, %USERPROFILE%\.claude-pillagers. CLAUDE_CONFIG_DIR is set for this window only, never
# user-wide, so his terminal Claude stays on his work account. It compares a hash of the signed-in address with PLAN_ACCOUNT_SHA in caps.txt (the same
# check tools/console-lane.sh does) and prints only yes or no, never the address. Claude never sees the sign-in. ASCII only.
$Repo = 'C:\claudecode\dark raiders'
$env:CLAUDE_CONFIG_DIR = (Join-Path $env:USERPROFILE '.claude-pillagers')
New-Item -ItemType Directory -Force -Path $env:CLAUDE_CONFIG_DIR | Out-Null
Remove-Item Env:\ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
function Test-Account {
  $want = ''
  try { $want = ((Select-String -LiteralPath ($Repo + '\tools\handoff\console\caps.txt') -Pattern '^PLAN_ACCOUNT_SHA=(.*)$' | Select-Object -First 1).Matches[0].Groups[1].Value).Trim() } catch { }
  $em = ''
  try { $em = [string]((& claude auth status 2>$null | Out-String) | ConvertFrom-Json).email } catch { }
  if (-not $em) { return 'none' }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = (($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($em.ToLowerInvariant())) | ForEach-Object { $_.ToString('x2') }) -join '') } finally { $sha.Dispose() }
  if ($h -eq $want) { return 'right' } else { return 'wrong' }
}
Write-Host ''
# 11-02 night: his default browser, Edge, is signed in to his work account, so twice this landed on the wrong one without a choice. Chrome holds his personal profile, so the page opens there.
$chrome = @((Join-Path $env:ProgramFiles 'Google/Chrome/Application/chrome.exe'), (Join-Path ${env:ProgramFiles(x86)} 'Google/Chrome/Application/chrome.exe'), (Join-Path $env:LOCALAPPDATA 'Google/Chrome/Application/chrome.exe')) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if ($chrome) { $env:BROWSER = $chrome; Write-Host 'The page opens in Chrome, where your personal account is.' -ForegroundColor Cyan }
Write-Host 'Choose your PERSONAL Claude account (the Gmail one) and approve. If it shows your work account, switch accounts on the page first.' -ForegroundColor Cyan
Write-Host 'Your work login on this PC is not touched.' -ForegroundColor Cyan
Write-Host ''
& claude auth login
Write-Host ''
switch (Test-Account) {
  'right' { Write-Host 'All set: the helpers are signed in to the right account. You can close this window.' -ForegroundColor Green }
  'wrong' { Write-Host 'That was a different account, so the helpers will stay off. Close this and double-click the shortcut again, and pick your personal account.' -ForegroundColor Yellow }
  default { Write-Host 'The sign-in did not finish. Close this and double-click the shortcut again.' -ForegroundColor Yellow }
}
Write-Host ''
Read-Host 'Press Enter to close'
