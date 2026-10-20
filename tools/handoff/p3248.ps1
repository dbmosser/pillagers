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

# PRE-RAID POLISH: NO CUT OFF CHIPS, WIDER KIT COLUMN, SHARPER MAP NAMES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
column-gap:10px; align-content:center; align-items:center; padding:0 12px; background:var(--ui-raised);
'@ @'
column-gap:8px; align-content:center; align-items:center; padding:0 8px; background:var(--ui-raised);
'@

SubRx @'
#sectormodal .srsr{ position:absolute; width:1px; height:1px; overflow:hidden; clip:rect(0 0 0 0); white-space:nowrap; }
'@ @'
#sectormodal .srsr{ display:none; }
'@

SubRx @'
<i>EQUIP PLATES ON THE SURFACE</i>
'@ @'
<i>EQUIP PLATES</i>
'@

SubRx @'
c.lineWidth=4; c.strokeStyle='rgba(8,18,28,.9)'
'@ @'
c.lineWidth=3; c.strokeStyle='rgba(8,18,28,.9)'
'@

SubRx @'
width="840" height="'+Math.round(840*M.h/M.w)+'"
'@ @'
width="640" height="'+Math.round(640*M.h/M.w)+'"
'@

SubRx @'
width:34px; height:32px; min-width:0; padding:0; display:grid;
'@ @'
width:34px; height:30px; min-width:0; padding:0; display:grid;
'@

SubRx @'
grid-template-columns:minmax(0,1fr) 200px;
'@ @'
grid-template-columns:minmax(0,1fr) 184px;
'@

SubRx @'
var VER='32.47';
'@ @'
var VER='32.48';
'@

$pat = "(?m)^  now:'v32\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.48: The pre-raid page chips fit their boxes and the map names read larger. Check 32.48 fails on v32.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
