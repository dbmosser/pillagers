# Drain the public collector into exports/ so the watchdog reads stranger runs
# exactly the way it reads Daniel's own.
#
#   .\tools\pull-public-runs.ps1 -Url https://dr-runs.you.workers.dev/run -Key <admin key>
#
# Files land as exports/public-<install>-<timestamp>.txt, deliberately WITHOUT the
# consumed- prefix, because that prefix is the watchdog's "already mined" marker
# and these have not been mined yet.
param(
  [Parameter(Mandatory=$true)][string]$Url,
  [Parameter(Mandatory=$true)][string]$Key,
  [string]$Out = 'C:\claudecode\dark raiders\exports'
)

$ErrorActionPreference = 'Stop'

try {
  $resp = Invoke-WebRequest -Uri ("$Url" + "?key=$Key") -Method GET -UseBasicParsing -TimeoutSec 30
} catch {
  Write-Output "FAILED to reach collector: $($_.Exception.Message)"
  exit 1
}

$rows = $resp.Content | ConvertFrom-Json
if (-not $rows -or $rows.Count -eq 0) { Write-Output 'no runs waiting'; exit 0 }

$new = 0; $skipped = 0
foreach ($r in $rows) {
  # The collector key is already unique per post, so it is the filename.
  $safe = ($r.name -replace '[^A-Za-z0-9_.-]', '_')
  $path = Join-Path $Out ("public-$safe.txt")
  # Never re-write one we already pulled, whether or not it has been consumed.
  $consumed = Join-Path $Out ("consumed-public-$safe.txt")
  if ((Test-Path $path) -or (Test-Path $consumed)) { $skipped++; continue }
  [IO.File]::WriteAllText($path, $r.body, (New-Object Text.UTF8Encoding $false))
  $new++
}

Write-Output "pulled $new new, skipped $skipped already present"

# A quick shape check so a batch of junk is obvious immediately rather than after
# I have already drawn conclusions from it. Same authenticity rule the watchdog
# uses on his own files: a run with no duration and no movement is a fixture leak,
# not a person.
Get-ChildItem $Out -Filter 'public-*.txt' | ForEach-Object {
  $t = Get-Content $_.FullName -Raw
  $suspect = ($t -match 'dur:0s') -and ($t -match 'moved:0')
  $ver = if ($t -match 'DARK RAIDERS v([\d.]+)') { $matches[1] } else { '?' }
  $iid = if ($t -match 'Install:\s*(\w+)') { $matches[1] } else { '?' }
  $runs = if ($t -match 'Profile: (\d+) runs') { $matches[1] } else { '?' }
  Write-Output ("  {0}  v{1}  install {2}  {3} runs{4}" -f $_.Name, $ver, $iid, $runs, $(if($suspect){'  <-- SUSPECT, zero duration'}else{''}))
}
