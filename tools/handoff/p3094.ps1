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

# mimic boxes are gone from the arcade and the career (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v26.xx (ai27), HIS YES (2026-10-14, suggestion 27): MIMIC CONTAINERS. Now and then (MIMIC_PM in a thousand) a crate or a locker is a
// MIMIC: a dormant crawler lies in it. Which ones are mimics is a pure function of where the box stands and the raid seed (isMimic: a
// hash, no random number drawn), so the raid builds exactly as before and the seeded stream and the container counts do not move. A
// mimic gives itself away to a careful player by a faint tick when you come within 130 of it; start to search it and, 0.8 seconds
// later, the crawler bursts out and goes for you (and, being a crawler, latches on). The box keeps its loot and is searched as normal
// afterward. A box wakes once. The bot sim never wakes one. Its crawler is made on the cosmetic stream (fxBorrow), so no seeded draw moves.
var MIMIC_PM=20;
function isMimic(ct){
  var h;
  if(!ct||typeof G==='undefined'||!G||CFG.mimic===0) return false;
  if(ct.type!=='crate'&&ct.type!=='locker') return false;
  if(ct.dropped||ct.mercSrc||ct.cache||ct.mimicDone) return false;
  h=((Math.round(ct.x)*73856093)^(Math.round(ct.y)*19349663)^(((G.seed|0)+1)*83492791))>>>0;
  h=Math.imul(h^(h>>>15),2246822507)>>>0; h=(h^(h>>>13))>>>0;
  return (h%1000)<MIMIC_PM;
}
function mimicWake(ct){
  var c=null, p=G.player, by=(typeof NET==='object'&&NET.on&&NET.role==='host')?((ct.mimicBy>0)?(ct.mimicBy|0):((ct.netBy>0)?(ct.netBy|0):0)):0, i, q, a, x, y;   // v28.xx (cw-mimicseen), CLOUD HUNT 2026-10-15: a box player 2 opened through the host wakes on him
  if(by&&NET.up) for(i=0;i<NET.up.length;i++){ q=NET.up[i]; if(q&&q.seat===by&&netUpShown(q)){ p=netUpBody(q); break; } }
  // v28.xx (cw-mimicaway), HIS ORDER (2026-10-15): "MIMIC crawler from a looting box: pops out AWAY from the player, so he can kill it without
  // taking damage; has a different name, so he knows where it came from". It came out on the player's side of the box (26 toward him) and bit
  // at once. It now comes out 34 on the far side of the box (then the nearest free side), is named MIMIC, and holds its first bite for a second.
  a=p?Math.atan2(p.y-ct.y,p.x-ct.x):0; var _mo=[3.1416,2.3416,3.9416,1.5416,4.7416], _mf=false, _mi;
  for(_mi=0;_mi<_mo.length&&!_mf;_mi++){ x=ct.x+Math.cos(a+_mo[_mi])*34; y=ct.y+Math.sin(a+_mo[_mi])*34; if(spotFree(G.map,x,y,12)) _mf=true; }
  if(!_mf){ x=ct.x; y=ct.y; }
  fxBorrow(function(){ c=mkCrawler(x,y); c.name=mkName('MIMIC',['M','X','V']); });
  c.mimic=1; c.state='chase'; c.alert=3; c.tx=p?p.x:x; c.ty=p?p.y:y; c.cd=1.0;
  G.ents.push(c);
  ct.mimicDone=1; ct.mimicWake=0;
  // v28.xx (cw-mimicaway), HIS ORDER (2026-10-15): "the box gets a unique disappear-into-the-void swirl animation". The box was only a box the crawler
  // came out of. It is spent now (no loot, not searchable) and spins away into a violet swirl for 1.5 s, then is gone.
  ct.opened=true; ct.loot=[]; ct.prog=0; ct.pulled=0; if(!G.sim) ct.mimicVoid=1.5;
  if(!G.sim){ spark(ct.x,ct.y,'#ff5a40',16,260); if(!by){ G.shake=Math.max(G.shake||0,4); say('MIMIC','warn'); } sfx('alarm',ct.x,ct.y,'crawler'); }   // v28.xx (cw-mimicseen), CLOUD HUNT 2026-10-15: the line and shake go to the player who opened it
  if(by&&!G.sim) netMarkSend({t:'mark',k:'mimic',seat:by,x:Math.round(ct.x),y:Math.round(ct.y)});
  return c;
}
function mimicTick(dt){
  var i, ct, p=G&&G.player;
  if(!G||G.over||G.sim||!G.containers) return;
  for(i=0;i<G.containers.length;i++){
    ct=G.containers[i];
    if(ct.mimicVoid>0) ct.mimicVoid-=dt;   // v28.xx (cw-mimicaway): the void swirl timer
    if(ct.mimicDone||ct.opened) continue;
    if(ct.mim===undefined) ct.mim=isMimic(ct)?1:0;
    if(!ct.mim) continue;
    if(!ct.mimicWake&&(ct.prog||0)>0){ ct.mimicWake=1; ct.mimicT=0.8; ct.mimicBy=(typeof ct.netBy==='number'&&ct.netBy>0)?ct.netBy:0; }   // v28.xx (cw-mimicseen), CLOUD HUNT 2026-10-15: remember which of the party opened it
    if(ct.mimicWake){ ct.mimicT-=dt; if(ct.mimicT<=0) mimicWake(ct); continue; }
    if(p&&!p.downed&&dist(p,ct)<130){
      ct.tkT=(ct.tkT===undefined?fxn(0.4,1.2):ct.tkT)-dt;
      if(ct.tkT<=0){ ct.tkT=fxn(2.0,3.2); if(typeof foley==='function') foley('pinClick',ct.x,ct.y,{g:0.22,rate:1.5}); }
    }
  }
}

'@ @'
// v28.xx (cw-nomimic), HIS NOTE (2026-10-18, in a raid at 2:12, build 30.73): "get rid of the mimics, its just too confusing". MIMIC CONTAINERS (v26.77, his
// yes of 2026-10-14) are gone from the arcade and the career: no crate or locker hides a crawler, nothing ticks as you walk up to a box, no MIMIC line, no
// alarm, no void swirl. isMimic, mimicWake and mimicTick went with them. isMimic drew no random number (it was a hash of the box position and the raid
// seed, and the crawler was made on the cosmetic stream), so the seeded stream, the entity counts and the container counts do not move. CFG.mimic was
// never a settings row and never a profile key (applyCfg keeps only the keys DEF has), so an old save that had it on loads back as off by itself.

'@

SubRx @'
  try{ mimicTick(dt); }catch(_mt){}   // v26.xx (ai27): a mimic crate wakes when searched
  for(var _rs=0;_rs<G.containers.length;_rs++){
'@ @'
  for(var _rs=0;_rs<G.containers.length;_rs++){
'@

SubRx @'
// v28.xx (cw-mimicaway), HIS ORDER (2026-10-15): "the box gets a unique disappear-into-the-void swirl animation". The spent mimic box shrinks and
// spins into a dark hole ringed by four violet spiral arms, over 1.5 s, and is gone. Pure function of the timer: no random draw.
function drawMimicVoid(ct){
  var t=1-Math.max(0,ct.mimicVoid)/1.5, s=Math.max(0.03,1-t*t*0.97), k, j, a, r, o=ct.opened, fade=Math.min(1,t*5)*(1-Math.max(0,t-0.8)*5);
  wc.save();
  wc.globalAlpha=0.9*fade; wc.fillStyle='#08001a'; wc.beginPath(); wc.ellipse(ct.x,ct.y+2,26*(0.4+0.6*fade),13*(0.4+0.6*fade),0,0,6.2832); wc.fill();
  wc.restore();
  wc.save(); wc.translate(ct.x,ct.y); wc.rotate(t*7); wc.scale(s,s); wc.translate(-ct.x,-ct.y);
  ct.opened=false; ct.mimicVoidIn=1;
  try{ drawContS(ct); } finally { ct.opened=o; ct.mimicVoidIn=0; }
  wc.restore();
  wc.save();
  for(k=0;k<4;k++) for(j=0;j<9;j++){
    r=(8+j*3.4)*(1-t*0.5); a=k*1.5708+j*0.55+t*10;
    wc.globalAlpha=Math.max(0,fade)*(1-j*0.07); wc.fillStyle=(j%2)?'#c58cff':'#5a1aa0';
    wc.beginPath(); wc.arc(ct.x+Math.cos(a)*r,ct.y+2+Math.sin(a)*r*0.55,Math.max(0.6,2.8-j*0.2),0,6.2832); wc.fill();
  }
  wc.restore();
}

'@ @'
// v28.xx (cw-nomimic): drawMimicVoid, the swirl a spent mimic box spun away in, is gone with the mimics.

'@

SubRx @'
  if(ct.mimicVoid!==undefined&&!ct.mimicVoidIn){ if(ct.mimicVoid>0) drawMimicVoid(ct); return; }   // v28.xx (cw-mimicaway): a spent mimic box is only its swirl, then nothing
  var cL;
'@ @'
  var cL;
'@

SubRx @'
  if(k==='mimic'){ if(!G.sim){ if(isFinite(+m.x)&&isFinite(+m.y)) spark(+m.x,+m.y,'#ff5a40',16,260); if(mine){ G.shake=Math.max(G.shake||0,4); say('MIMIC','warn'); } } return 'mark:mimic'; }   // v28.xx (cw-mimicseen), CLOUD HUNT 2026-10-15: player 2 sees the spark and, when he opened it, the same shake and line the host gets for his own
  if(k==='pill'){ if(mine&&!G.sim) say('THE PILLBOX HAS SEEN YOU','warn'); return 'mark:pill'; }
'@ @'
  if(k==='pill'){ if(mine&&!G.sim) say('THE PILLBOX HAS SEEN YOU','warn'); return 'mark:pill'; }
'@

SubRx @'
the crawler shout, a mimic, a noisy
'@ @'
the crawler shout, a noisy
'@

SubRx @'
var VER='30.93';
'@ @'
var VER='30.94';
'@

$pat = "(?m)^  now:'v30\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.94: Mimic boxes are gone: no crate or locker hides a crawler, nothing ticks near a box, no MIMIC line. Check 30.94 fails on v30.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
