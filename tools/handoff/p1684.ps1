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

# HOLD Y NEXT TO A TEAMMATE TO PATCH HIM UP WITH WHAT YOUR BELT HAS SELECTED (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
function netAidTarget(p){
'@ @'
function netAidTarget(p,any){   // v16.84: any set skips the facing test (the Y hold); the belt path still faces him
'@

SubRx @'
    if(Math.abs(a)<=0.8&&d<bd){ bd=d; best=g.seat; }
'@ @'
    if((any||Math.abs(a)<=0.8)&&d<bd){ bd=d; best=g.seat; }
'@

SubRx @'
function netAidStart(s,key){
'@ @'
// v16.84, HIS ASK IN TWO-PLAYER CO-OP ON ONE PC: HOW DOES PLAYER 2 HEAL PLAYER 1 WITH BANDAGES? HOLD Y. Y on a pad and T on the
// keyboard, with a teammate up top within NET_REV_R (facing him is not needed, unlike the belt path), start a heal for him: a
// Bandage from your backpack while he is under its 85, else a Medkit if you carry one and he is under full. It takes the belt
// wind-up (netAidStart: the item leaves the backpack, startPrep runs, and at the end the aid word goes to his window, which
// applies it by its own rules), and it is refused with a line when he needs nothing or you carry nothing; quiet set keeps that
// line back (the pad Y beside a box to search). Returns true only when a wind-up started. Nothing new is spent or healed here;
// no number moved.
// v16.84, his rule: Y (T on the keyboard) uses the Bandage, Medkit or armour plate SELECTED on your tactical belt, and only that;
// with anything else selected it says to select one, and nothing is spent.
function netAidHold(quiet){
  var p, s, nm, hs=null, key=null;
  if(typeof G==='undefined'||!G||G.over||G.paused||G.sim||!G.player||!NET.on) return false;
  p=G.player; if(p.downed||p.dying) return false;
  s=netAidTarget(p,true); if(s<0) return false;
  if(!NET.up[s]) return false;
  nm=netSeatName(s)||'your teammate';
  try{ hs=hotbarSlots()[hotSel()]; }catch(_hs){ hs=null; }
  if(hs&&hs.kind==='heal') key=hs.icon;
  else if(hs&&hs.kind==='armor') key='plate';
  if(!key||!ITEMS[key]){ if(!quiet) say('Select a Bandage, a Medkit or a plate on your tactical belt to patch up '+nm+'.'); return false; }
  return !!netAidStart(s,key);   // its own lines refuse a teammate who needs nothing, or an item you have none of
}function netAidStart(s,key){
'@

SubRx @'
    if(hn===3){ padHold('KeyX',(pressed(3)&&!bagNav)||(_xDown&&PAD.xMode==='KeyE'&&_xSearch)); continue; }
'@ @'
    // v16.84, HIS ASK: HOLD Y TO PATCH UP A TEAMMATE. On the press, with a teammate up top within reach (facing not needed), Y
    // starts a heal for him (netAidHold: a Bandage under his 85, else a Medkit) and that hold does not search. When no heal
    // starts (nobody in reach, he needs nothing, nothing to give) Y holds keyboard X, the ring search, as before, so a teammate
    // standing beside you in the circle never blocks the search; the refusal line is kept quiet when there is a box to search.
    // Decided on the press and kept for the hold, one start per press; PAD.prev is stamped after this loop, so the press is an edge.
    if(hn===3){
      var _yD=pressed(3)&&!bagNav;
      if(_yD&&!PAD.prev[3]){ var _yA=false; try{ _yA=!!(NET.on&&!G.over&&typeof netAidHold==='function'&&netAidHold(!!G.nearContainer)); }catch(_ye){} PAD.yAid=_yA; }
      if(!_yD) PAD.yAid=false;
      padHold('KeyX',(_yD&&!PAD.yAid)||(_xDown&&PAD.xMode==='KeyE'&&_xSearch));
      continue;
    }
'@

SubRx @'
  if(code==='KeyQ'&&G&&!G.over&&!repeat) cycleThrow();
'@ @'
  if(code==='KeyQ'&&G&&!G.over&&!repeat) cycleThrow();
  if(code==='KeyT'&&G&&!G.over&&!G.paused&&!repeat&&NET.on&&typeof netAidHold==='function') netAidHold();   // v16.84, his ask: T patches up a teammate in reach with your Bandage or Medkit, the pad Y; T was bound to nothing in a raid (H cycles the legend, X is the ring search)
'@

SubRx @'
var VER='16.83';
'@ @'
var VER='16.84';
'@

$pat = "(?m)^  now:'v16\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.84: HOLD Y NEXT TO A TEAMMATE TO PATCH HIM UP. His ask during his co-op session: players need a way to heal each other with their items. Next to a teammate, Y on a controller or T on the keyboard uses the Bandage, Medkit or armour plate selected on your tactical belt on him, with the usual wind-up, and only that; with anything else selected it says to select one. With nobody in reach Y is the ring search as before. Check 16.84 fails on v16.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
