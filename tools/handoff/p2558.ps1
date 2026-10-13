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

# THE FORGE: THE UNDERCROFT SHOWS IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var W2=WEAPONS[it.gk];
'@ @'
    var _ff=forgeOf(it.gk), W2=_ff?forgeApply(WEAPONS[it.gk],_ff.fk,_ff.el):WEAPONS[it.gk];   // v23.xx (forge13): THE FORGE, the upgraded numbers
    if(_ff){ R.push(['UPGRADE',_ff.fk===2?'MK III':'MK II']); if(_ff.fk===2&&ELEM[_ff.el]) R.push(['ELEMENT',ELEM[_ff.el].name+'   '+ELEM[_ff.el].w2]); }
'@

SubRx @'
    var perShot=W2.dmg*(W2.pellets||1);
'@ @'
    var perShot=Math.round(W2.dmg*(W2.pellets||1)*10)/10;   // v23.xx (forge13): a forged pellet gun reads 124.8, not a float tail
'@

SubRx @'
function itemRows(key){
'@ @'
// v23.xx, THE FORGE (2026-10-12), forge13: THE UNDERCROFT SHOWS IT. forgeOf(gk) is the forge of the gun of that model in play here:
// in a live raid the gun in a hand or the next backpack copy; in the Undercroft the record kept on the armoury model (P.forged, forge12).
// The stash and backpack hover rows lead with UPGRADE (MK II or MK III) and ELEMENT and read the upgraded numbers, the belt and the
// sector page name the gun with its MK (Auto Rifle MK III), and a gun icon of a forged model glows gold, or in its element colour with a
// small element pip. Display only.
function forgeOf(gk){
  var p, w=null;
  if(!gk||!WEAPONS[gk]) return null;
  if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&G.player&&!G.hubFloor){
    p=G.player;
    w=(p.wep&&p.wep.id===gk)?p.wep:((p.sec&&p.sec.id===gk)?p.sec:((G.stowQ&&typeof gunQPeek==='function')?gunQPeek(gk):null));
    return (w&&(w.fk===1||w.fk===2))?{fk:w.fk,el:(w.fk===2&&ELEM[w.el])?w.el:''}:null;
  }
  if(P&&P.forged&&P.forged[gk]&&(P.weapons||[]).indexOf(gk)>=0&&(P.forged[gk].fk===1||P.forged[gk].fk===2)) return P.forged[gk];
  return null;
}
function forgeCol(f){ return f?((f.fk===2&&ELEM[f.el])?ELEM[f.el].c:FORGE_GOLD):null; }
function hubForged(w){
  var f=(w&&w.id&&P&&P.forged)?P.forged[w.id]:null;
  return (f&&(f.fk===1||f.fk===2)&&(P.weapons||[]).indexOf(w.id)>=0)?forgeApply(w,f.fk,f.el):w;
}
function itemRows(key){
'@

SubRx @'
  var col=RCOL[gunRarity(W.id)]||tint||W.tint||'#ffd48a';
'@ @'
  var _fgi=forgeOf(W.id), col=forgeCol(_fgi)||RCOL[gunRarity(W.id)]||tint||W.tint||'#ffd48a';   // v23.xx (forge13): a forged model glows gold or in its element colour
'@

SubRx @'
    var _ok=false; try{ _ok=gunArt(c,fam,id,W,col,S); }catch(_ga){ _ok=false; }
'@ @'
    var _ok=false; try{ _ok=gunArt(c,fam,id,W,col,S); }catch(_ga){ _ok=false; }
    if(_ok&&_fgi&&_fgi.fk===2&&ELEM[_fgi.el]){ c.fillStyle=ELEM[_fgi.el].c; c.beginPath(); c.arc(17*_gu,-13*_gu,3.4*_gu,0,6.2832); c.fill(); c.strokeStyle='rgba(6,9,13,.85)'; c.lineWidth=Math.max(1,_gu); c.stroke(); }   // v23.xx (forge13): the element pip
'@

SubRx @'
  (P.kit||[]).forEach(function(k){ if(pq[k]!==undefined) pq[k]++; });
'@ @'
  wep=hubForged(wep); sec=hubForged(sec);   // v23.xx (forge13): the Undercroft belt names and tints a forged gun
  (P.kit||[]).forEach(function(k){ if(pq[k]!==undefined) pq[k]++; });
'@

SubRx @'
  try{ w=(P.equipped&&P.equipped!=='fists')?WEAPONS[P.equipped]:null; }catch(_gw){ w=null; }
'@ @'
  try{ w=(P.equipped&&P.equipped!=='fists')?WEAPONS[P.equipped]:null; }catch(_gw){ w=null; }
  if(w) w=hubForged(w);   // v23.xx (forge13): going up with the Auto Rifle MK III
'@

SubRx @'
var VER='25.57';
'@ @'
var VER='25.58';
'@

$pat = "(?m)^  now:'v25\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.58: The Undercroft shows your upgraded guns by name, colour and numbers. Check 25.58 fails on v25.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
