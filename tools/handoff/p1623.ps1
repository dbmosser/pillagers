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

# USE YOUR BANDAGES AND PLATES ON A TEAMMATE. His note of 2026-09-27.

SubRx @'
    if(ix<0&&!(ait.use==='gun')){ say('No '+ait.name+' left.'); return; }
'@ @'
    if(ix<0&&!(ait.use==='gun')){ say('No '+ait.name+' left.'); return; }
    if((ait.use==='heal'||ait.use==='armor')&&NET.on){ var _aidS=netAidTarget(G.player); if(_aidS>=0){ netAidStart(_aidS,s2.itemKey); return; } }   // v16.23: facing a teammate beside you, it goes to him
'@

SubRx @'
  var PR=p[slot]; p[slot]=null;
'@ @'
  var PR=p[slot]; p[slot]=null;
  if(typeof PR.aid==='number'){ netAidFinish(PR); return; }   // v16.23: a bandage or plate for a teammate
'@

SubRx @'
       c:(G.pCrouch||crouchHeld())?1:0,sp:G.sprinting?1:0,dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):'',pz:G.paused?1:0};   // v16.20: pz, this player is paused
'@ @'
       c:(G.pCrouch||crouchHeld())?1:0,sp:G.sprinting?1:0,dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):'',pz:G.paused?1:0,
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0)};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate
'@

SubRx @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused
'@ @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@

SubRx @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; }   // v15.79: passed on as it came
'@ @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; out.hp=g.hp; out.mh=g.mh; out.ar=g.ar; out.ac=g.ac; }   // v15.79: passed on as it came
'@

SubRx @'
  if(m.t==='rev') return netRevTake(peer,m);   // v16.05: a teammate picked this player up, or (on the host) passes it on
'@ @'
  if(m.t==='rev') return netRevTake(peer,m);   // v16.05: a teammate picked this player up, or (on the host) passes it on
  if(m.t==='aid') return netAidTake(peer,m);   // v16.23: a teammate used his bandage or plate on this player, or (on the host) passes it on
'@

SubRx @'
function netAllPaused(){
'@ @'
// v16.23, HIS NOTE: HE SHOULD BE ABLE TO APPLY HIS OWN BANDAGES AND ARMOUR TO THE OTHER PLAYER STANDING NEXT TO HIM. Using a heal or an
// armour plate from the tactical belt while a teammate up top on the party seed stands within NET_REV_R and you face him (within
// 0.8 of a radian) gives it to him instead of you: it comes out of your backpack, takes the same wind-up it takes on you (startPrep),
// and when that finishes it goes to him through the host ({t:'aid'}); his window applies it by his own rules (applyHeal, which
// stops a Bandage at 85; a plate up to his armour cap). His health and armour ride in his state word, so a teammate who does not
// need it is told so and nothing is spent; if he has walked off by the end, the item comes back to your backpack. No new number.
function netAidTarget(p){
  var i, g, d, a, best=-1, bd=NET_REV_R+1;
  if(!p||p.downed||!netUpShared()) return -1;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)||g.dn) continue;
    d=Math.hypot(g.x-p.x,g.y-p.y); if(d>NET_REV_R) continue;
    a=Math.atan2(g.y-p.y,g.x-p.x)-(p.face||0); a=Math.atan2(Math.sin(a),Math.cos(a));
    if(Math.abs(a)<=0.8&&d<bd){ bd=d; best=g.seat; }
  }
  return best;
}
function netAidStart(s,key){
  var p=G.player, it=ITEMS[key], g=NET.up[s], nm=netSeatName(s)||'your teammate', bi, arm, ceil;
  if(!it||!g) return false;
  arm=(it.use==='armor');
  if(arm){ if(g.ac>0&&g.ar>=g.ac){ say('Armour on '+nm+' is full.'); return false; } if(p.prepA){ say('Already slotting a plate.'); return false; } }
  else { ceil=it.capHp?Math.min(g.mh||100,it.capHp):(g.mh||100); if(g.hp>=ceil){ say(nm+' does not need a '+it.name+'.'); return false; } if(p.prep){ say('Already applying '+(ITEMS[p.prep.key]?ITEMS[p.prep.key].name:'something')+'.'); return false; } }
  bi=G.bag.indexOf(key); if(bi<0){ say('No '+it.name+' left.'); return false; }
  G.bag.splice(bi,1);
  startPrep(arm?'armor':'heal',key);
  p[arm?'prepA':'prep'].aid=s;
  say((arm?'Slotting a plate for ':'Bandaging ')+nm+'.'); blip('pick');
  return true;
}
function netAidFinish(PR){
  var p=G.player, s=PR.aid, g=NET.up[s], nm=netSeatName(s)||'your teammate', it=ITEMS[PR.key], i;
  if(!g||!netUpShown(g)||g.dn||Math.hypot(g.x-p.x,g.y-p.y)>NET_REV_R*1.5){ G.bag.push(PR.key); say(nm+' moved away. '+(it?it.name:'It')+' kept.'); return false; }
  if(NET.role==='host') netAidPass(s,NET.seat,PR.key);
  else for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'aid',s:s,k:PR.key});
  say((it&&it.use==='armor')?('Plate slotted for '+nm+'.'):('Patched up '+nm+'.')); blip('pick');
  return true;
}
function netAidPass(s,by,key){
  var i;
  if(s===NET.seat) return netAidApply(by,key);
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===s) return netSend(NET.peers[i],{t:'aid',s:s,by:by,k:key})?'passed':'lost';
  return 'nobody';
}
function netAidTake(peer,m){
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad';
  if(NET.role==='host') return netAidPass(m.s,peer.seat,netClean(m.k,24));
  if(NET.role==='join'){ if(m.s!==NET.seat) return 'ignored'; return netAidApply((typeof m.by==='number')?(m.by|0):0,netClean(m.k,24)); }
  return 'off';
}
function netAidApply(by,key){
  var p, it=ITEMS[key], nm=netSeatName(by)||'Your teammate';
  if(typeof G==='undefined'||!G||G.over||G.sim||!G.player||!it) return 'no raid';
  p=G.player; if(p.downed) return 'down';
  if(it.use==='armor'){ p.armor=Math.min(armorCap(),(p.armor||0)+(it.amt||0)); say(nm+' slotted a plate for you. Armour '+Math.round(p.armor)+'.'); }
  else if(it.use==='heal'){ applyHeal(key); say(nm+' patched you up.'); }
  else return 'bad';
  blip('pick');
  return 'aid';
}
function netAllPaused(){
'@

SubRx @'
var VER='16.22';
'@ @'
var VER='16.23';
'@

$pat = "(?m)^  now:'v16\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.23: USE YOUR BANDAGES AND PLATES ON A TEAMMATE. His note. Using a heal or an armour plate from your tactical belt while you face a teammate standing next to you gives it to him: it comes out of your backpack, takes the same time, and heals him by his own rules (a Bandage stops at 85). A teammate who does not need it is told so and nothing is spent. No number moved. Check 16.23 fails on v16.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
