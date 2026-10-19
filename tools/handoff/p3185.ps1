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

# CAMERA 30 PERCENT CLOSER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ZT=1,ZC=1,zoomSaveT=0;
'@ @'
// v28.xx (cw-cx-camera130), HIS PICK (2026-10-18, art survey a36 C): "30 percent closer". One default for both windows and every raid mode; a saved dial keeps its value.
var ZDEFAULT=1.3,ZT=ZDEFAULT,ZC=ZDEFAULT,zoomSaveT=0;
function loadZoom(){ ZT=ZC=clamp(P.zoom||ZDEFAULT,ZMIN,ZMAX); }
'@

SubRx @'
  ZT=ZC=clamp(P.zoom||1,ZMIN,ZMAX);
'@ @'
  loadZoom();   // v28.xx (cw-cx-camera130): use 1.3 only when there is no saved zoom; seed the eased camera and the dial together.
'@

SubRx @'
  if(code==='Numpad0'){ setZoom(1);   /* v28.xx (cw-gunkeys0): the 0 key is the Rocket Launcher now, so zoom to 100 is the numpad 0 only */ if(G&&!G.over) say('ZOOM 100%','sys'); }   // v22.xx (R55): a system label in caps
'@ @'
  if(code==='Numpad0'){ setZoom(ZDEFAULT); if(G&&!G.over) say('ZOOM '+Math.round(ZDEFAULT*100)+'%','sys'); }   // v28.xx (cw-cx-camera130): reset zoom uses the new default, 130 percent; number-row 0 stays the rocket launcher.
'@

SubRx @'
['Numpad0','zoom to 100%']
'@ @'
['Numpad0','zoom to 130%']
'@

SubRx @'
var VER='31.84';
'@ @'
var VER='31.85';
'@

$pat = "(?m)^  now:'v31\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.85: The default camera is 30 percent closer. Reset zoom returns to 130 percent. Check 31.85 fails on v31.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
