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

# FULLSCREEN GATE SCALES LIKE THE MENUS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function fsGateShow(why){
'@ @'
// v35.04 (cw-fsgatezoom): the gate takes the menu screen factor like every other window (applyMenuZoom). It is mounted on the body,
// outside that list, so at 4K it drew at half the size of the pause menu. Inset 0 still fills the screen at any zoom.
function fsGateZoom(){
  var g=document.getElementById('fsgate'); if(!g) return 0;
  var z=1; try{ z=menuScale(); }catch(_ms){}
  if(!(z>0)) z=1;
  var zs=String(z); if(g.style.zoom!==zs) g.style.zoom=zs;
  return z;
}
function fsGateShow(why){
'@

SubRx @'
  FSG.open=1; g.style.display='flex';
'@ @'
  FSG.open=1; g.style.display='flex';
  try{ fsGateZoom(); }catch(_gz){}
'@

SubRx @'
  if(on!==FSG.was){ FSG.was=on; try{ fsPauseBtnSync(); }catch(_pb){} }
'@ @'
  if(on!==FSG.was){ FSG.was=on; try{ fsPauseBtnSync(); }catch(_pb){} }
  if(FSG.open){ try{ fsGateZoom(); }catch(_gz){} }   // v35.04 (cw-fsgatezoom): a resize while the gate is up
'@

SubRx @'
var VER='35.03';
'@ @'
var VER='35.04';
'@

$pat = "(?m)^  now:'v35\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.04: The fullscreen gate is the same size as the menus at 4K. Check 35.04 fails on v35.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
