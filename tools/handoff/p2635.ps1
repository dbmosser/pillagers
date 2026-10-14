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

# THE FOUR STARTER GUNS ARE GONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
slowest trigger in the game by a distance; Scuttle at 780 was the old record.
'@ @'
slowest trigger in the game by a distance.
'@

SubRx @'
  sniper:{optic:4,id:'sniper',name:'Longshot',dmg:170,rof:1600,spread:.006,mag:5,reload:3200,rng:900,auto:false,noise:640,tint:'#e8f0ff'},
  // Four issued starters, one rolled at random on every deploy. Tuned at or just
  // under the Scav Pistol and Compact SMG so the shop and loot guns stay upgrades.
  tacker:{id:'tacker',name:'Tacker',dmg:20,rof:240,spread:.048,mag:14,reload:1300,rng:400,auto:false,noise:320,tint:'#ffd9a8',starter:1},
  sputter:{id:'sputter',name:'Sputter',dmg:11,rof:80,spread:.130,mag:28,reload:1750,rng:330,auto:true,noise:300,tint:'#ffe6b8',starter:1},
  chatter:{id:'chatter',name:'Chatter',dmg:20,rof:150,spread:.085,mag:22,reload:1950,rng:470,auto:true,noise:400,tint:'#ffd18a',starter:1},
  scuttle:{id:'scuttle',name:'Scuttle',dmg:12,pellets:5,rof:780,spread:.200,mag:6,reload:2200,rng:210,auto:false,noise:470,tint:'#ffc98a',starter:1},
'@ @'
  sniper:{optic:4,id:'sniper',name:'Longshot',dmg:170,rof:1600,spread:.006,mag:5,reload:3200,rng:900,auto:false,noise:640,tint:'#e8f0ff'},
'@

SubRx @'
var STARTERS=['tacker','sputter','chatter','scuttle'];
'@ @'
// v26.35 (nostarters), HIS ORDER (2026-10-14): "get rid of sputter tacker chatter scuttle -- i dont understand why those were ever in the
// game". The four issued starter guns are gone. This list is what is left of the loaner draw: buildRaid still makes that one draw from four
// names (a live raid takes the Scav Pistol and drops the pick, the bot sim plays the gun it names), so the seeded stream, the seed 4242 raid
// and the party loaner word are what they were. Four real guns of the old strength: the Scav Pistol, Compact SMG, Auto Rifle and Riot Scattergun.
var SIM_START=['pistol','smg','rifle','shotgun'];
'@

SubRx @'
Pistol 23, Tacker 20, Scuttle 12 a pellet, Magnum 62,
'@ @'
Pistol 23, Magnum 62,
'@

SubRx @'
var WTIER={fists:0,tacker:1,pistol:1,sputter:2,scuttle:2,smg:2,chatter:2,magnum:3,
'@ @'
var WTIER={fists:0,pistol:1,smg:2,magnum:3,
'@

SubRx @'
(the three pistol rows in mkRaider are the Tacker now, the same tier and feel),
// an imported friend who favoured it walks in with the Tacker, and reward 5 pays
'@ @'
(the three sidearm rows in mkRaider carry the Magnum and the Compact SMG now, v26.35 nostarters),
// an imported friend who favoured it walks in with the Magnum, and reward 5 pays
'@

SubRx @'
          if(!Array.isArray(P.weapons)) P.weapons=[];
          // THE v2.97 GUN RENAME MIGRATION. The four issued starters were named
          // Ferro, Kettle, Stitcher and Hullcracker, which are four real ARC
          // RAIDERS weapons, so they are gone. Their internal KEYS went with the
          // names rather than being left behind as a private record of the lift.
          // This has to run BEFORE the filter on the very next lines, and that is
          // the whole reason it exists: the filter drops any weapon key the build
          // no longer knows, so without this a returning save would have its owned
          // starters and their accumulated wear SILENTLY DELETED, which is the
          // worst class of bug this file can ship. Owned guns, the equipped gun
          // and the wear ledger are all keyed by gun id, so all three are mapped.
          var GUNMIG={ferro:'tacker',kettle:'sputter',stitcher:'chatter',hullcracker:'scuttle'};
          P.weapons=P.weapons.map(function(k){ return GUNMIG[k]||k; });
          if(GUNMIG[P.equipped]) P.equipped=GUNMIG[P.equipped];
          if(P.wear){ for(var _gk in GUNMIG){ if(P.wear[_gk]!==undefined){
            P.wear[GUNMIG[_gk]]=(P.wear[GUNMIG[_gk]]||0)+P.wear[_gk]; delete P.wear[_gk]; } } }
'@ @'
          if(!Array.isArray(P.weapons)) P.weapons=[];
'@

SubRx @'
      pistol: {len:1700,lp:2600,hp:300,g:.13,decay:3.6,body:{f0:200,f1:70,d:.09,g:.10,type:'sine'}},
      tacker: {len:1300,lp:3400,hp:600,g:.12,decay:4.4,body:{f0:260,f1:110,d:.06,g:.07,type:'triangle'}},
'@ @'
      pistol: {len:1700,lp:2600,hp:300,g:.13,decay:3.6,body:{f0:200,f1:70,d:.09,g:.10,type:'sine'}},
'@

SubRx @'
      smg:    {len:1500,lp:2100,hp:200,g:.11,decay:4.0,body:{f0:170,f1:80,d:.07,g:.08,type:'sine'}},
      sputter:{len:1200,lp:1600,hp:150,g:.11,decay:4.6,body:{f0:130,f1:60,d:.06,g:.09,type:'square'},rattle:1},
      chatter:{len:1900,lp:2200,hp:250,g:.12,decay:3.8,body:{f0:190,f1:75,d:.08,g:.09,type:'sine'}},
'@ @'
      smg:    {len:1500,lp:2100,hp:200,g:.11,decay:4.0,body:{f0:170,f1:80,d:.07,g:.08,type:'sine'}},
'@

SubRx @'
      shotgun:{len:4200,lp:900,hp:100,g:.22,decay:2.2,body:{f0:120,f1:45,d:.12,g:.14,type:'sine'},pump:1},
      scuttle:{len:3200,lp:1300,hp:200,g:.20,decay:2.6,body:{f0:150,f1:60,d:.09,g:.11,type:'triangle'},pump:1},
'@ @'
      shotgun:{len:4200,lp:900,hp:100,g:.22,decay:2.2,body:{f0:120,f1:45,d:.12,g:.14,type:'sine'},pump:1},
'@

SubRx @'
        cs.connect(cfl); cfl.connect(cg); cg.connect(OUT); cs.start(t+ck[ci]);
      }
    }
    if(V.rattle){
      // a second, lighter crack a hair behind the first: the Sputter sputters
      var rl2=Math.round(V.len*.6),rb2=a.createBuffer(1,rl2,a.sampleRate),rc2=rb2.getChannelData(0);
      for(var ri2=0;ri2<rl2;ri2++) rc2[ri2]=(Math.random()*2-1)*Math.pow(1-ri2/rl2,V.decay);
      var rs2=a.createBufferSource(); rs2.buffer=rb2;
      var rf2=a.createBiquadFilter(); rf2.type='lowpass'; rf2.frequency.value=(V.lp||1600)*.8*J;
      var rg2=a.createGain(); rg2.gain.value=V.g*vol*.6;
      rs2.connect(rf2); rf2.connect(rg2); rg2.connect(OUT); rs2.start(t+.012);
    }
'@ @'
        cs.connect(cfl); cfl.connect(cg); cg.connect(OUT); cs.start(t+ck[ci]);
      }
    }
'@

SubRx @'
    if(_upIss===false){ var _upR=RNGS; wep=WEAPONS[pick(STARTERS)]; RNGS=_upR; }
    else wep=WEAPONS[pick(STARTERS)];
'@ @'
    if(_upIss===false){ var _upR=RNGS; wep=WEAPONS[pick(SIM_START)]; RNGS=_upR; }
    else wep=WEAPONS[pick(SIM_START)];
'@

SubRx @'
  } else if(_upIss===true){ pick(STARTERS); }
'@ @'
  } else if(_upIss===true){ pick(SIM_START); }
'@

SubRx @'
  // v24.xx (scavspawnonly), HIS ORDER: the Scav Pistol is spawn-only, so the three pistol rows are the Tacker, the other tier 1
  // sidearm (20 a round against 23, 14 rounds against 12), and the pick still draws once from nine.
  var _wkL=['tacker','tacker','tacker','smg','smg','rifle','rifle','carbine','shotgun'], _wkR=rr()*_wkL.length, wk=_wkL[Math.floor(_wkR)];
'@ @'
  // v24.xx (scavspawnonly), HIS ORDER: the Scav Pistol is spawn-only, so no pillager carries it, and its three rows held the Tacker.
  // v26.35 (nostarters), HIS ORDER (2026-10-14): "get rid of sputter tacker chatter scuttle". Those three sidearm rows (the first three)
  // carry real, lootable guns now: one the Magnum and two the Compact SMG, so the Compact SMG is the commonest gun on a pillager (four rows
  // of nine) and the lower tiers lead. Nine rows still, so the pick still draws once from nine and the seeded stream is what it was.
  var _wkL=['magnum','smg','smg','smg','smg','rifle','rifle','carbine','shotgun'], _wkR=rr()*_wkL.length, wk=_wkL[Math.floor(_wkR)], _wkSide=Math.floor(_wkR)<3;
'@

SubRx @'
  if(ITEMS['gun_'+wk]) r.bag.push('gun_'+wk);   // v24.xx (scavspawnonly): the Tacker is an issued gun with no item form, so it is not loot
'@ @'
  // v26.35 (nostarters): the three sidearm rows used to carry the Tacker, which had no item form and so never dropped. The gun they carry
  // now is a real one, but the share of pillagers who drop a gun stays what it was: it is in his hands and not in his pack, and noGunDrop
  // names it, so the death path, the revive payout and the swap leave no copy of it. The other six rows put theirs in the pack as before.
  if(ITEMS['gun_'+wk]){ if(_wkSide) r.noGunDrop=wk; else r.bag.push('gun_'+wk); }
'@

SubRx @'
    e.wep=WEAPONS[_gk]; e.dmg=WEAPONS[_gk].dmg;
'@ @'
    e.wep=WEAPONS[_gk]; e.dmg=WEAPONS[_gk].dmg;
    e.noGunDrop=null;   // v26.35 (nostarters): the gun an elite is blessed with is a find, and it drops as before
'@

SubRx @'
  for(i=0;i<n;i++){ k=rollLoot(LOOT.safe); if(k) out.push(k); }
  return out;
}
'@ @'
  for(i=0;i<n;i++){ k=rollLoot(LOOT.safe); if(k) out.push(k); }
  return out;
}
// v26.35 (nostarters): does the gun in a pillager's hands leave a copy on his body? Every gun with an item form does, except the one a
// sidearm-row pillager spawned with (noGunDrop, set in mkRaider): that row used to carry the Tacker, which never dropped, and the rate
// of dropped guns is kept where it was. The death path, the revive payout and the swap all ask here.
function heldGunDrops(e){ return !!(e&&e.wep&&e.wep.id&&ITEMS['gun_'+e.wep.id]&&e.noGunDrop!==e.wep.id); }
'@

SubRx @'
      } else if(e.kind==='raider'&&(e.bag.length||(e.wep&&e.wep.id&&ITEMS['gun_'+e.wep.id]))){
'@ @'
      } else if(e.kind==='raider'&&(e.bag.length||heldGunDrops(e))){
'@

SubRx @'
        if(e.wep&&e.wep.id&&ITEMS['gun_'+e.wep.id]&&!e.paidRevive&&_drop.indexOf('gun_'+e.wep.id)<0)
'@ @'
        if(heldGunDrops(e)&&!e.paidRevive&&_drop.indexOf('gun_'+e.wep.id)<0)
'@

SubRx @'
        else if(!downRdr.paidRevive&&downRdr.wep&&downRdr.wep.id&&ITEMS['gun_'+downRdr.wep.id]) _rpk='gun_'+downRdr.wep.id;
'@ @'
        else if(!downRdr.paidRevive&&heldGunDrops(downRdr)) _rpk='gun_'+downRdr.wep.id;
'@

SubRx @'
      if(old&&old.id!=='fists'&&ITEMS['gun_'+old.id]&&e.bag.indexOf('gun_'+old.id)<0) e.bag.push('gun_'+old.id);   // v24.xx (scavspawnonly): a Tacker has no item form
'@ @'
      if(old&&old.id!=='fists'&&ITEMS['gun_'+old.id]&&old.id!==e.noGunDrop&&e.bag.indexOf('gun_'+old.id)<0) e.bag.push('gun_'+old.id);   // v26.35 (nostarters): a sidearm-row gun is in his hands only
'@

SubRx @'
      // v24.xx (scavspawnonly), HIS ORDER: no pillager carries the Scav Pistol, so a friend who favoured it (or bare hands) walks in
      // with the Tacker, the same tier and feel.
      e.wep=(WEAPONS[P.ghost.wep].mag===0||P.ghost.wep==='pistol')?WEAPONS.tacker:WEAPONS[P.ghost.wep];
'@ @'
      // v24.xx (scavspawnonly), HIS ORDER: no pillager carries the Scav Pistol, so a friend who favoured it (or bare hands) walks in
      // with a gun of his own tier. v26.35 (nostarters): the Magnum, where it was the Tacker. It is the gun in his hands and no copy
      // for his body, so the drop rate is what it was.
      var _gSub=(WEAPONS[P.ghost.wep].mag===0||P.ghost.wep==='pistol');
      e.wep=_gSub?WEAPONS.magnum:WEAPONS[P.ghost.wep];
      if(_gSub) e.noGunDrop=e.wep.id;
'@

SubRx @'
var ARCADE_GUNS2=['magnum','dmr','shotgun','chatter','smg','carbine'];
'@ @'
var ARCADE_GUNS2=['magnum','dmr','shotgun','rifle','smg','carbine'];   // v26.35 (nostarters): the Auto Rifle where the Chatter was
'@

SubRx @'
(never a pistol, a Tacker or bare hands)
'@ @'
(never a pistol or bare hands)
'@

SubRx @'
  if(id==='shotgun'||id==='scuttle'){
'@ @'
  if(id==='shotgun'){
'@

SubRx @'
  } else if(id==='rifle'||id==='chatter'||id==='carbine'||id==='dmr'){
'@ @'
  } else if(id==='rifle'||id==='carbine'||id==='dmr'){
'@

SubRx @'
  } else if(id==='smg'||id==='sputter'||id==='whisper'){
'@ @'
  } else if(id==='smg'||id==='whisper'){
'@

SubRx @'
  } else {   // the Scav Pistol, the Tacker and any gun added later
'@ @'
  } else {   // the Scav Pistol and any gun added later
'@

SubRx @'
var GEAR_LIGHT={pistol:1,tacker:1,magnum:1,smg:1,sputter:1,whisper:1,fists:1};
'@ @'
var GEAR_LIGHT={pistol:1,magnum:1,smg:1,whisper:1,fists:1};
'@

SubRx @'
var DRAWT={tacker:0.25,pistol:0.25,magnum:0.35,sputter:0.4,smg:0.4,whisper:0.45,chatter:0.5,carbine:0.5,rifle:0.55,scuttle:0.6,shotgun:0.6,dmr:0.7,sniper:0.85,lmg:1.0,lance:1.0};
'@ @'
var DRAWT={pistol:0.25,magnum:0.35,smg:0.4,whisper:0.45,carbine:0.5,rifle:0.55,shotgun:0.6,dmr:0.7,sniper:0.85,lmg:1.0,lance:1.0};
'@

SubRx @'
muzzle: Tacker and Scav Pistol about
// 19, Magnum, Sputter and Compact SMG 21,
'@ @'
muzzle: the Scav Pistol about
// 19, Magnum and Compact SMG 21,
'@

SubRx @'
  var D={};
  D.tacker={pist:1,tip:16.8,by:0,grip:4.4,fg:4.4,well:[8.5,2.8],port:[8,-2.75],rv:[3,-2.75,11,5.5],br:[14,16.8],p:[
    P([4,1.5, 7,1.5, 6.2,6, 3.4,6],'d'), R(5.5,2.75,6.5,1.4,'l'), R(3,-2.75,11,5.5,'m','FHR'), R(9,-2.75,2,5.5,'y','O'),
    R(14,-1.5,2.8,3,'d','H')]};
'@ @'
  var D={};
'@

SubRx @'
    C(10,0,2.5,'l','F'), R(9,-0.3,2,0.6,'k','O'), R(18.6,-3.6,0.9,1.1,'d')]};
  D.sputter={tip:20,by:0,grip:5,fg:15.2,well:[11.2,2.8],port:[9,-2.8],rv:[3,-2.8,10,5.6],br:[13,20],p:[
    R(-3,-1.6,6,0.9,'d'), R(-3,-1.6,1,3.8,'d'), R(-3,1.3,6,0.9,'d'), grip(5), P([10,2.8, 12.4,2.8, 14.2,7, 11.8,7.4],'l','H'),
    R(3,-2.8,10,5.6,'m','FHR'), R(13,-1.9,4.6,3.8,'d','H'), R(14,-0.5,0.8,1,'k','OV'), R(15.6,-0.5,0.8,1,'k','OV'),
    R(17.6,-1.2,2.4,2.4,'m')]};
'@ @'
    C(10,0,2.5,'l','F'), R(9,-0.3,2,0.6,'k','O'), R(18.6,-3.6,0.9,1.1,'d')]};
'@

SubRx @'
    R(14,-2,5,4,'d','H'), R(15,-0.6,0.9,1.2,'k','OV'), R(16.8,-0.6,0.9,1.2,'k','OV'), R(19,-1.2,2,2.4,'m')]};
  D.chatter={tip:26.5,by:0,grip:5,fg:16.5,well:[10.4,2.6],port:[9,-2.6],rv:[3,-2.6,10,5.2],br:[13,26.5],p:[
    grip(5), cmag(9,2.6), P([-3,-2.2, 3,-1.6, 3,2, -3,3],'d','F'), R(3,-2.6,10,5.2,'m','FHR'), R(13,-2,8,3.8,'d','HR'),
    R(20,-3.6,0.9,1.6,'d'), R(21,-1,5.5,2,'m','H')]};
'@ @'
    R(14,-2,5,4,'d','H'), R(15,-0.6,0.9,1.2,'k','OV'), R(16.8,-0.6,0.9,1.2,'k','OV'), R(19,-1.2,2,2.4,'m')]};
'@

SubRx @'
    R(25,-2.2,0.6,4.4,'k','OV')]};
  D.scuttle={tip:21.2,by:0,grip:4.8,fg:13,well:[7,2.9],port:[7,-2.9],rv:[4,-2.9,6,5.8],br:[10,21.2],p:[
    P([-3,-1.8, 4.2,-1.8, 4.6,2.6, 1.6,2.6, -3,3.8],'w'), R(-2,0.2,5,0.5,'W','O'), R(4,-2.9,6,5.8,'m','FHR'),
    R(10,-2.4,10,2.3,'m','H'), R(10,-0.1,10,2.3,'l','R'), R(10.5,1.6,5.4,1.8,'W'), R(19.6,-2.9,1.6,5.6,'d')]};
'@ @'
    R(25,-2.2,0.6,4.4,'k','OV')]};
'@

SubRx @'
  if(_wid==='pistol'||_wid==='tacker'){ _L=7; _B=4; }
'@ @'
  if(_wid==='pistol'){ _L=7; _B=4; }
'@

SubRx @'
  else if(_wid==='smg'||_wid==='sputter'){ _L=10; _B=3; _mag=1; }
  else if(_wid==='shotgun'||_wid==='scuttle'){ _L=12; _B=7; _pump=1; }
'@ @'
  else if(_wid==='smg'){ _L=10; _B=3; _mag=1; }
  else if(_wid==='shotgun'){ _L=12; _B=7; _pump=1; }
'@

SubRx @'
  else { _mag=1; }   // chatter, carbine, rifle and anything new: the 13px body
'@ @'
  else { _mag=1; }   // carbine, rifle and anything new: the 13px body
'@

SubRx @'
var GUN_FAMILY={pistol:'hand',tacker:'hand',magnum:'revolver',
                smg:'smg',sputter:'smg',chatter:'smg',
'@ @'
var GUN_FAMILY={pistol:'hand',magnum:'revolver',
                smg:'smg',
'@

SubRx @'
                shotgun:'shotgun',scuttle:'shotgun',
'@ @'
                shotgun:'shotgun',
'@

SubRx @'
var VER='26.34';
'@ @'
var VER='26.35';
'@

$pat = "(?m)^  now:'v26\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.35: The Tacker, Sputter, Chatter and Scuttle are gone: pillagers carry real lootable guns and the DEMO kit deals real guns. Check 26.35 fails on v26.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
