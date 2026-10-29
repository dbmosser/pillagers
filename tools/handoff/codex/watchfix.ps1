# watchfix.ps1 -Key cw-cx-KEY [-Dir DRAFTDIR]
# The ship writes only draft.why into DESIGN.md. Codex sometimes puts the "Watch:" line in draft.now. If why has no Watch: line and now has one, append it to why.
# The lane appends a call to this script to every Codex mk script it installs, so it runs every time the draft json is written. ASCII only; never throws.
param([string]$Key,[string]$Dir='C:\claudecode\dark raiders\tools\handoff\drafts')
try{
  $f=Join-Path $Dir ("draft-"+$Key+".json"); if(-not (Test-Path $f)){ exit 0 }
  $d=Get-Content -Raw -Encoding UTF8 $f | ConvertFrom-Json
  $why=[string]$d.why; $now=[string]$d.now
  if($why -match '(?i)\bWatch:'){ exit 0 }
  $m=[regex]::Match($now,'(?is)\bWatch:.*$'); if(-not $m.Success){ exit 0 }
  $d.why=($why.TrimEnd()+" "+$m.Value.Trim())
  [IO.File]::WriteAllText($f,($d | ConvertTo-Json -Depth 10),(New-Object Text.UTF8Encoding $false))
  "watchfix: added the Watch line from now to why in draft-$Key.json"
}catch{ "watchfix skipped: $($_.Exception.Message)" }
