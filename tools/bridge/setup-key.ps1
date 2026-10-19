# setup-key.ps1 : makes or shows the ONE shared key the host bridge uses. Run it in a NORMAL PowerShell window (no administrator).
#
# The main PC's bridge agent and the VM's hostctl both read the same 32-byte key from a file OUTSIDE the repository
# (C:\Users\<you>\AppData\Local\PillagersBridge\key.txt). Make it once on the main PC, then copy that one line into the VM.
#
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\setup-key.ps1"          make the key if there is none, then show where it is
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\setup-key.ps1" -Show     print the key so you can copy it into the VM
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\setup-key.ps1" -Set VALUE set the key to VALUE (64 hex characters) - use this INSIDE THE VM to paste the key the main PC made
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\setup-key.ps1" -New      make a fresh key even if one exists (both machines must then get the new one)
#
# The key is a password for the bridge. Treat it like one: it is never put in the repository and never printed unless you ask with -Show.
# ASCII only. Windows PowerShell 5.1 and PowerShell 7.
param(
  [switch]$Show,
  [switch]$New,
  [string]$Set
)
$ErrorActionPreference = 'Stop'
$dir = Join-Path $env:LOCALAPPDATA 'PillagersBridge'
$keyFile = Join-Path $dir 'key.txt'
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

function Save([string]$k) {
  Set-Content -LiteralPath $keyFile -Value $k -Encoding Ascii -NoNewline
  Add-Content -LiteralPath $keyFile -Value "`n" -Encoding Ascii
}

if ($Set) {
  $v = ($Set -replace '[^0-9a-fA-F]', '').ToLower()
  if ($v.Length -ne 64) { Write-Host ('That is not a valid key. It must be 64 hex characters (you gave ' + $v.Length + '). Run -Show on the main PC and copy the whole line.') -ForegroundColor Red; exit 1 }
  Save $v
  Write-Host ('Key set from what you pasted. Saved to ' + $keyFile) -ForegroundColor Green
  exit 0
}

$have = $false
try { $cur = (Get-Content -LiteralPath $keyFile -Raw).Trim(); if ($cur -match '^[0-9a-fA-F]{64}$') { $have = $true } } catch { }

if ($New -or -not $have) {
  if ($have -and -not $New) { } else {
    $bytes = New-Object byte[] 32
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $k = -join ($bytes | ForEach-Object { $_.ToString('x2') })
    Save $k
    $have = $true; $cur = $k
    Write-Host ('Made a new shared key and saved it to ' + $keyFile) -ForegroundColor Green
  }
} else {
  Write-Host ('A key is already here: ' + $keyFile) -ForegroundColor Green
}

if ($Show) {
  Write-Host ''
  Write-Host 'THE KEY (copy the whole line; inside the VM run:  setup-key.ps1 -Set <paste it> ):' -ForegroundColor Yellow
  Write-Host $cur
} else {
  Write-Host ''
  Write-Host 'To copy it into the VM, run this again with  -Show  and paste the line into the VM with  setup-key.ps1 -Set <that line>' -ForegroundColor Gray
}
exit 0
