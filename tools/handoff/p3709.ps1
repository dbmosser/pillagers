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

# DEAD CODE OUT 6 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// The digits 5 to 9 in a raid: the item on that key, at once, with the gun still in his hands. A grenade key throws its grenade through the quick
// throw path (G.tsel is pointed at it for the throw and put back, so the G pick does not move), a medical key uses its item through the path H
// uses (useBeltHeal), key 9 slots a plate as a hold on H does (quickPlate). An empty key gives the usual none line. G.hot never moves.
function beltInstant(i){
  var p=G&&G.player, sl, c, cls='', ti, sv;
  if(!G||G.sim||G.over||G.paused||G.trade||G.hubFloor||!p||i<0||i>=HOTBAR_N) return false;
  if(p.downed){ say('NOT WHILE DOWN'); return false; }
  if(p.dying||p.specOut) return false;
  sl=hotbarSlots(); c=sl[i];
  cls=BELT_CLASS[i]; if(c&&c.kind==='throw') cls='throw'; else if(c&&(c.kind==='heal'||c.kind==='stim')) cls='med'; else if(c&&c.kind==='armor') cls='plate'; else if(i<GUNKEYS) return false;   // cw-hotitems: the item on the key decides
  if(cls==='throw'){
    ti=(c&&c.kind==='throw'&&c.icon&&(c.count|0)>0)?THROWKEYS.indexOf(c.icon):-1;
    if(ti<0){ say('NO THROWABLE ON KEY '+slotKeyName(i)); return false; }
    sv=G.tsel; G.tsel=ti;
    try{ doThrow(); } finally { G.tsel=sv; }
    return true;
  }
  if(cls==='med') return useBeltHeal(i);
  if(cls==='plate') return quickPlate();
  return false;
}

'@ @'
// v28.xx (cw-dead6): dead code out, no caller anywhere (audit 2026-10-28): beltInstant, padAxis.

'@

SubRx @'
function padAxis(v){ return padStick(v,0).x; }

'@ @'

'@

SubRx @'
var VER='37.08';
'@ @'
var VER='37.09';
'@

$pat = "(?m)^  now:'v37\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.09: Nothing a player can see changes. Check 37.09 fails on v37.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
