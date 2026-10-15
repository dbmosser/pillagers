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

# PLAYER 2 HUNTS THE SAME GOLDEN ENEMY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // FLOW-NET-OUT (the next coop builds add their keys above this line)
'@ @'
  o.g=goldNetOut(); o.c=clueNetOut();   // v27.18 (coop5): and the golden enemy and the clue hunt
  // FLOW-NET-OUT (the next coop builds add their keys above this line)
'@

SubRx @'
  // FLOW-NET-IN (the next coop builds take their keys above this line)
'@ @'
  if(fl.g) goldNetTake(fl.g);   // v27.18 (coop5): the golden enemy
  if(fl.c) clueNetTake(fl.c);   // v27.18 (coop5): the clue hunt
  // FLOW-NET-IN (the next coop builds take their keys above this line)
'@

SubRx @'
  // FLOW-NET-WORD (the next coop builds take their words above this line)
'@ @'
  if(m.k==='clue'){
    if(NET.role!=='host'||!netEntsHost()||!flowOn()) return 'ignored';
    return clueTaken(m.i|0,1)?'clue':'gone';
  }
  // FLOW-NET-WORD (the next coop builds take their words above this line)
'@

SubRx @'
function goldTick(dt){
  var S=goldS(), p=G.player, ix, e;
'@ @'
function goldTick(dt){
  var S=goldS(), p=G.player, ix, e;
  if(flowPeer()) return;   // v27.18 (coop5): a linked player 2 window gilds nothing, the golden enemy is the host one (goldNetTake)
'@

SubRx @'
function clueTick(dt){
  var S=G.flow.gold, C=clueS(), p=G.player, i, pr;
'@ @'
function clueTick(dt){
  var S=G.flow.gold, C=clueS(), p=G.player, i, pr;
  if(flowPeer()){ cluePeerTick(dt); return; }   // v27.18 (coop5): a linked player 2 window lays out no hunt, it keeps the host one (clueNetTake)
'@

SubRx @'
function clueCircle(C){
'@ @'
function clueCircle(C){
  if(C.mir) return C.mir;   // v27.18 (coop5): the circle as the host has it, for a linked window
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.18 (coop5), HIS ORDER (2026-10-14), the two player first: THE GOLDEN ENEMY AND ITS CLUE HUNT COME TO PLAYER 2. Each window gilded a machine of its own (on the same dice, but from where
// each player stood, so not always the same one) and laid out its own three clue props, so the two players could hunt two different golden machines, and the hoard of the real one
// was announced to the host alone. The host now says which body is gilded (key g: its body number, or that it fell and where) and how the hunt stands (key c: the three props and which
// are taken, how many, and the search circle with its size); the linked window gilds and lays out nothing (goldTick, clueTick) and draws the shine on the body the host named, the props, and
// the circle on its maps from that. THE CLUES ARE FOR BOTH: player 2 walking within reach of a prop takes it in his own window at once (the callout, the sparks) and tells the host
// (t fl, k clue), which marks it taken for everyone and shrinks the circle; so either of them can find the golden enemy. When it falls, GOLDEN ENEMY DOWN is said in both windows and the
// hunt is over; the hoard it leaves is a box like the rest and is marked on the maps by its name.
function goldNetOut(){
  var S=G.flow&&G.flow.gold;
  if(!S) return 0;
  if(S.dead) return [0,1,Math.round(+S.dx||0),Math.round(+S.dy||0)];
  if(S.ref&&S.ref.nid) return [S.ref.nid|0,0,0,0];
  return 0;
}
function goldNetTake(a){
  var S=goldS(), e;
  if(!a||typeof a.length!=='number'||a.length<4) return 0;
  if(a[1]){
    if(!S.dead){
      S.dead=1; S.dx=+a[2]||0; S.dy=+a[3]||0;
      try{ spark(S.dx,S.dy,'#ffc72e',30,320); flash(S.dx,S.dy,260,'#ffc72e',.5); say('GOLDEN ENEMY DOWN','obj',{sub:'SEARCH THE HOARD'}); }catch(_gd){}
    }
    return 1;
  }
  e=evEnt(a[0]|0);
  if(e&&!S.dead){ if(!e.golden){ e.golden=1; e.r=Math.round(e.r*GOLD.big); } S.ref=e; }
  return 1;
}
function clueNetOut(){
  var C=G.flow&&G.flow.clue, a=[], i, c;
  if(!C||!C.props) return 0;
  if(C.done) return [1];
  c=clueCircle(C);
  for(i=0;i<C.props.length&&i<3;i++) a.push([CLUE_KINDS.indexOf(C.props[i].kind),Math.round(C.props[i].x),Math.round(C.props[i].y),C.props[i].got?1:0]);
  return [0,C.n|0,Math.round(c.x),Math.round(c.y),Math.round(c.r),c.st|0,a];
}
function clueNetTake(a){
  var C=clueS(), i, r, pr, first;
  if(!a||typeof a.length!=='number') return 0;
  if(a[0]){ C.done=1; return 1; }
  if(a.length<7||!a[6]||typeof a[6].length!=='number'||!isFinite(+a[2])||!isFinite(+a[3])||!isFinite(+a[4])) return 0;
  first=!C.props;
  if(first){ C.props=[]; C.off=[]; C.lx=0; C.ly=0; }
  for(i=0;i<a[6].length&&i<3;i++){
    r=a[6][i]; if(!r||r.length<4||!isFinite(+r[1])||!isFinite(+r[2])) continue;
    pr=C.props[i];
    if(!pr){ pr={kind:CLUE_KINDS[r[0]|0]||'scanner',x:0,y:0,got:0}; C.props[i]=pr; }
    pr.x=+r[1]; pr.y=+r[2]; if(r[3]) pr.got=1;
  }
  C.n=a[1]|0;
  C.mir={x:+a[2],y:+a[3],r:+a[4],st:a[5]|0};
  if(first){ try{ say('GOLDEN ENEMY','info',{sub:'SEARCH CIRCLE ON THE MAP'}); }catch(_cs){} }
  return 1;
}
// a clue taken, by anyone: marked, counted, said. Returns whether it was new.
function clueTaken(ix,byOther){
  var C=G.flow&&G.flow.clue, pr;
  if(!C||!C.props||C.done||!C.props[ix]||C.props[ix].got) return false;
  pr=C.props[ix]; pr.got=1; C.n=(C.n|0)+1;
  try{ spark(pr.x,pr.y,'#ffe08a',14,200); say('CLUE '+C.n+'/'+C.props.length,'obj',{sub:CLUE_TXT[pr.kind]+(byOther?'  YOUR PARTNER':'')}); }catch(_cp){}
  return true;
}
function cluePeerTick(dt){
  var C=clueS(), p=G.player, i, pr;
  if(!C.props||C.done||!p||p.downed||p.dying) return;
  for(i=0;i<C.props.length;i++){
    pr=C.props[i];
    if(!pr||pr.got||Math.hypot(p.x-pr.x,p.y-pr.y)>=CLUE.pick) continue;
    if(clueTaken(i,0)) flowNetPost({k:'clue',i:i});
  }
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.17';
'@ @'
var VER='27.18';
'@

$pat = "(?m)^  now:'v27\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.18: Player 2 now hunts the same golden enemy as player 1 and finds the same clues. Check 27.18 fails on v27.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
