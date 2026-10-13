$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'25.87',what:")) { throw "check 25.87 is in the fixture already" }

SubRx @'
  {v:'25.86',what:
'@ @'
  {v:'25.87',what:'his order (so player can only carry 4 guns max; swap with the lowest gun that is not in use, move it to the inventory): with keys 1 to 4 all showing a real gun, a gun that arrives takes the place of the weakest gun that is not in his hands and that gun goes to the backpack with no key (the stowed gun or a backpack gun on key 3 or 4), a weaker find or a tie goes straight to the backpack with nothing moving, the gun in his hands is never chosen, the rows say SLOT n and BACKPACK, an issued loaner is left behind, and a backpack over its cap drops the gun that was pushed out',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof autoBelt!=='function'||typeof grantLoot!=='function'||typeof hotbarSlots!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4) return 'SKIP: no four gun keys here';
     var ids=['rifle','carbine','shotgun','magnum','smg','lmg','pistol'], i;
     for(i=0;i<ids.length;i++) if(!WEAPONS[ids[i]]||!ITEMS['gun_'+ids[i]]) return 'SKIP: no '+ids[i]+' gun item here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, s0=say, gs0=gunStats, cap0=PACKCAP[P.pack], heard=[], r, sl, fi, pins0, wNew, n0, cc;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function gid(x){ return (x&&x.kind==='gun'&&!x.vacant)?String(x.icon||'').replace(/^gun_/,''):''; }
     function pinOf(id){ var k; for(k in g.hotAssign) if(g.hotAssign[k]==='gun_'+id) return +k; return -1; }
     function row(item){ for(var j=0;j<heard.length;j++) if(heard[j].o&&heard[j].o.item===item) return heard[j]; return null; }
     function tagOf(item){ var h=row(item); return h?String(h.o.tag||''):'(no row)'; }
     function has(id){ return g.bag.indexOf('gun_'+id)>=0; }
     function stage(hand,sec,b1,b2){
       p.wep=cl(hand); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl(sec); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=['gun_'+b1,'gun_'+b2]; g.stowQ={}; g.stowAmmo={};
       g.hotAssign={0:'gun_'+hand,1:'gun_'+sec,2:'gun_'+b1,3:'gun_'+b2}; g.hotAuto={0:1,1:1,2:1,3:1};
       g.hotPruned={}; g.drag=null; g.paused=false; g.hot=0; heard.length=0;
       var s=hotbarSlots();
       if(!(gid(s[0])===hand&&s[0].inHand&&gid(s[1])===sec&&gid(s[2])===b1&&gid(s[3])===b2)) return 'staging: keys 1 to 4 do not show '+hand+' in hand, '+sec+', '+b1+', '+b2+' ('+[0,1,2,3].map(function(j){ return gid(s[j])||(s[j]&&s[j].k)||'-'; }).join(', ')+')';
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       g.ents.length=0; p.iv=99; keys={}; g.bagOpen=false; g.mapOpen=false;
       say=function(m,k,o){ heard.push({m:String(m),k:k,o:o||{}}); };
       // ONE: the weakest gun is a backpack gun on key 3 (smg): the find (a Support MG) takes its key, the smg stays in the backpack with no key
       r=stage('rifle','carbine','smg','shotgun'); if(r) return r;
       grantLoot({x:p.x,y:p.y,loot:[],dropped:1},['gun_lmg']);
       if(pinOf('lmg')!==2) bad.push('ONE: the find did not take key 3, the weakest gun key (keys '+JSON.stringify(g.hotAssign)+')');
       if(pinOf('smg')!==-1||!has('smg')) bad.push('ONE: the weakest gun is not in the backpack with no key (keys '+JSON.stringify(g.hotAssign)+', backpack '+g.bag.join(',')+')');
       if(!has('lmg')) bad.push('ONE: the find is not in the backpack grid');
       if(pinOf('rifle')!==0||pinOf('carbine')!==1||pinOf('shotgun')!==3) bad.push('ONE: another gun key moved ('+JSON.stringify(g.hotAssign)+')');
       if(!(p.wep.id==='rifle'&&p.sec.id==='carbine')) bad.push('ONE: the guns in his hands changed to '+p.wep.id+'/'+(p.sec&&p.sec.id));
       if(tagOf('gun_lmg')!=='SLOT 3') bad.push('ONE: the find row says '+tagOf('gun_lmg')+', not SLOT 3');
       if(tagOf('gun_smg')!=='BACKPACK') bad.push('ONE: the pushed-out gun row says '+tagOf('gun_smg')+', not BACKPACK');
       // TWO: the weakest gun is the stowed gun (smg): the find takes that slot with half a magazine, the smg goes to the backpack with its rounds
       r=stage('rifle','smg','carbine','shotgun'); if(r) return r;
       grantLoot({x:p.x,y:p.y,loot:[],dropped:1},['gun_lmg']);
       sl=hotbarSlots(); fi=-1; for(i=0;i<4;i++) if(gid(sl[i])==='lmg'&&!sl[i].inHand&&fi<0) fi=i;
       if(!(p.sec&&p.sec.id==='lmg'&&p.wep.id==='rifle')) bad.push('TWO: the guns in his hands are '+p.wep.id+'/'+(p.sec&&p.sec.id)+', not rifle/lmg');
       if(!has('smg')||has('lmg')||g.bag.length!==3) bad.push('TWO: the backpack holds '+g.bag.join(',')+', not the pinned guns and the pushed-out smg');
       if(pinOf('smg')!==-1) bad.push('TWO: the pushed-out smg kept a key (keys '+JSON.stringify(g.hotAssign)+')');
       if(!(g.stowAmmo&&g.stowAmmo.smg&&g.stowAmmo.smg.length===1)) bad.push('TWO: the smg rounds were not stowed with it');
       if(p.secAmmo!==Math.ceil(WEAPONS.lmg.mag/2)) bad.push('TWO: the find came up with '+p.secAmmo+' rounds, not half a magazine');
       if(fi<0) bad.push('TWO: no gun key 1 to 4 shows the find'); else if(tagOf('gun_lmg')!=='SLOT '+(fi+1)) bad.push('TWO: the find row says '+tagOf('gun_lmg')+', not SLOT '+(fi+1));
       if(tagOf('gun_smg')!=='BACKPACK') bad.push('TWO: the pushed-out gun row says '+tagOf('gun_smg')+', not BACKPACK');
       // THREE: a find weaker than every gun on the keys goes to the backpack and nothing moves
       r=stage('rifle','carbine','smg','shotgun'); if(r) return r;
       pins0=JSON.stringify(g.hotAssign);
       grantLoot({x:p.x,y:p.y,loot:[],dropped:1},['gun_pistol']);
       if(JSON.stringify(g.hotAssign)!==pins0||p.sec.id!=='carbine'||p.wep.id!=='rifle') bad.push('THREE: a weak find moved something (keys '+JSON.stringify(g.hotAssign)+')');
       if(!has('pistol')||pinOf('pistol')!==-1) bad.push('THREE: the weak find is not in the backpack with no key');
       if(tagOf('gun_pistol')!=='BACKPACK') bad.push('THREE: the weak find row says '+tagOf('gun_pistol')+', not BACKPACK');
       // FOUR: the gun in his hands is never chosen, even when it is the weakest of all (a pistol in hand, smg on key 3 is the weakest that may go)
       r=stage('pistol','rifle','smg','shotgun'); if(r) return r;
       g.bag.push('gun_lmg'); r=autoBelt('gun_lmg',true);
       if(p.wep.id!=='pistol'||pinOf('pistol')!==0) bad.push('FOUR: the gun in his hands was moved ('+p.wep.id+', keys '+JSON.stringify(g.hotAssign)+')');
       if(pinOf('lmg')!==2||pinOf('smg')!==-1) bad.push('FOUR: the weakest gun not in his hands did not go (keys '+JSON.stringify(g.hotAssign)+')');
       if(!/TO SLOT 3$/.test(String(r||''))) bad.push('FOUR: the call returned '+JSON.stringify(r)+', not a TO SLOT 3 headline');
       // FIVE: ties. With the damage equal, three tier 3 guns tie: a tied find goes to the backpack, and a stronger find takes the HIGHER key
       gunStats=function(w){ var s=gs0(w); s.dps=100; return s; };
       r=stage('smg','carbine','shotgun','magnum'); if(r) return r;
       pins0=JSON.stringify(g.hotAssign);
       g.bag.push('gun_rifle'); r=autoBelt('gun_rifle',true);
       if(JSON.stringify(g.hotAssign)!==pins0||p.sec.id!=='carbine') bad.push('FIVE: a tied find moved something (keys '+JSON.stringify(g.hotAssign)+')');
       if(!/TO BACKPACK$/.test(String(r||''))) bad.push('FIVE: a tied find returned '+JSON.stringify(r)+', not a TO BACKPACK headline');
       r=stage('smg','carbine','shotgun','magnum'); if(r) return r;
       g.bag.push('gun_lmg'); autoBelt('gun_lmg',true);
       if(pinOf('lmg')!==3||pinOf('magnum')!==-1||pinOf('shotgun')!==2||p.sec.id!=='carbine') bad.push('FIVE: among tied guns the higher key did not go (keys '+JSON.stringify(g.hotAssign)+', stowed '+p.sec.id+')');
       gunStats=gs0;
       // SIX: an issued loaner in the stowed slot is the weakest and is left behind, not banked
       r=stage('rifle','pistol','carbine','shotgun'); if(r) return r;
       p.secIssued=true;
       g.bag.push('gun_lmg'); autoBelt('gun_lmg',true);
       if(!(p.sec&&p.sec.id==='lmg')) bad.push('SIX: the stowed loaner was not replaced ('+(p.sec&&p.sec.id)+')');
       if(has('pistol')) bad.push('SIX: the issued loaner was banked in the backpack');
       if(!(typeof BELTDISP!=='undefined'&&BELTDISP&&BELTDISP.tag==='LEFT BEHIND')) bad.push('SIX: the loaner row is not tagged LEFT BEHIND');
       // SEVEN: a backpack over its cap drops the gun that was pushed out, and the red row names it
       r=stage('rifle','smg','carbine','shotgun'); if(r) return r;
       g.bag.push('gun_lmg'); wNew=bagWeight()-ITEMS.gun_lmg.wt+ITEMS.gun_smg.wt;
       PACKCAP[P.pack]=wNew-0.5; n0=g.containers.length;
       autoBelt('gun_lmg',true);
       cc=g.containers[g.containers.length-1];
       if(!(p.sec&&p.sec.id==='lmg')) bad.push('SEVEN: the find did not take the stowed slot ('+(p.sec&&p.sec.id)+')');
       if(has('smg')) bad.push('SEVEN: the pushed-out gun stayed in a full backpack');
       if(!(g.containers.length===n0+1&&cc&&JSON.stringify(cc.loot||[]).indexOf('gun_smg')>=0)) bad.push('SEVEN: the pushed-out gun is not on the ground at his feet');
       if(!heard.some(function(h){ return h.m==='BACKPACK FULL'&&h.o&&h.o.key==='bagfull'&&/SUPPORT MG|SMG/i.test(String(h.o.sub||'')); })) bad.push('SEVEN: no red BACKPACK FULL row naming the gun ('+heard.map(function(h){ return h.m; }).join(' / ')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0; gunStats=gs0; try{ PACKCAP[P.pack]=cap0; }catch(_pc){}
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; BELTDISP=null; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
