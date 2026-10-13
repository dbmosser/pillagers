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

# THE MINIMAP KNOWS WHEN TO STEP ASIDE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawMinimap(){
'@ @'
// v24.xx (minimap3), HIS ORDER (2026-10-12): "add minimap", where it shows. A Settings row, MINIMAP ON or OFF (on by default; a save
// from before the row reads as on). It steps aside whenever something else owns the screen: the sector map (M) and the backpack are
// open, the raid has ended (the KILLED IN ACTION, EXTRACTED and ABANDONED cards) or the DEMO run is over (RUN OVER), and it is never
// drawn in the Undercroft. Off or hidden, the CONDITIONS panel moves back up under the credits as before. Player 2's window draws
// its own from its own position, and the size follows the screen (hudRes) at 1080p, 1440p and 4K, like the rest of the HUD.
function mmShown(){
  if(CFG.minimap===0) return false;
  if(typeof state==='string'&&state!=='raid') return false;
  if(!G||G.over||G.mapOpen||G.bagOpen) return false;
  if(G.arcade&&typeof ARCADE==='object'&&ARCADE&&ARCADE.over) return false;
  return true;
}
function drawMinimap(){
'@

SubRx @'
  if(!p||G.sim||!G.map||!(W>0)||!(H>0)) return 0;
'@ @'
  if(!p||G.sim||!G.map||!(W>0)||!(H>0)) return 0;
  if(!mmShown()) return 0;   // v24.xx (minimap3): the Settings row, the map, the backpack, the end cards and the Undercroft
'@

SubRx @'
     {n:'LARGE FOR TV', cfg:{hudTv:1}}
   ], def:0},
'@ @'
     {n:'LARGE FOR TV', cfg:{hudTv:1}}
   ], def:0},
  // v24.xx (minimap3): his "add minimap"; on by default
  {k:'minimap', label:'MINIMAP',
   hint:'THE STREET AROUND YOU, TOP RIGHT IN A RAID.',
   opts:[
     {n:'ON',  cfg:{minimap:1}},
     {n:'OFF', cfg:{minimap:0}}
   ], def:0},
'@

SubRx @'
var VER='25.32';
'@ @'
var VER='25.33';
'@

$pat = "(?m)^  now:'v25\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.33: Settings has a MINIMAP row, and the minimap hides under the map, the backpack and the end cards. Check 25.33 fails on v25.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
