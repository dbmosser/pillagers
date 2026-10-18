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

# THE MARKSMAN RIFLE AND THE WHISPER ARE GONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
dmr:{optic:3,id:'dmr',name:'Marksman Rifle',dmg:64,rof:680,spread:.016,mag:8,reload:2300,rng:760,auto:false,noise:520,tint:'#fff0c0'},
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally". The Marksman Rifle is gone from the game.
'@

SubRx @'
whisper:{id:'whisper',name:'Whisper',dmg:24,rof:400,spread:.048,mag:30,reload:2100,rng:430,auto:true,noise:90,tint:'#a8d8c0'},
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally". The Whisper is gone from the game.
'@

SubRx @'
lmg:4,dmr:4,whisper:4,sniper:5,
'@ @'
lmg:4,sniper:5,
'@

SubRx @'
gun_dmr:{name:'Marksman Rifle (field)',val:2000,wt:5,r:'rare',c:'#fff0c0',use:'gun',gk:'dmr'},
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally". gun_dmr is gone; a saved one pays 2000 (gunsGoneSweep).
'@

SubRx @'
gun_whisper:{name:'Whisper (field)',val:3400,wt:4,r:'elite',c:'#a8d8c0',use:'gun',gk:'whisper'},
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally". gun_whisper is gone; a saved one pays 3400 (gunsGoneSweep).
'@

SubRx @'
['gun_dmr',1],['plate',1],['gun_sniper',1]
'@ @'
['gun_carbine',1],['plate',1],['gun_sniper',1]
'@

SubRx @'
['KEY',4],['gun_whisper',1],['comp',1]
'@ @'
['KEY',4],['gun_magnum',1],['comp',1]
'@

SubRx @'
['gun_lance',3.5],['codex',3.5],['gun_whisper',3.5],['bloom',3.5]
'@ @'
['gun_lance',3.5],['codex',3.5],['gun_rocket',3.5],['bloom',3.5]
'@

SubRx @'
['gun_dmr',4],['titan',4]
'@ @'
['gun_shotgun',4],['titan',4]
'@

SubRx @'
['gun_whisper',2],['relay',2]
'@ @'
['gun_magnum',2],['relay',2]
'@

SubRx @'
{kind:'wep',k:'dmr'},
'@ @'
{kind:'wep',k:'magnum'},
'@

SubRx @'
dmr:    {len:4200,lp:1400,hp:120,g:.20,decay:2.6,body:{f0:120,f1:45,d:.10,g:.14,type:'sine'},bolt:1},
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally".
'@

SubRx @'
// The Whisper is a cough, not a crack: short, heavily filtered, quiet.
      whisper:{len:900,lp:900,hp:200,g:.07,decay:4.2,body:{f0:140,f1:90,d:.05,g:.03,type:'sine'}},
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally".
'@

SubRx @'
var _pool=[['dmr',26],['lmg',24],['magnum',20],['whisper',14],['sniper',11],['lance',5]];
'@ @'
var _pool=[['rifle',26],['lmg',24],['magnum',20],['carbine',14],['sniper',11],['lance',5]];   // v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally": the Auto Rifle and the Burst Carbine take the two rows
'@

SubRx @'
var _t=0,_acc=0,_gk='dmr',_i,_gf=0.99;
'@ @'
var _t=0,_acc=0,_gk='rifle',_i,_gf=0.99;
'@

SubRx @'
var PED_GUNS=['gun_smg','gun_carbine','gun_shotgun','gun_rifle','gun_lmg','gun_dmr'];
'@ @'
var PED_GUNS=['gun_smg','gun_carbine','gun_shotgun','gun_rifle','gun_lmg','gun_sniper'];   // v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally": the Longshot takes the last stall slot
'@

SubRx @'
pick(['wcore','reactor','bloom','gun_dmr','gun_lmg'])
'@ @'
pick(['wcore','reactor','bloom','gun_rifle','gun_lmg'])
'@

SubRx @'
g.player.wep=rollFieldGun('dmr');
'@ @'
g.player.wep=rollFieldGun('rifle');
'@

SubRx @'
dmr:    {add:0.70,rec:0.95,dly:0.15,cone:0.035},
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally".
'@

SubRx @'
whisper:{add:0.40,rec:1.10,dly:0.10,cone:0.040},
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally".
'@

SubRx @'
id==='rifle'||id==='carbine'||id==='dmr'){
'@ @'
id==='rifle'||id==='carbine'){
'@

SubRx @'
{rate:id==='dmr'?0.92:1}
'@ @'
{rate:1}
'@

SubRx @'
{rate:id==='dmr'?0.85:0.92}
'@ @'
{rate:0.92}
'@

SubRx @'
{rate:id==='dmr'?0.82:1}
'@ @'
{rate:1}
'@

SubRx @'
else if(id==='smg'||id==='whisper'){
'@ @'
else if(id==='smg'){
'@

SubRx @'
if(RLFX.w&&gunBase(RLFX.w.id)==='whisper') o.g=(o.g===undefined?1:o.g)*0.7;   // the quiet gun reloads quietly
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally": the quiet gun is gone.
'@

SubRx @'
if(w==='dmr'||w==='sniper'||w==='whisper'||w==='lance'||w==='magnum') return 'mark';
'@ @'
if(w==='sniper'||w==='lance'||w==='magnum') return 'mark';
'@

SubRx @'
smg:1,whisper:1,fists:1
'@ @'
smg:1,fists:1
'@

SubRx @'
smg:0.4,whisper:0.45,carbine:0.5
'@ @'
smg:0.4,carbine:0.5
'@

SubRx @'
shotgun:0.6,dmr:0.7,sniper:0.85
'@ @'
shotgun:0.6,sniper:0.85
'@

SubRx @'
pick(['gun_whisper','gun_lance','gun_rocket'])
'@ @'
pick(['gun_sniper','gun_lance','gun_rocket'])
'@

SubRx @'
{sp:598500, kind:'wep', v:'dmr', label:'THE DMR'},
'@ @'
{sp:598500, kind:'wep', v:'rifle', label:'The auto rifle'},
'@

SubRx @'
{sp:874700, kind:'wep', v:'whisper', label:'THE WHISPER'},
'@ @'
{sp:874700, kind:'wep', v:'carbine', label:'The burst carbine'},
'@

SubRx @'
{sp:1013800, kind:'wep', v:'whisper', label:'BACKUP WHISPER'},
'@ @'
{sp:1013800, kind:'wep', v:'shotgun', label:'The scattergun'},
'@

SubRx @'
D.whisper={tip:29.4,by:0,grip:5,fg:16,well:[10.7,2.4],port:[9,-2.4],rv:[2.8,-2.4,11,4.8],br:[18.4,29.4],p:[
    grip(5), R(9.5,2.4,2.4,5.4,'l','H'), P([-3,-2, 2.8,-1.6, 2.8,1.8, -3,2.8],'d','F'), P([-1.8,-0.6, 1.4,-0.5, 1.4,0.7, -1.8,1.4],'k','O'),
    R(2.8,-2.4,11,4.8,'m','FHR'), R(13.8,-1.6,4.6,3.2,'d'), R(18.4,-2.2,11,4.4,'d','HR'), R(21.5,-2.2,0.6,4.4,'k','OV'),
    R(25,-2.2,0.6,4.4,'k','OV')]};
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally": the Whisper drawing is gone.
'@

SubRx @'
D.dmr={tip:35.6,by:0,grip:5.2,fg:20,well:[12.1,2.7],port:[10,-2.7],rv:[3,-2.7,13,5.4],br:[16,35.6],p:[
    grip(5.2), R(10.5,2.7,3.2,4.6,'l','H'), P([-3,-2.6, 3,-2.2, 3,2.4, -3,3.6],'d','F'), R(-2.4,-3.6,4,1.2,'l'), R(3,-2.7,13,5.4,'m','FHR'),
    R(16,-2.1,10,3.8,'l','FHR'), R(26,-0.9,7,1.8,'m','H'), R(33,-1.7,2.6,3.4,'d'), R(34,-1.7,0.6,3.4,'k','O'),
    R(7,-3.4,1,0.8,'d','O'), R(12.5,-3.4,1,0.8,'d','O'), R(4.5,-6.4,11,3,'d','H'), R(3.8,-6.8,1.4,3.8,'d'), R(14.6,-6.9,1.8,4,'d'),
    R(16,-6.6,0.7,3.4,'g','O')]};
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally": the Marksman Rifle drawing is gone.
'@

SubRx @'
else if(_wid==='whisper'){ _L=11; _B=2; _tube=1; _mag=1; }
  else if(_wid==='dmr'){ _L=15; _B=7; _sc=1; _mag=1; }
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally": no Whisper or Marksman Rifle body.
'@

SubRx @'
carbine:'rifle',rifle:'rifle',whisper:'rifle',
'@ @'
carbine:'rifle',rifle:'rifle',
'@

SubRx @'
lmg:'lmg',dmr:'marksman',sniper:'marksman'
'@ @'
lmg:'lmg',sniper:'marksman'
'@

SubRx @'
var can=(gunBase(id)==='whisper');
    P([[-52,-12]
'@ @'
var can=false;   // v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally": no suppressed gun
    P([[-52,-12]
'@

SubRx @'
var can=(gunBase(id)==='whisper');
    part(-20,-5,9,9,dk,'stock');
'@ @'
var can=false;   // v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally": no suppressed gun
    part(-20,-5,9,9,dk,'stock');
'@

SubRx @'
['gun_whisper','plate'],
  ['gun_sniper','plate'],
  ['gun_dmr','plate','medkit'],
'@ @'
['gun_sniper','plate'],
'@

SubRx @'
['gun_lmg',1],['gun_dmr',1],
'@ @'
['gun_lmg',1],['gun_magnum',1],
'@

SubRx @'
'gun_dmr','gun_rifle','gun_shotgun','core','comp'
'@ @'
'gun_carbine','gun_rifle','gun_shotgun','core','comp'
'@

SubRx @'
ARCADE_GUNS2=['magnum','dmr','shotgun','rifle','smg','carbine'];
'@ @'
ARCADE_GUNS2=['magnum','lmg','shotgun','rifle','smg','carbine'];
'@

SubRx @'
ARCADE_VAULT_GUNS=['gun_lance','gun_whisper','gun_sniper'];
'@ @'
ARCADE_VAULT_GUNS=['gun_lance','gun_rocket','gun_sniper'];
'@

SubRx @'
function applyLoadedProfile(r){
'@ @'
// v28.xx (cw-gunsgone), HIS ORDER (2026-10-18): "get rid of marksman rifle and whisper totally". A saved Marksman Rifle or Whisper (and
// its blue or gold twin) turns into credits at the field value (2000 and 3400; a twin 1.5 times), once, on load. Anything else that
// names one (the packed kit, the belt plans, the forge record, the wear record, a dropped gun) just loses the name, so nothing
// reads a gun the item table no longer has.
var GUNS_GONE={dmr:2000,whisper:3400};
function goneGunVal(k){ var m=/^(?:gun_)?(dmr|whisper)(_v)?$/.exec(String(k)); return m?Math.round(GUNS_GONE[m[1]]*(m[2]?1.5:1)):0; }
function gunsGoneSweep(p){
  var paid=0, i, k, h, L, fn=function(x){ return !goneGunVal(x); }, hs;
  if(!p||typeof p!=='object') return 0;
  ['stash','weapons'].forEach(function(f){ if(Array.isArray(p[f])) p[f]=p[f].filter(function(x){ var v=goneGunVal(x); paid+=v; return !v; }); });
  ['kit','dropKit','gunBeforeFree','kitBeforeFree'].forEach(function(f){ if(Array.isArray(p[f])) p[f]=p[f].filter(fn); });
  if(p.kitSaved&&typeof p.kitSaved==='object'&&Array.isArray(p.kitSaved.kit)) p.kitSaved.kit=p.kitSaved.kit.filter(fn);
  hs=[p.hotAssign, p.hotBeforeFree, p.kitSaved&&p.kitSaved.hot];
  for(i=0;i<hs.length;i++){ h=hs[i]; if(h&&typeof h==='object') for(k in h) if(Object.prototype.hasOwnProperty.call(h,k)&&goneGunVal(h[k])) delete h[k]; }
  ['forged','wear'].forEach(function(f){ h=p[f]; if(h&&typeof h==='object'&&!Array.isArray(h)) for(k in h) if(Object.prototype.hasOwnProperty.call(h,k)&&goneGunVal(k)) delete h[k]; });
  if(Array.isArray(p.gunPiled)) p.gunPiled=p.gunPiled.filter(function(x){ return !(x&&goneGunVal(x.gk)); });
  if(paid) p.credits=(+p.credits||0)+paid;
  return paid;
}
function applyLoadedProfile(r){
'@

SubRx @'
if(!Array.isArray(P.stash)) P.stash=[];
          P.stash=P.stash.filter(function(k){ return !!ITEMS[k]; });
'@ @'
try{ gunsGoneSweep(P); }catch(_ggs){}   // v28.xx (cw-gunsgone): a saved Marksman Rifle or Whisper pays its credits first
          if(!Array.isArray(P.stash)) P.stash=[];
          P.stash=P.stash.filter(function(k){ return !!ITEMS[k]; });
'@

SubRx @'
var VER='29.57';
'@ @'
var VER='29.58';
'@

$pat = "(?m)^  now:'v29\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.58: The Marksman Rifle and the Whisper are gone. A saved one pays its credits when the game loads. Check 29.58 fails on v29.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
