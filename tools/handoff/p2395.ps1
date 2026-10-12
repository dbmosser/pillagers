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

# THE TRIPWIRE MINE KEEPS A KEY WITH A PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return out;
}
function unkeyedHeals(){
'@ @'
  // v23.xx (gameplayfixa), from the review of feat1a, his #6 and answer 32 ("on the belt like a grenade"): THE TRIPWIRE MINE HAS
  // A KEY WHILE A PLATE IS CARRIED. Four gun keys, three throws, Medical and the plate fill all nine keys, so the mine cell was never
  // pushed: Q passed it over (no cell, v15.06) and the pad, which throws only from a belt cell, could not throw it at all until the
  // plate was spent. A carried mine that no cell shows now takes the highest vacant gun key (4, then 3), as a Stim does (v22.42),
  // as an automatic pin, so it stays on that key for the raid: spending the plate later does not move it to key 9.
  if(G.pouch&&G.pouch.trip>0&&ITEMS.trip&&!G.sim&&!G.hubFloor&&!G.over){
    var _tpS=false, _tpI;
    for(_tpI=0;_tpI<out.length;_tpI++) if(out[_tpI]&&(out[_tpI].k==='throw:trip'||out[_tpI].itemKey==='trip')) _tpS=true;
    if(!_tpS){
      G.hotAssign=G.hotAssign||{};
      for(_tpI=GUNKEYS-1;_tpI>=2;_tpI--){
        if(_tpI<out.length&&out[_tpI]&&out[_tpI].vacant&&out[_tpI].k==='gunkey:'+_tpI&&G.hotAssign[_tpI]===undefined){
          G.hotAssign[_tpI]='trip'; G.hotAuto=G.hotAuto||{}; G.hotAuto[_tpI]=1;
          out[_tpI]={k:'throw:trip',name:ITEMS.trip.name,icon:'trip',kind:'throw',count:G.pouch.trip,c:ITEMS.trip.c||'#cdd6dd',assigned:1,itemKey:'trip',empty:0};
          break;
        }
      }
    }
  }
  return out;
}
function unkeyedHeals(){
'@

SubRx @'
var VER='23.94';
'@ @'
var VER='23.95';
'@

$pat = "(?m)^  now:'v23\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.95: A Tripwire Mine always has a belt key, on key 4 or 3 when an armour plate fills key 9, and the controller can select and throw it. Check 23.95 fails on v23.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
