$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.45',what:
'@ @'
  {v:'15.46',what:'reviving a pillager never loses the gun in his hands: an elite holding a Marksman Rifle with a Scav Pistol and scrap in his pack pays the pistol for the revive and, killed after, leaves the Marksman Rifle on his body once, while a pillager holding the Scav Pistol his pack carries pays that pistol and his body holds no second one, and one with an empty pack pays the Compact SMG in his hands and his body holds no second SMG (bodies audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkRaider!=='function'||typeof updatePlayer!=='function'||typeof updateEnts!=='function'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: this build has no pillagers, player update or entity update';
     if(typeof keys==='undefined'||typeof mouse==='undefined') return 'SKIP: no key or mouse state in this build';
     if(!(WEAPONS.pistol&&WEAPONS.pistol.id==='pistol'&&WEAPONS.smg&&WEAPONS.smg.id==='smg'&&WEAPONS.dmr&&WEAPONS.dmr.id==='dmr'&&ITEMS.gun_pistol&&ITEMS.gun_smg&&ITEMS.gun_dmr&&ITEMS.scrap)) return 'SKIP: this build has no Scav Pistol, Compact SMG, Marksman Rifle or scrap to stage';
     var bad=[], g=null, p=null, keepEnts=null, keepBag=null, keepTel=null, keepIv=0, shut=[];
     // Distinctive names, so only the bodies staged here are read and removed.
     var TAG='QX REVIVE PROBE ';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function count(list,k){ var c=0; for(var i=0;i<(list||[]).length;i++) if(list[i]===k) c++; return c; }
     function guns(list){ var o=[]; for(var i=0;i<(list||[]).length;i++) if(String(list[i]).indexOf('gun_')===0) o.push(list[i]); return o.length?o.join(', '):'no gun'; }
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     // A downed hostile pillager 24 units from him, holding wk with exactly this pack, off the ledger, and the only thing in the raid.
     function stage(tag,wk,elite,pack){
       var r=mkRaider(p.x+24,p.y,IDENTITIES[0],true);
       r.name=TAG+tag; r.ident=null; r.merc=0; r.ghost=0; r.elite=elite?1:0; r.hostile=true; r.friendlyPC=0;
       r.wep=WEAPONS[wk]; r.dmg=r.wep.dmg; r.rng=Math.min(r.wep.rng*0.72,580);
       r.bag=pack.slice(); r.healQ=0; r.paidRevive=0; r.byPlayer=false; r.finished=0;
       r.x=p.x+24; r.y=p.y; r.downed=1; r.downT=60; r.state='down'; r.hp=30;
       g.ents.length=0; g.ents.push(r);
       return r;
     }
     // E pressed once beside him on the play path, then he is killed down the ordinary death path, by nobody. What the revive paid,
     // the gun in his hands after it, whether he died, and the named body he left, taken out of the raid once found.
     function reviveThenKill(r){
       g.bag=[]; g.revLock=0;
       clearKeys(); mouse.down=false; keys['KeyE']=true; updatePlayer(0.016); clearKeys();
       var o={up:!r.downed, paid:g.bag.slice(), held:(r.wep&&r.wep.id), gone:false, body:null};
       if(!o.up) return o;
       r.hp=0; r.finished=1; r.downed=0; r.byPlayer=false;
       g.ents.length=0; g.ents.push(r);
       updateEnts(0.016);
       o.gone=g.ents.indexOf(r)<0;
       for(var i=g.containers.length-1;i>=0;i--){ var bc=g.containers[i]; if(bc&&bc.fallen===r.name){ o.body=bc; g.containers.splice(i,1); break; } }
       return o;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||g.sim||!g.ents||!g.containers||!g.bag||!g.tel) return 'SKIP: no live raid';
       p=g.player;
       keepEnts=g.ents.slice(); keepBag=g.bag.slice(); keepTel={rv:g.tel.revives,rr:g.tel.raiderRevives}; keepIv=p.iv;
       p.downed=false; p.roll=0; p.iv=99; p.autoJog=false;
       g.searching=null; g.searchT=0; g.trade=null;
       // No unopened container within 90 of him, so E has nothing else to open in the frame it revives.
       for(var ci=0;ci<g.containers.length;ci++){ var CU=g.containers[ci]; if(CU&&!CU.opened&&Math.abs(CU.x-p.x)<90&&Math.abs(CU.y-p.y)<90){ shut.push({c:CU,at:CU.openedAt}); CU.opened=true; } }
       // CONTROL: a pillager holding the Scav Pistol his pack carries is picked up, pays that pistol, dies and leaves a body with his scrap.
       var A=stage('ONE','pistol',false,['gun_pistol','scrap']);
       var a=reviveThenKill(A);
       if(!a.up) return 'SKIP: E beside a downed pillager 24 units away did not pick him up here';
       if(count(a.paid,'gun_pistol')!==1) return 'SKIP: the revive of a pillager carrying a Scav Pistol and scrap paid '+(a.paid.join(', ')||'nothing')+', not the pistol, so the payout is not reached here';
       if(!a.gone||!a.body) return 'SKIP: the revived pillager did not die and leave a named body here';
       if(count(a.body.loot,'scrap')!==1) return 'SKIP: his body held '+((a.body.loot||[]).join(', ')||'nothing')+', not the scrap left in his pack, so the body cannot be read here';
       // KEPT: the gun in his hands was the one paid, so his body holds no second one.
       if(count(a.body.loot,'gun_pistol')!==0) bad.push('a pillager holding the Scav Pistol his pack carried, revived for that pistol and then killed, left a body holding '+guns(a.body.loot)+', so the one gun paid twice');
       // THE FINDING: an elite holding a Marksman Rifle, with the Scav Pistol he spawned with still first in his pack.
       var B=stage('TWO','dmr',true,['gun_pistol','scrap']);
       var b=reviveThenKill(B);
       if(!b.up) return skip('E beside the downed elite did not pick him up here');
       // CONTROL: the revive paid the pistol from his pack, not the rifle, and the rifle stayed in his hands.
       if(count(b.paid,'gun_pistol')!==1||count(b.paid,'gun_dmr')!==0) return skip('the revive of the elite paid '+(b.paid.join(', ')||'nothing')+', not the Scav Pistol from his pack');
       if(b.held!=='dmr') return skip('the elite held '+b.held+' after the revive, not the Marksman Rifle');
       if(!b.gone||!b.body||count(b.body.loot,'scrap')!==1) return skip('the revived elite did not die and leave a named body with his scrap here');
       // THE FIX: the Marksman Rifle he held and never paid is on his body once, and the pistol he paid is not.
       if(count(b.body.loot,'gun_dmr')!==1||count(b.body.loot,'gun_pistol')!==0) bad.push('an elite holding a Marksman Rifle, revived for the Scav Pistol in his pack and then killed, left a body holding '+guns(b.body.loot)+', where the rifle in his hands was never paid and belongs on it once');
       // KEPT: with an empty pack the revive pays the Compact SMG from his hands, and his body holds no second one.
       var C=stage('THREE','smg',false,[]);
       var c=reviveThenKill(C);
       if(!c.up) return skip('E beside the downed pillager with an empty pack did not pick him up here');
       if(count(c.paid,'gun_smg')!==1) return skip('the revive of a pillager with an empty pack paid '+(c.paid.join(', ')||'nothing')+', not the Compact SMG in his hands');
       if(!c.gone) return skip('the revived pillager with an empty pack did not die here');
       if(c.body&&count(c.body.loot,'gun_smg')!==0) bad.push('a pillager with an empty pack, revived for the Compact SMG in his hands and then killed, left a body holding '+guns(c.body.loot)+', so the one gun paid twice');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); mouse.down=false; }catch(_k){}
       try{ if(g){ g.revLock=0; g.nearDown=null; } }catch(_r){}
       try{ for(var sh=0;sh<shut.length;sh++){ shut[sh].c.opened=false; shut[sh].c.openedAt=shut[sh].at; } }catch(_o){}
       try{ if(g&&g.containers){ for(var cj=g.containers.length-1;cj>=0;cj--){ var cc=g.containers[cj]; if(cc&&typeof cc.fallen==='string'&&cc.fallen.indexOf(TAG)===0) g.containers.splice(cj,1); } } }catch(_b){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(g&&keepBag) g.bag=keepBag; }catch(_g){}
       try{ if(g&&keepTel){ g.tel.revives=keepTel.rv; g.tel.raiderRevives=keepTel.rr; } }catch(_t){}
       try{ if(p){ p.iv=keepIv; p.downed=false; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
