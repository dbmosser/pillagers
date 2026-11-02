$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE OVERSEER IGNORES DECOYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function ping(x,y,s,h,quiet,src,typ,ent,pre){
'@ @'
// v37.xx (cw-ovdecoy), his answer g-13 (2026-10-25): "No, the Overseer ignores decoys". PING_DECOY is 1 only while a decoy calls ping; the body loop
// below skips the boss then. Every other body still hears a decoy, and the Overseer still hears shots, steps and blasts.
var PING_DECOY=0;
function ping(x,y,s,h,quiet,src,typ,ent,pre){
'@

SubRx @'
if(e.kind==='listener') continue;             // it does not take orders from noise twice
'@ @'
if(e.kind==='listener') continue;             // it does not take orders from noise twice
    if(PING_DECOY&&e.boss) continue;   // v37.xx (cw-ovdecoy): the Overseer ignores decoys
'@

SubRx @'
if(dc.acc>=.8){ dc.acc=0; if(!dc.fx) ping(dc.x,dc.y,420,false,false,'env','move'); }
'@ @'
if(dc.acc>=.8){ dc.acc=0; if(!dc.fx){ PING_DECOY=1; try{ ping(dc.x,dc.y,420,false,false,'env','move'); } finally { PING_DECOY=0; } } }   // v37.xx (cw-ovdecoy): flagged so the Overseer skips it. v17.29, co-op hunt 2026-09-28: a decoy passed on for drawing calls nothing; the host world hears it
'@

SubRx @'
var VER='37.31';
'@ @'
var VER='37.32';
'@

$pat = "(?m)^  now:'v37\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.32: The Overseer no longer follows a decoy. Check 37.32 fails on v37.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
