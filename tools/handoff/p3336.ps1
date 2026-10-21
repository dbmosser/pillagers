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

# the minimap is off by default; one Settings row turns it on (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mmSizeK(){ var s=+CFG.mmSz; return (s>=0.5&&s<=2)?s:1; }
'@ @'
function mmSizeK(){ var s=+CFG.mmSz; return (s>=0.5&&s<=2)?s:1; }
// v33.35 (cw-mmoff), HIS ORDER (2026-10-20): "remove minimap entirely, i guess make it an option in settings but default to leaving it off". The one Settings row
// (MINIMAP) has OFF first and OFF is the usual: mmSz 0 draws nothing, and the column, the run info panel and everything under the corner already sit by MMAP.box
// being empty. mmSizeK still reads 1 for a 0, so the column keeps its width. mmOffMove moves a save that holds a minimap size to OFF once (P.mmOff1 marks it done).
function mmOn(){ return +CFG.mmSz>0; }
function mmOffMove(){
  if(!P||P.mmOff1===1) return false;
  if(P.gameOpts&&typeof P.gameOpts.mmSize==='number') P.gameOpts.mmSize=0;
  P.mmOff1=1;
  return true;
}
'@

SubRx @'
  if(CFG.minimap===0) return false;
'@ @'
  if(CFG.minimap===0||!mmOn()) return false;   // v33.35 (cw-mmoff): the Settings row says OFF
'@

SubRx @'
  // v24.xx (minimap3): his "add minimap"; on by default
  {k:'minimap', label:'MINIMAP',
   hint:'The street around you, top right in a raid.',
   opts:[
     {n:'ON',  cfg:{minimap:1}},
     {n:'OFF', cfg:{minimap:0}}
   ], def:0},

'@ @'

'@

SubRx @'
  {k:'mmSize', label:'MINIMAP SIZE', sec:'DISPLAY',
   hint:'How big the minimap is, top right. The panels under it move down.',
   opts:[
     {n:'SMALL',    cfg:{mmSz:0.75}},
     {n:'STANDARD', cfg:{mmSz:1}},
     {n:'LARGE',    cfg:{mmSz:1.35}}
   ], def:1},

'@ @'
  // v33.35 (cw-mmoff), HIS ORDER (2026-10-20): "remove minimap entirely, i guess make it an option in settings but default to leaving it off". One row for the minimap now:
  // OFF (the usual) and the three sizes. The old MINIMAP on/off row is gone (one control per job). A save that held a size moves to OFF once (mmOffMove).
  {k:'mmSize', label:'MINIMAP', sec:'DISPLAY',
   hint:'The street around you, top right. Off is the usual.',
   opts:[
     {n:'OFF',      cfg:{mmSz:0}},
     {n:'SMALL',    cfg:{mmSz:0.75}},
     {n:'STANDARD', cfg:{mmSz:1}},
     {n:'LARGE',    cfg:{mmSz:1.35}}
   ], def:0},
'@

SubRx @'
  try{ volMusicMove(); }catch(_vm){}
'@ @'
  try{ volMusicMove(); }catch(_vm){}
  try{ mmOffMove(); }catch(_mo){}   // v33.35 (cw-mmoff): once per save
'@

SubRx @'
var VER='33.35';
'@ @'
var VER='33.36';
'@

$pat = "(?m)^  now:'v33\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.36: No minimap in raids unless you turn it on in Settings. Check 33.36 fails on v33.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
