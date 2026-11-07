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

# BANDAGE PICK-UPS AND SAVE MEDAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netRevNeed(){ return NET_REV_T*(1-wornM('revive')); }
'@ @'
function netRevNeed(){ return NET_REV_T*((G&&G.bag&&G.bag.indexOf('bandage')>=0)?0.5:1)*(1-wornM('revive')); } /* v28.xx (cw-cx-revive-save): g-58, A bandage makes it faster; keep the existing medic gear bonus. */
'@

SubRx @'
seg=((typeof NET_REV_T==='number'&&NET_REV_T>0)?NET_REV_T:3.2)/8
'@ @'
seg=netRevNeed()/8
'@

SubRx @'
  p.downT-=dt;   // cw-downgain: a hit on the downed bar gives time back at once (downBarTick); there is no slow bleed any more
'@ @'
  // v28.xx (cw-cx-revive-save): g-60, Yes, pause during a revive. A lost or stale word cannot hold the clock.
  var held=false, i, g;
  if(NET.on) for(i=0;i<NET.up.length;i++){
    g=NET.up[i];
    if(netUpShown(g)&&!netUpGone(g)&&!g.dn&&g.age>=0&&g.age<0.4&&g.rg===NET.seat&&Math.hypot(g.x-p.x,g.y-p.y)<=NET_REV_R*1.5){ held=true; break; }
  }
  if(!held) p.downT-=dt;
'@

SubRx @'
function sndDowned(mine,wx,wy){
'@ @'
// v28.xx (cw-cx-revive-save): g-62, Yes, a sharper alert. Six square notes, no voice, on the alarms-controlled sting bus.
function sndMateLate(){
  var a, out, t, i, o, og, at, mv=volOf('volAlarm');
  if(!(mv>0)||(G&&G.sim)||(typeof NET==='object'&&NET&&NET.specTick)) return false;
  a=ac(); if(!a) return false;
  out=sndBus('sting'); if(!out) return false;
  t=a.currentTime;
  try{
    for(i=0;i<6;i++){
      at=t+i*0.09; o=a.createOscillator(); og=a.createGain(); o.type='square';
      o.frequency.setValueAtTime(i%2?990:1320,at);
      og.gain.setValueAtTime(0.0001,at); og.gain.exponentialRampToValueAtTime(0.24*mv,at+0.008); og.gain.exponentialRampToValueAtTime(0.0001,at+0.08);
      o.connect(og); og.connect(out); o.start(at); o.stop(at+0.09);
    }
  }catch(_ml){ return false; }
  SND_DOWN.late=(SND_DOWN.late|0)+1;
  return true;
}
function sndDowned(mine,wx,wy){
'@

SubRx @'
var SND_DOWN={n:0,mine:0,mate:0,at:-1};
'@ @'
var SND_DOWN={n:0,mine:0,mate:0,late:0,at:-1}; /* v28.xx (cw-cx-revive-save): count the last-five-seconds alert. */
'@

SubRx @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.fk=(m.fk===1||m.fk===2)?m.fk:0; g.el=(g.fk===2&&typeof m.el==='string'&&ELEM[m.el])?m.el:''; g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.mf=(m.mf===1||m.mf===2)?m.mf:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); g.hd=m.hd?1:0; g.am=(typeof m.am==='number'&&isFinite(m.am))?Math.max(0,Math.min(999,m.am|0)):-1; g.rs=(typeof m.rs==='number'&&isFinite(m.rs))?Math.max(-1,Math.min(99999,m.rs|0)):0; }   // v28.xx (cw-partnergun): his rounds and reserve for the teammate row; a word without them (an older window) draws no gun line   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour // v28.47 (cloud-coop-teammate-bare-hands), CLOUD HUNT 2026-10-15: hd kept; a word without it (an older window) reads as empty hands
'@ @'
  // v28.xx (cw-cx-revive-save): one late warning per fall, before replacing the old down seconds.
  if(up){
    if(!m.dn) g.revLate=0;
    else if(g.dn&&g.dt>5&&(+m.dt)>0&&(+m.dt)<=5&&!g.revLate&&G&&!G.over&&!G.sim&&!NET.specTick&&g.sd===(G.seed>>>0)&&((+m.sd)>>>0)===(G.seed>>>0)){
      g.revLate=1; try{ sndMateLate(); }catch(_ml){} try{ padRumble(0.8,300); }catch(_mr){}
    }
    g.rg=(typeof m.rg==='number'&&m.rg===(m.rg|0)&&m.rg>=0&&m.rg<NET.max)?m.rg:-1;
  }
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.fk=(m.fk===1||m.fk===2)?m.fk:0; g.el=(g.fk===2&&typeof m.el==='string'&&ELEM[m.el])?m.el:''; g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.mf=(m.mf===1||m.mf===2)?m.mf:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); g.hd=m.hd?1:0; g.am=(typeof m.am==='number'&&isFinite(m.am))?Math.max(0,Math.min(999,m.am|0)):-1; g.rs=(typeof m.rs==='number'&&isFinite(m.rs))?Math.max(-1,Math.min(99999,m.rs|0)):0; }   // v28.xx (cw-partnergun): his rounds and reserve for the teammate row; a word without them (an older window) draws no gun line   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour // v28.47 (cloud-coop-teammate-bare-hands), CLOUD HUNT 2026-10-15: hd kept; a word without it (an older window) reads as empty hands
'@

SubRx @'
    if(up) out.shold=g.shold;
'@ @'
    if(up&&g.rg>=0) out.rg=g.rg; /* v28.xx (cw-cx-revive-save): relay who is being picked up. */
    if(up) out.shold=g.shold;
'@

SubRx @'
  msg.shold=held;
'@ @'
  if(G.netRevT>0&&G.netRevS>=0) msg.rg=G.netRevS; /* v28.xx (cw-cx-revive-save): omitted when the hold ends. */
  msg.shold=held;
'@

SubRx @'
  var s=-1, nm, w, g, rose;
'@ @'
  var s=-1, nm, w, g, rose, bi; /* v28.xx (cw-cx-revive-save): spend only after the partner stands up. */
'@

SubRx @'
      if(rose){ say(String(netSeatName(w)||'your teammate').toUpperCase()+' IS BACK UP','ally'); blip('pick'); try{ sndRevLand(); }catch(_rl){} }
'@ @'
      // v28.xx (cw-cx-revive-save): g-58 and g-66, pay only for a confirmed pick-up; a lost word costs nothing.
      if(rose){
        if(G.netRevBand&&G.bag){ bi=G.bag.indexOf('bandage'); if(bi>=0) G.bag.splice(bi,1); }
        if(!G.sim&&xf('xfStyle')&&netRevSaveRisk(p,G.netRevAt0)) styMedal('SAVE',150,p.x,p.y);
        say(String(netSeatName(w)||'your teammate').toUpperCase()+' IS BACK UP','ally'); blip('pick'); try{ sndRevLand(); }catch(_rl){}
      }
      G.netRevBand=0;
'@

SubRx @'
  if(G.netRevS!==s){ G.netRevS=s; G.netRevT=0; }
'@ @'
  if(G.netRevS!==s){ G.netRevS=s; G.netRevT=0; G.netRevAt0=G.t; } /* v28.xx (cw-cx-revive-save): remember the start of this hold. */
'@

SubRx @'
  if(NET.role==='host') netRevPass(s,NET.seat);
'@ @'
  G.netRevBand=(G.bag&&G.bag.indexOf('bandage')>=0)?1:0; /* v28.xx (cw-cx-revive-save): pending cost; nothing spent until the up word. */
  if(NET.role==='host') netRevPass(s,NET.seat);
'@

SubRx @'
function netRevHold(p,dt){
'@ @'
// v28.xx (cw-cx-revive-save): g-66, Yes, a save medal. Only incoming damage during this hold or a nearby active hostile qualifies.
function netRevSaveRisk(p,at){
  if(typeof at==='number'&&typeof p.hurtAt==='number'&&p.hurtAt>=at) return true;
  return (G.ents||[]).some(function(e){ return flowFoe(e)&&(e.state==='chase'||e.state==='alarm'||e.state==='hunt')&&Math.hypot(e.x-p.x,e.y-p.y)<=700; });
}
function netRevHold(p,dt){
'@

SubRx @'
'TEAM COMBO':2,'SCREEN CLEAR':3
'@ @'
'TEAM COMBO':2,'SAVE':2,'SCREEN CLEAR':3
'@

SubRx @'
  'TEAM COMBO':'M9 8a3 3 0 1 0 0 6a3 3 0 1 0 0-6zM17 9a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM3 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4'
'@ @'
  'TEAM COMBO':'M9 8a3 3 0 1 0 0 6a3 3 0 1 0 0-6zM17 9a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM3 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4',
  'SAVE':'M9 8a3 3 0 1 0 0 6a3 3 0 1 0 0-6zM17 9a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM3 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4'
'@

SubRx @'
var VER='37.50';
'@ @'
var VER='37.51';
'@

$pat = "(?m)^  now:'v37\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.51: A carried bandage halves the base pick-up hold and is spent only when the teammate stands up. Fresh nearby revive state pauses bleed time. One six-note alert per fall at five seconds. Confirmed risky saves award the tier-two save medal and 150 sp. Existing medic gear still applies. Check 37.51 fails on v37.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
