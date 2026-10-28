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

if ($s.Contains("  {v:'35.72',what:")) { throw "check 35.72 is in the fixture already" }

SubRx @'
  {v:'35.71',what:
'@ @'
  {v:'35.72',what:'cw-newpdefs, his order of 10-28 (these should be the default settings for a new player, and for arcade mode): a brand new profile opens on his settings page (new player, edit the words off, superhot off, shared sight on, fog of war off, few pillagers, few machines, forgiving, long raid, rich, light heat) and pays x1.05, a save from before keeps the set it played on, his own save keeps every choice, and every demo start in either window takes the same list and leaving puts the career choices back',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof applyGameOpts!=='function'||typeof arcadeSandboxIn!=='function'||typeof arcadeSandboxOut!=='function'||typeof diffNow!=='function') return 'SKIP: no settings rows, loader or demo sandbox here';
     if(typeof netShHost==='function'&&netShHost()!==null) return 'SKIP: a linked window, where the host word decides';
     if(typeof newpHome!=='function'||typeof newpKeep!=='function'||typeof newpSandbox!=='function') return 'no new player default for every new profile in this build';
     var saved=P, cfg={}, k, i, j, oldStore=storeSet, oldSave=saveProfile, om=window.matchMedia, defs=[], bad=[], snap, row, go0;
     // his picture, top to bottom: the row and the option name it must stand on
     var WANT=[['textEdit','Off'],['superhot','Off'],['sharedSight','On'],['fogWar','Off'],['raiders','Few'],['robots','Few'],['hits','Forgiving'],['clock','Long'],['loot','Rich'],['ext','Light']];
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function rowOf(key){ var r=null, q; for(q=0;q<GAMEOPTS.length;q++) if(GAMEOPTS[q].k===key) r=GAMEOPTS[q]; return r; }
     function onList(tag){
       var q, r, ix;
       for(q=0;q<WANT.length;q++){
         r=rowOf(WANT[q][0]); if(!r){ bad.push(tag+': no '+WANT[q][0]+' row'); continue; }
         ix=gameOptLive(WANT[q][0]);
         if(ix<0||!r.opts[ix]||r.opts[ix].n!==WANT[q][1]) bad.push(tag+': '+WANT[q][0]+' stands on '+(ix>=0&&r.opts[ix]?r.opts[ix].n:'custom')+', not '+WANT[q][1]);
       }
       if(diffNow()!=='new player') bad.push(tag+': difficulty reads '+diffNow()+', not new player');
     }
     for(k in CFG) cfg[k]=CFG[k];
     for(i=0;i<GAMEOPTS.length;i++) defs.push(GAMEOPTS[i].def);
     try{
       window.matchMedia=function(q){ if(q==='(prefers-reduced-motion: reduce)') return {matches:false,media:q}; return om?om.call(window,q):{matches:false,media:q}; };
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       go0=JSON.parse(JSON.stringify(P.gameOpts||{}));
       // ONE: a brand new profile (born from the profile literal: np1 set, nothing chosen) opens on his settings page
       newpHome();
       P.gameOpts={flashRed:1}; P.tuned={}; P.np1=1; P.cfg=null; applyGameOpts();
       onList('ONE new profile');
       need(Math.round(diffMulOf(CFG)*100)/100===1.05,'ONE: a new profile pays x'+diffMulOf(CFG)+', not x1.05 (superhot off only)');
       need(CFG.eDmg===0.7&&CFG.raidSec===900&&CFG.lootMult===1.35&&CFG.nRaider===5&&CFG.nSentry===12&&CFG.siegeVol===0.6&&CFG.sharedSight===1&&CFG.fogWar===0&&CFG.superhot===0&&CFG.textEdit===0,'ONE: the dials of a new profile are not the list (eDmg '+CFG.eDmg+', raidSec '+CFG.raidSec+', lootMult '+CFG.lootMult+', nRaider '+CFG.nRaider+', nSentry '+CFG.nSentry+', siegeVol '+CFG.siegeVol+')');
       for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k!=='flashRed'&&Object.prototype.hasOwnProperty.call(P.gameOpts,GAMEOPTS[i].k)) bad.push('ONE: the new profile saved '+GAMEOPTS[i].k+' as a pick');
       // TWO: the same profile saved and loaded again stays on the list (nothing pins the old set onto it)
       snap=JSON.parse(JSON.stringify(P)); snap.cfg=JSON.parse(JSON.stringify(CFG)); snap.cfgv=18;
       applyLoadedProfile({value:JSON.stringify(snap)});
       onList('TWO new profile reloaded');
       // THREE: a save from before this build that never picked these rows keeps the main game it played on
       snap=JSON.parse(JSON.stringify(P)); delete snap.np1; snap.gameOpts={flashRed:0}; snap.tuned={}; snap.cfg=null;
       applyLoadedProfile({value:JSON.stringify(snap)});
       need(diffNow()==='main game','THREE: an old save with nothing picked moved to '+diffNow()+', not the main game it played');
       need(CFG.eDmg===1&&CFG.raidSec===540&&CFG.lootMult===1&&CFG.xhSz===1,'THREE: an old save lost its dials (eDmg '+CFG.eDmg+', raidSec '+CFG.raidSec+', lootMult '+CFG.lootMult+', xhSz '+CFG.xhSz+')');
       need(P.np1===1&&P.gameOpts.hits===2&&P.gameOpts.clock===1&&P.gameOpts.loot===1,'THREE: the old set was not kept as its picks');
       need(gameOptIx('raiders')===2&&gameOptIx('sharedSight')===0,'THREE: rows that did not change moved');
       applyLoadedProfile({value:JSON.stringify(P)});
       need(diffNow()==='main game','THREE: the old save moved on its second load');
       // FOUR: his save (new player picked, standard pillagers, fog of war on) keeps every choice it has, nothing added among his picks
       snap=JSON.parse(JSON.stringify(P)); delete snap.np1; snap.tuned={}; snap.cfg=null;
       snap.gameOpts={flashRed:1,raiders:1,fogWar:1}; for(k in ITCH_EASY) snap.gameOpts[k]=ITCH_EASY[k];
       var mine=JSON.stringify(snap.gameOpts);
       applyLoadedProfile({value:JSON.stringify(snap)});
       need(JSON.stringify(P.gameOpts)===mine,'FOUR: his choices changed on load: '+JSON.stringify(P.gameOpts));
       need(CFG.nRaider===10&&CFG.fogWar===1&&CFG.eDmg===0.7,'FOUR: his dials are not his choices (nRaider '+CFG.nRaider+', fogWar '+CFG.fogWar+', eDmg '+CFG.eDmg+')');
       // FIVE: every demo start, either window, takes the list; leaving puts the career choices back
       for(j=0;j<2;j++){
         P.gameOpts={flashRed:1,hits:0,raiders:0,robots:0,ext:0,clock:2,loot:2,sharedSight:1,fogWar:1,xhSz:0,xfAffix:0}; P.tuned={nRaider:15}; applyGameOpts(); CFG.nRaider=15;
         var car=JSON.stringify(P.gameOpts);
         if(!arcadeSandboxIn(j?'p2':'host')) throw new Error('staging: the demo sandbox did not open');
         onList('FIVE demo '+(j?'player 2':'player 1'));
         need(CFG.eDmg===0.7&&CFG.nRaider===5&&CFG.nSentry===12&&CFG.siegeVol===0.6&&CFG.lootMult===1.35&&CFG.sharedSight===1&&CFG.fogWar===0&&CFG.superhot===0&&CFG.xfAffix===0,'FIVE: the demo dials for '+(j?'player 2':'player 1')+' are not the list (eDmg '+CFG.eDmg+', nRaider '+CFG.nRaider+', siegeVol '+CFG.siegeVol+', fogWar '+CFG.fogWar+')');
         need(Math.round(diffMulOf(CFG)*100)/100===1.05,'FIVE: the demo pays x'+diffMulOf(CFG)+' for '+(j?'player 2':'player 1'));
         applyGameOpts(); onList('FIVE demo after a settings pass '+(j?'player 2':'player 1'));
         arcadeSandboxOut();
         need(JSON.stringify(P.gameOpts)===car,'FIVE: leaving the demo changed the career choices: '+JSON.stringify(P.gameOpts));
         need(CFG.eDmg===1.4&&CFG.nRaider===15&&CFG.fogWar===1,'FIVE: leaving the demo did not put the career dials back (eDmg '+CFG.eDmg+', nRaider '+CFG.nRaider+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(ARCADE.on) arcadeSandboxOut(); }catch(_a){}
       window.matchMedia=om;
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       try{ P.gameOpts=go0||P.gameOpts; P.tuned={}; }catch(_g){}
       for(i=0;i<GAMEOPTS.length&&i<defs.length;i++) GAMEOPTS[i].def=defs[i];
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ KEYS.inv=null; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
