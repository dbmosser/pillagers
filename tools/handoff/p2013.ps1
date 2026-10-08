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

# A PILLAGER LOOKS THE SAME IN BOTH WINDOWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var r={kind:'raider',x:x,y:y,r:11,
'@ @'
  var r={kind:'raider',x:x,y:y,lx:Math.round(x),ly:Math.round(y),r:11,
'@

SubRx @'
m.rg=netClean(e.rig,8); m.mc=e.merc?1:0; }
'@ @'
m.rg=netClean(e.rig,8); m.mc=e.merc?1:0; if(typeof e.lx==='number'){ m.lx=e.lx; m.ly=e.ly; } }   // v20.13: his birthplace, which his look is hashed from
'@

SubRx @'
try{ lk=raiderLook(e.ident,m.x,m.y);
'@ @'
try{ if(typeof m.lx==='number'&&typeof m.ly==='number'){ e.lx=m.lx; e.ly=m.ly; } lk=raiderLook(e.ident,(typeof e.lx==='number')?e.lx:m.x,(typeof e.ly==='number')?e.ly:m.y);   /* v20.13, code review: hash where he was born, as the host did */
'@

SubRx @'
var VER='20.12';
'@ @'
var VER='20.13';
'@

$pat = "(?m)^  now:'v20\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.13: In co-op, every pillager looks the same in both windows. Check 20.13 fails on v20.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
