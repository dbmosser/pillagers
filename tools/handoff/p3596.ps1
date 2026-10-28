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

# BOTH PLAYERS HOLD SEARCH FOR FASTER BOXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v28.xx (cw-cx-duosearch), his decision 2026-10-28: "Crates open faster with two". Every box, in demo and career co-op.
var DUO_SRCH=1.5, DUO_R=200;
function duoAt(ct,seat){
  if(!ct||!NET.on||!G||G.sim||!NET.upSeed||(G.seed>>>0)!==(NET.upSeed>>>0)) return false;
  if(seat===undefined) seat=NET.seat;
  var p=G.player, i, q;
  if(NET.role==='host'&&seat!==NET.seat&&!G.over&&p&&!p.downed&&!p.dying&&!p.specOut&&p.hp>0&&Math.hypot(p.x-ct.x,p.y-ct.y)<=DUO_R) return true;
  for(i=0;i<(NET.up||[]).length;i++){
    q=NET.up[i];
    if(q&&q.seat!==seat&&netUpShown(q)&&!netUpGone(q)&&!netUpHid(q)&&!q.dn&&!q.specOut&&!q.out&&q.hp>0&&Math.hypot(q.x-ct.x,q.y-ct.y)<=DUO_R) return true;
  }
  return false;
}
'@ @'
// v28.xx (cw-cx-bothsearch), his correction 2026-10-28: "both players need to be actively looting", "e.g. holding E".
var DUO_SRCH=1.5, DUO_R=200;
function duoHolding(){
  var p=G&&G.player, ct, i;
  if(!G||G.over||G.sim||G.paused||G.bagOpen||G.mapOpen||G.mapFirst||G.trade||G.forgeUI||G.wheel||G.legendOn||!p||p.downed||p.dying||p.specOut||p.hp<=0||p.roll>0) return false;
  if(!((keys.KeyE&&!(keys.PadX&&G.nearPad))||keys.PadSearch)) return false;
  // v28.xx (cw-cx-bothsearch): an occupied box still counts; G.searching is cleared when its other searcher owns it.
  for(i=0;i<(G.containers||[]).length;i++){
    ct=G.containers[i];
    if(!ct.opened&&!(ct.auto&&G.t-ct.dropT<8)&&Math.hypot(p.x-ct.x,p.y-ct.y)<46&&losClear(p.x,p.y,ct.x,ct.y,G.vseg)) return true;
  }
  return false;
}
function duoAt(ct,seat){
  if(!ct||!NET.on||!G||G.sim||!NET.upSeed||(G.seed>>>0)!==(NET.upSeed>>>0)) return false;
  if(seat===undefined) seat=NET.seat;
  var p=G.player, i, q, own=false, other=false;
  if(duoHolding()&&Math.hypot(p.x-ct.x,p.y-ct.y)<=DUO_R){ if(seat===NET.seat) own=true; else other=true; }
  for(i=0;i<(NET.up||[]).length;i++){
    q=NET.up[i];
    // v28.xx (cw-cx-bothsearch): missing shold from an older window means no held input; use the latest position, before visual easing.
    if(q&&q.shold===1&&!q.pz&&netUpShown(q)&&!netUpGone(q)&&!netUpHid(q)&&!q.dn&&!q.specOut&&!q.out&&q.hp>0&&Math.hypot((q.tx===undefined?q.x:q.tx)-ct.x,(q.ty===undefined?q.y:q.ty)-ct.y)<=DUO_R){ if(q.seat===seat) own=true; else other=true; }
  }
  return own&&other;
}
'@

SubRx @'
  if(up) g.xo=m.xo?1:0;   // v35.xx (cw-xsink): an extraction took him (the DEMO host out for the run); a word without it (an older window) reads as not out
'@ @'
  if(up) g.xo=m.xo?1:0;   // v35.xx (cw-xsink): an extraction took him (the DEMO host out for the run); a word without it (an older window) reads as not out
  if(up) g.shold=(m.shold===1)?1:0;   // v28.xx (cw-cx-bothsearch): search input, not a granted box or the busy-hands pose
'@

SubRx @'
    if(up&&g.xo) out.xo=1;   // v35.xx (cw-xsink): passed on as it came
'@ @'
    if(up&&g.xo) out.xo=1;   // v35.xx (cw-xsink): passed on as it came
    if(up) out.shold=g.shold;   // v28.xx (cw-cx-bothsearch): forward both press and release
'@

SubRx @'
  if(NET.upAcc<NET_HUB_STEP) return 0;
'@ @'
  // v28.xx (cw-cx-bothsearch): publish input edges on this frame, even between the regular position packets.
  var held=duoHolding()?1:0;
  if(NET.upAcc<NET_HUB_STEP&&(NET.upHold||0)===held) return 0;
  NET.upHold=held;
'@

SubRx @'
  NET.upAcc=Math.min(NET.upAcc-NET_HUB_STEP,NET_HUB_STEP);
'@ @'
  NET.upAcc=Math.max(0,Math.min(NET.upAcc-NET_HUB_STEP,NET_HUB_STEP));   // v28.xx (cw-cx-bothsearch): an input edge may send before the position clock is due
'@

SubRx @'
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0),dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0,sa:(!CFG.superhot||G.shAct)?1:0,hd:(G.handsT>0||p.hand)?1:0,xo:ascOut(p)?1:0};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate // v28.47 (cloud-coop-teammate-bare-hands), CLOUD HUNT 2026-10-15: hd, his hands are busy (a grenade or heal out, a search or a seal), so his teammate draws him without his gun as he sees himself
  if(NET.role==='host') msg.s=NET.seat;   // a friend names no seat: the host files him under the seat of his link
'@ @'
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0),dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0,sa:(!CFG.superhot||G.shAct)?1:0,hd:(G.handsT>0||p.hand)?1:0,xo:ascOut(p)?1:0};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate // v28.47 (cloud-coop-teammate-bare-hands), CLOUD HUNT 2026-10-15: hd, his hands are busy (a grenade or heal out, a search or a seal), so his teammate draws him without his gun as he sees himself
  if(NET.role==='host') msg.s=NET.seat;   // a friend names no seat: the host files him under the seat of his link
  msg.shold=held;   // v28.xx (cw-cx-bothsearch): one backward-safe bit for keyboard E or the pad search input
'@

SubRx @'
//   far or none; ONE SEARCHER PER BOX, so two players never double the search speed (numbers frozen). Every frame the host
'@ @'
//   far or none; ONE SEARCHER PER BOX owns the loot. v28.xx (cw-cx-bothsearch): both holding search nearby gives 1.5x, even at an occupied box.
'@

SubRx @'
function netContInit(g){
  var i, ct;
'@ @'
function netContInit(g){
  var i, ct;
  NET.upHold=0;   // v28.xx (cw-cx-bothsearch): a new raid starts with no previous held-input edge
'@

SubRx @'
var VER='35.95';
'@ @'
var VER='35.96';
'@

$pat = "(?m)^  now:'v35\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.96: Boxes search 1.5 times faster while both players hold search. Check 35.96 fails on v35.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
