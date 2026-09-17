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
  {v:'15.15',what:
'@ @'
  {v:'15.16',what:'an imported friend keeps their favourite gun for the raid: a friend favouring the Scav Pistol and carrying an Auto Rifle still holds the pistol after a frame, still carries the rifle as loot and still starts a Bandage, while a plain pillager holding the same pair swaps to the rifle on that frame (mainframe audit finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof applyGhost!=='function'||typeof raiderUseKit!=='function'||typeof updateEnts!=='function') return 'SKIP: this build has no imported friend or pillager kit use';
     if(!(WEAPONS.pistol&&WEAPONS.pistol.mag&&WEAPONS.rifle&&ITEMS.gun_rifle&&ITEMS.gun_rifle.gk==='rifle'&&ITEMS.bandage&&ITEMS.bandage.use==='heal')) return 'SKIP: this build has no Scav Pistol, Auto Rifle or Bandage to stage';
     if(!((WTIER.rifle||0)>(WTIER.pistol||0))) return 'SKIP: the Auto Rifle does not outrank the Scav Pistol here, so no swap would be offered';
     var bad=[], snap=null, g=null, gh=null, r2=null, keepGhost=null;
     var find=function(){
       gh=null; r2=null;
       for(var k=0;k<g.ents.length;k++){
         var en=g.ents[k];
         if(en.kind!=='raider'||en.downed||en.finished) continue;
         if(en.ghost){ if(!gh) gh=en; }
         else if(!en.merc&&!r2) r2=en;
       }
     };
     var guns=function(x){
       var c=(x.wep&&x.wep.id!=='fists')?1:0;
       for(var i=0;i<(x.bag||[]).length;i++){ var it=ITEMS[x.bag[i]]; if(it&&it.use==='gun') c++; }
       return c;
     };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       keepGhost=__P().ghost;
       __P().ghost={tag:'QX_GHOST_7',wep:'pistol',wepName:'Scav Pistol',runs:3,ext:1,rate:33,avgHaul:0};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       // CONTROL: the kit dial is on, so pillagers use what they carry in this raid.
       if(CFG.raiderKit===0) return 'SKIP: pillager kit use is switched off here';
       find();
       if(!gh){ applyGhost(); find(); }
       // CONTROL: the import placed the friend holding their favourite, and a plain pillager is in the same raid.
       if(!gh) return 'SKIP: no imported friend was placed in the raid';
       if(!gh.wep||gh.wep.id!=='pistol') return 'SKIP: the import did not hand the friend the Scav Pistol here ('+(gh.wep&&gh.wep.id)+')';
       if(!r2) return 'SKIP: no plain pillager in this raid to compare against';
       // THE STAGE: the friend holds the favourite and carries an Auto Rifle, as a body that rolled one does, plus a Bandage at
       // 40 percent health; the plain pillager holds a Scav Pistol and carries the same Auto Rifle. Both swap tests are due now.
       gh.bag=['gun_rifle','bandage']; gh.kitT=0; gh.healQ=0; gh.hp=Math.max(1,Math.round(gh.maxhp*0.4));
       var heals0=gh.kitHeals||0;
       r2.wep=WEAPONS.pistol; r2.dmg=r2.wep.dmg; r2.rng=Math.min(r2.wep.rng*0.72,580); r2.bag=['gun_rifle']; r2.kitT=0;
       updateEnts(0.016);
       // CONTROL: the frame ran the swap: the plain pillager traded the Scav Pistol for the Auto Rifle and still has two guns.
       if(!r2.wep||r2.wep.id!=='rifle') return 'SKIP: the plain pillager did not swap to the Auto Rifle on this frame ('+(r2.wep&&r2.wep.id)+'), so no swap ran here';
       if(guns(r2)!==2) return 'SKIP: the plain pillager swap did not keep both guns ('+guns(r2)+'), so the frame did more than swap';
       // CONTROL: the friend is still in the raid and up after the frame.
       if(g.ents.indexOf(gh)<0||gh.downed||gh.finished) return 'SKIP: the friend left the raid or went down on the staged frame';
       if(!gh.wep||gh.wep.id!=='pistol') bad.push('an imported friend favouring the Scav Pistol held the '+((gh.wep&&gh.wep.name)||'nothing')+' after one frame: the swap took the gun the body carried and put the favourite away');
       if(gh.bag.indexOf('gun_rifle')<0) bad.push('the Auto Rifle the friend carried is no longer carried as loot'+(gh.bag.indexOf('gun_pistol')>=0?', and the Scav Pistol is carried in its place':''));
       // THE FIX IS NARROW: only the swap is skipped, so the hurt friend still starts the Bandage.
       if(!((gh.kitHeals||0)>heals0)&&gh.bag.indexOf('bandage')>=0) bad.push('the friend at 40 percent health did not start the Bandage they carry on that frame, so more than the gun swap is switched off for them');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(snap) __P().ghost=keepGhost; }catch(_g){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
