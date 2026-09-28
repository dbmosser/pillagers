param([string]$Key,[string]$After='')
# Applies draft-<Key>.json (after any drafts named in -After, comma separated, in order) to an in-memory copy of
# dark_raiders.html and reports each anchor's match count. Also applies the check to an in-memory mkfixture.ps1.
# Writes nothing. Exit code 0 only when every anchor matched exactly once and every text is ASCII.
$ErrorActionPreference='Stop'
$sp=Split-Path -Parent $MyInvocation.MyCommand.Definition
$s=[IO.File]::ReadAllText('C:\claudecode\dark raiders\dark_raiders.html')
$fx=[IO.File]::ReadAllText('C:\claudecode\dark raiders\tools\mkfixture.ps1')
$bad=0
function Pat([string]$old){ ($old.Replace("`r",'') -split "`n" | ForEach-Object { [regex]::Escape($_) }) -join "\r?\n" }
function Apply([string]$k,[bool]$report){
  $d=Get-Content -Raw (Join-Path $sp ("draft-"+$k+".json")) | ConvertFrom-Json
  $i=0
  foreach($e in @($d.edits)){
    $i++; $a=[string]$e.anchor; $r=([string]$e.replacement).Replace("`r",'')
    foreach($t in @($a,$r)){ foreach($ch in $t.ToCharArray()){ if([int]$ch -gt 126 -or ([int]$ch -lt 32 -and [int]$ch -ne 10 -and [int]$ch -ne 9)){ "  $k edit $i : NON-ASCII or control character code $([int]$ch)"; $script:bad++; break } } }
    $c=([regex]::Matches($script:s,(Pat $a))).Count
    if($report -or $c -ne 1){ "  $k edit $i : anchor matched $c times: " + ($a.Split("`n")[0]).Substring(0,[Math]::Min(90,($a.Split("`n")[0]).Length)) }
    if($c -ne 1){ $script:bad++; continue }
    $script:s=[regex]::Replace($script:s,(Pat $a),{ param($m) $r })
  }
  $chk=[string]$d.check
  foreach($ch in $chk.ToCharArray()){ if([int]$ch -gt 126){ "  $k check: NON-ASCII character $([int]$ch)"; $script:bad++; break } }
  if($report){
    if(-not $chk.TrimStart().StartsWith("{v:'VER',what:")){ "  $k check: must start with   {v:'VER',what:"; $script:bad++ }
    if(-not $chk.TrimEnd().EndsWith('}},')){ "  $k check: must end with }},"; $script:bad++ }
    if($chk -match "(?m)^'@"){ "  $k check: a line starts with '@"; $script:bad++ }
    foreach($f in 'title','why','now','check'){ if(-not $d.$f){ "  $k : field $f is missing"; $script:bad++ } }
    "  $k : $(@($d.edits).Count) edits, check $($chk.Length) chars, title: $($d.title)"
  }
}
foreach($k in ($After.Split(',') | Where-Object { $_ })){ Apply $k $false }
Apply $Key $true
if($bad){ "FAIL: $bad problems"; exit 1 } else { "OK: every anchor matched once" ; exit 0 }
