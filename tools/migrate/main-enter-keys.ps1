# main-enter-keys.ps1 : HE runs this once on the main PC, from the desktop shortcut "Pillagers keys" (main-dev-setup.ps1 makes it). Keys are per PC and do not
# travel. It asks for each key the VM had that this PC does not, hidden, through tools\ai-keys.ps1, which saves it as a Windows user variable. Claude never
# sees, reads or prints a key. Pressing Enter on an empty line skips one (ai-keys.ps1 saves nothing for an answer too short to be a key). ASCII only.
$Keys = 'C:\claudecode\dark raiders\tools\ai-keys.ps1'
$Want = [ordered]@{ console = @('PILLAGERS_API_KEY', 'your Anthropic Console key (console.anthropic.com, API keys)'); itch = @('BUTLER_API_KEY', 'your itch.io key (itch.io, Settings, API keys)') }
Write-Host ''
foreach ($s in $Want.Keys) {
  $name = $Want[$s][0]
  if ([Environment]::GetEnvironmentVariable($name, 'User')) { Write-Host ($s + ' key: already on this PC.') -ForegroundColor Green; continue }
  Write-Host ('Next: ' + $Want[$s][1]) -ForegroundColor Cyan
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Keys $s
}
Write-Host ''
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Keys | Select-Object -First 12
Read-Host 'Press Enter to close'
