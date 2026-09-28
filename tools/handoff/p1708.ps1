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

# A BANDAGE OR MEDKIT GIVEN TO A TEAMMATE WHO IS ALREADY HEALING IS NO LONGER WASTED: IT COMES BACK TO YOUR BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(m.t==='aid') return netAidTake(peer,m);   // v16.23: a teammate used his bandage or plate on this player, or (on the host) passes it on
'@ @'
  if(m.t==='aid') return netAidTake(peer,m);   // v16.23: a teammate used his bandage or plate on this player, or (on the host) passes it on
  if(m.t==='aidx') return netAidBackTake(peer,m);   // v17.08, co-op hunt 2026-09-28: a teammate window could not use the bandage or plate this player sent, so it comes back
'@

SubRx @'
  else if(it.use==='heal'){ applyHeal(key); say(nm+' patched you up.'); }
'@ @'
  else if(it.use==='heal'){
    // v17.08, co-op hunt 2026-09-28: a heal from a teammate was poured into the heal already running here, which keeps its own
    // ceiling, so while his own Bandage was winding up or running to 85 the teammate Bandage gave nothing and was gone. What is
    // already on its way (netAidReach) is now tested against this item ceiling, as every self heal is, and an item that cannot
    // raise him goes back to the teammate who sent it (netAidBack) instead of being spent.
    if(netAidReach(p)>=healCeil(it)){ netAidBack(by,key,'full'); return 'full'; }
    applyHeal(key); say(nm+' patched you up.');
  }
'@

SubRx @'
  return 'aid';
}
'@ @'
  return 'aid';
}
// v17.08, co-op hunt 2026-09-28: HOW HIGH THE HEALS ALREADY ON THEIR WAY WILL TAKE HIM. The running heal (healReach), raised by
// a heal of his own still winding up (p.prep: spent at the press, it lands on top of anything a teammate adds). A teammate heal
// that cannot take him past this is refused on his window, where the numbers are live, not on the healer copy of his health.
function netAidReach(p){
  var r=healReach(p), pk=(p.prep&&p.prep.kind==='heal'&&typeof p.prep.aid!=='number')?ITEMS[p.prep.key]:null;
  if(pk) r=Math.max(r,Math.min(healCeil(pk),r+healAmt(pk)));
  return r;
}
// v17.08, co-op hunt 2026-09-28: A HEAL OR PLATE HIS WINDOW COULD NOT USE GOES BACK TO THE TEAMMATE WHO SPENT IT ({t:'aidx'}),
// routed as the aid word came: a friend sends it to the host, and the host takes it himself or passes it to the seat by. The
// healer window puts it back in his backpack with a line (netAidKept). Returns what it did, so a check can read the answer.
function netAidBack(by,key,why){
  var i, w={t:'aidx',s:by,f:NET.seat,k:key,w:why};
  if(NET.role==='host'){
    if(by===NET.seat) return netAidKept(NET.seat,key,why);
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===by) return netSend(NET.peers[i],w)?'passed':'lost';
    return 'nobody';
  }
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],w);
  return 'sent';
}
function netAidBackTake(peer,m){
  var i, k;
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad';
  k=netClean(m.k,24);
  if(NET.role==='host'){
    if(m.s===NET.seat) return netAidKept(peer.seat,k,m.w);
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===m.s) return netSend(NET.peers[i],{t:'aidx',s:m.s,f:peer.seat,k:k,w:netClean(m.w,8)})?'passed':'lost';
    return 'nobody';
  }
  if(NET.role==='join'){ if(m.s!==NET.seat) return 'ignored'; return netAidKept((typeof m.f==='number')?(m.f|0):0,k,m.w); }
  return 'off';
}
function netAidKept(from,key,why){
  var it=ITEMS[key], nm=netSeatName(from)||'Your teammate';
  if(!it||(it.use!=='heal'&&it.use!=='armor')) return 'bad';
  if(typeof G==='undefined'||!G||G.over||G.sim||!G.player||!G.bag) return 'no raid';
  G.bag.push(key);
  say(nm+((why==='full')?' is already healing. ':' could not take it. ')+it.name+' kept.'); blip('pick');
  return 'kept';
}
'@

SubRx @'
var VER='17.07';
'@ @'
var VER='17.08';
'@

$pat = "(?m)^  now:'v17\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.08: Aid items, co-op hunt 2026-09-28: netAidStart refused a teammate heal only when his health from the state word had reached the item ceiling, and the state word carries neither the running heal (healQ, healReach) nor a heal of his own still winding up (p.prep). On his window netAidApply then called applyHeal, which adds to the running heal under the same ceiling, so the drain stopped at 85 and threw the teammate Bandage away (a Medkit over his own Medkit the same at 100). Every self heal tests healReach for this, the aid path never did. netAidApply now reads netAidReach (healReach, raised by a heal of his own in p.prep) and, when that already reaches the item ceiling, does not apply it and sends a new word {t:aidx} back to the healer, routed as the aid word came (a friend to the host, the host to the seat that sent it). netAidBackTake passes it on or takes it, and netAidKept puts the item back in the backpack of the healer with the line NAME is already healing. ITEM kept. A heal that can still raise him is applied as before. No number moved. Check 17.08 fails on v17.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
