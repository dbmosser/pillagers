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

# Rocket Launcher on key 0 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
noise:620,tint:'#d8b4ff'}
};
'@ @'
noise:620,tint:'#d8b4ff'},
  // v28.xx (cw-rocket), HIS ORDER (2026-10-18): "add a rocket launcher as '0'. It should take maybe 30 ammo per rocket and require a reload after 2 rockets". A slow rocket with a blast
  // (rkt:1): two in the tube, a long reload, 30 of the one universal ammo pool for each rocket loaded.
  rocket:{optic:2,id:'rocket',name:'Rocket Launcher',dmg:60,rof:700,spread:.012,mag:2,reload:3600,rng:900,auto:false,noise:700,tint:'#ffb070',rkt:1}
};
'@

SubRx @'
sniper:5,lance:5};
'@ @'
sniper:5,lance:5,rocket:5};
'@

SubRx @'
gun_lance:{name:'Meridian Lance (field)',val:4600,wt:6,r:'elite',c:'#d8b4ff',use:'gun',gk:'lance'},
'@ @'
gun_lance:{name:'Meridian Lance (field)',val:4600,wt:6,r:'elite',c:'#d8b4ff',use:'gun',gk:'lance'},
  gun_rocket:{name:'Rocket Launcher (field)',val:3800,wt:7,r:'elite',c:'#ffb070',use:'gun',gk:'rocket'},   // v28.xx (cw-rocket)
'@

SubRx @'
sniper:'sniper',lance:'energy'};
'@ @'
sniper:'sniper',lance:'energy',rocket:'rocket'};
'@

SubRx @'
energy:'gun_lance',rocket:'gun_lance'};
'@ @'
energy:'gun_lance',rocket:'gun_rocket'};
'@

SubRx @'
energy:'lance'}, GHOSTSPR
'@ @'
energy:'lance',rocket:'rocket'}, GHOSTSPR
'@

SubRx @'
lance:  {len:5000,lp:1200
'@ @'
rocket: {len:5200,lp:900,hp:70,g:.22,decay:1.8,body:{f0:70,f1:26,d:.2,g:.2,type:'sine'},tail:1},   // v28.xx (cw-rocket): a deep launch thump
      lance:  {len:5000,lp:1200
'@

SubRx @'
lance:  {add:0.60,rec:0.90,dly:0.20,cone:0.025},
'@ @'
rocket: {add:0.90,rec:0.70,dly:0.20,cone:0.020},
  lance:  {add:0.60,rec:0.90,dly:0.20,cone:0.025},
'@

SubRx @'
dmr:0.7,sniper:0.85,lmg:1.0,lance:1.0};
'@ @'
dmr:0.7,sniper:0.85,lmg:1.0,lance:1.0,rocket:1.0};
'@

SubRx @'
lmg:'lmg',dmr:'marksman',sniper:'marksman',lance:'lance'};
'@ @'
lmg:'lmg',dmr:'marksman',sniper:'marksman',lance:'lance',rocket:'rocket'};
'@

SubRx @'
R(32.8,-2.6,1.4,5.2,'d'), R(38,-2.1,1.6,4.2,'d'), R(6,-5.6,8,2.4,'d','H'), R(13.4,-5.3,0.7,1.8,'v','O')]};
'@ @'
R(32.8,-2.6,1.4,5.2,'d'), R(38,-2.1,1.6,4.2,'d'), R(6,-5.6,8,2.4,'d','H'), R(13.4,-5.3,0.7,1.8,'v','O')]};
  D.rocket={tip:41,by:0,grip:5.2,fg:20,well:[12,3],port:[10,-3],rv:[3,-3,13,6],br:[14,41],p:[   // v28.xx (cw-rocket): a shoulder tube with a flared muzzle and a rocket nose
    grip(5.2), P([-3,-2.6, 3,-2.4, 3,2.6, -3,3.6],'d','F'), R(3,-3,13,6,'l','FHR'), R(14,-4.2,24,8.4,'m','HR'), R(12,-4.6,1.6,9.2,'d'),
    R(24,-4.6,1.6,9.2,'d'), R(36,-5.4,5,10.8,'d','H'), R(38.4,-2.4,2.6,4.8,'r','O'), R(6,-7.4,8,2.4,'d','H'), R(13.4,-7.1,0.7,1.8,'g','O')]};
'@

SubRx @'
  } else {
    P([[-24,2],[-14,2],[-18,22],[-28,22]]); F(poly,2,22);
    R(-44,-14,52,20,5); F(darkHex(col,0.75),-14,6);
'@ @'
  } else if(fam==='rocket'){   // v28.xx (cw-rocket): a fat olive tube, a flared muzzle, the rocket nose in the rarity colour
    P([[-24,2],[-14,2],[-18,22],[-28,22]]); F(poly,2,22);
    R(-52,-18,100,24,10); F('#4d5a3e',-18,6);
    R(34,-22,14,32,3); F(metal,-22,10);
    R(-56,-20,8,28,3); F('#2c3037',-20,8);
    for(i=0;i<3;i++) line(-30+i*22,-17,-30+i*22,5,1.6,'rgba(0,0,0,.35)');
    P([[48,-12],[66,-5],[48,2]]); F(col,-12,2);
    R(-28,-28,30,8,3); F('#24272c',-28,-20); lens(-6,-24,3.2);
    guard(-14,0,6,9);
  } else {
    P([[-24,2],[-14,2],[-18,22],[-28,22]]); F(poly,2,22);
    R(-44,-14,52,20,5); F(darkHex(col,0.75),-14,6);
'@

SubRx @'
vx:Math.cos(ang)*1180,vy:Math.sin(ang)*1180,
'@ @'
vx:Math.cos(ang)*(wep.rkt?RKT_SPD:1180),vy:Math.sin(ang)*(wep.rkt?RKT_SPD:1180),
'@

SubRx @'
life:wep.rng/1180,player:
'@ @'
life:wep.rng/(wep.rkt?RKT_SPD:1180),player:
'@

SubRx @'
thru:(wep.id==='lance')?1:0,gid:
'@ @'
rkt:wep.rkt?1:0,_pen:wep.rkt?99:0,thru:(wep.id==='lance')?1:0,gid:
'@

SubRx @'
if(!G.sim&&!melee){
    // v8.35: brass is decoration
'@ @'
if(!G.sim&&!melee&&!wep.rkt){   // v28.xx (cw-rocket): a rocket tube throws no brass
    // v8.35: brass is decoration
'@

SubRx @'
if(hit||b.life<=0) G.bullets.splice(i,1);
'@ @'
if(hit||b.life<=0){ if(b.rkt&&b.player) rocketBlast(b); G.bullets.splice(i,1); }   // v28.xx (cw-rocket): a rocket goes off where it ends, on a body, a wall or the end of its range
'@

SubRx @'
var p=G.player,R=(CFG.fragR===undefined?190:CFG.fragR),i;
'@ @'
var p=G.player,R=f.R||(CFG.fragR===undefined?190:CFG.fragR),i;   // v28.xx (cw-rocket): a rocket blast brings its own radius
'@

SubRx @'
var _fName=_fMine?'YOUR OWN CHARGE':
'@ @'
var _fName=_fMine?(f.nm||'YOUR OWN CHARGE'):
'@

SubRx @'
wc.lineTo(b.x,b.y-12); wc.stroke();
    if(_trc>1){
'@ @'
wc.lineTo(b.x,b.y-12); wc.stroke();
    if(b.rkt){ wc.fillStyle='#fff3c8'; wc.beginPath(); wc.arc(b.x,b.y-12,4,0,6.2832); wc.fill(); }   // v28.xx (cw-rocket): the rocket has a hot head
    if(_trc>1){
'@

SubRx @'
wc.strokeStyle=b.tint; wc.lineWidth=(b.el||b.elw)?3:2;
'@ @'
wc.strokeStyle=b.tint; wc.lineWidth=b.rkt?5:((b.el||b.elw)?3:2);
'@

SubRx @'
var _gtl=9*_trc, _gtv;
'@ @'
var _gtl=(b.rkt?26:9)*_trc, _gtv;
'@

SubRx @'
function tickReload(dt){
'@ @'
// v28.xx (cw-rocket), HIS ORDER (2026-10-18): "30 ammo per rocket and require a reload after 2 rockets". The one universal pool (p.reserve) pays 30 for each rocket loaded;
// every other gun still pays one a round. rlRounds is what a reload would load, rlHave whether a reload can load anything, rsvShow the number the HUD shows beside the tube.
var RKT_SPD=460, RKT_AMMO=30, RKT_R=170;
function rktCost(w){ return (w&&w.rkt)?RKT_AMMO:1; }
function rlRounds(p){ var c=rktCost(p.wep), r=(c>1)?Math.floor((p.reserve||0)/c):(p.reserve||0); return Math.max(0,Math.min((p.wep.mag||0)-(p.ammo||0),r)); }
function rlHave(p){ var c=rktCost(p.wep); return c>1?Math.floor((p.reserve||0)/c)>0:p.reserve>0; }
function rsvShow(p){ var c=rktCost(p.wep); return c>1?Math.floor((p.reserve||0)/c):p.reserve; }
function rocketBlast(b){ explodeFrag({x:b.x,y:b.y,R:RKT_R,nm:'Your own rocket'}); }
function tickReload(dt){
'@

SubRx @'
var take=Math.min(p.wep.mag-p.ammo,p.reserve);
      // v22.73, the raid text rewrite (R28)
'@ @'
var take=rlRounds(p);   // v28.xx (cw-rocket)
      // v22.73, the raid text rewrite (R28)
'@

SubRx @'
p.ammo+=take; p.reserve-=take;
      // v25.xx (reloaddone)
'@ @'
p.ammo+=take; p.reserve-=take*rktCost(p.wep);   // v28.xx (cw-rocket): a rocket costs 30
      // v25.xx (reloaddone)
'@

SubRx @'
p.ammo<p.wep.mag&&p.reserve>0){ p.reloading=p.wep.reload*buzzSlow();
'@ @'
p.ammo<p.wep.mag&&rlHave(p)){ p.reloading=p.wep.reload*buzzSlow();
'@

SubRx @'
p.wep.mag>0&&p.ammo<=0&&p.reserve>0&&!p.downed
'@ @'
p.wep.mag>0&&p.ammo<=0&&rlHave(p)&&!p.downed
'@

SubRx @'
if(p.reserve>0&&p.reloading<=0&&CFG.autoRel!==0){
'@ @'
if(rlHave(p)&&p.reloading<=0&&CFG.autoRel!==0){
'@

SubRx @'
else if((p.reserve<=0||(CFG.autoRel===0&&p.reloading<=0))&&!p.dryTold)
'@ @'
else if((!rlHave(p)||(CFG.autoRel===0&&p.reloading<=0))&&!p.dryTold)
'@

SubRx @'
(p.reserve<=0?'dry':'empty')
'@ @'
(!rlHave(p)?'dry':'empty')
'@

SubRx @'
ctx.fillText(p.ammo+' / '+p.reserve,W-16,by-LH(14));
'@ @'
ctx.fillText(p.ammo+' / '+rsvShow(p),W-16,by-LH(14));
'@

SubRx @'
(p.ammo+' / '+p.reserve),x+PW-11,cy);
'@ @'
(p.ammo+' / '+rsvShow(p)),x+PW-11,cy);
'@

SubRx @'
pick(['gun_whisper','gun_lance']),'servo']);
'@ @'
pick(['gun_whisper','gun_lance','gun_rocket']),'servo']);
'@

SubRx @'
  ['gun_lance'],
  ['gun_whisper','plate'],
'@ @'
  ['gun_lance'],
  ['gun_rocket','plate','frag'],   // v28.xx (cw-rocket)
  ['gun_whisper','plate'],
'@

SubRx @'
var VER='29.17';
'@ @'
var VER='29.18';
'@

$pat = "(?m)^  now:'v29\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.18: New gun on key 0: the Rocket Launcher. Slow rocket, big blast, 2 to a load, 30 ammo a rocket. Found in the Pillbox wreck and the Wirt lot. Check 29.18 fails on v29.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
