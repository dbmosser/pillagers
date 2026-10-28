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

if ($s.Contains("  {v:'35.44',what:")) { throw "check 35.44 is in the fixture already" }

SubRx @'
  {v:'35.43',what:
'@ @'
  {v:'35.44',what:'cw-msgroute, his complaint 2026-10-27 (too many messages reach the player), the research rule: only the ladder reaches the screen (danger or teammate down, extraction, teammate news, a goal done, the answer to something that did not work); a codex entry, location revealed and running slowly draw nothing and stay in the run log, which the pause box lists; danger draws at once; the left feed shows at most 3 lines, each gone after 5 s, and takes one new line every 2.5 s; an answer and contract item nearby go in at once; teammate news that waited over 4 s is dropped; a goal done waits out the fight and shows as one line; kill lines stay; a search of several items still draws one pickup row per item (looting untouched); his order 10-27 ~22:35: an exit over 200 m away closing draws nothing, the exit you are heading to closing still draws its line',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof feedSay!=='function'||typeof feedTick!=='function'||typeof feedDraw!=='function'||typeof feedKillLine!=='function'||typeof pickSay!=='function'||typeof codexScan!=='function'||typeof openContainer!=='function'||typeof togglePauseBox!=='function') return 'SKIP: no feed, pickup stack, codex or pause box here';
     var bad=[], g, p, i, ik, it0, ks=[], box=null, oCN=codexNote, oSP=saveProfile, GK='', rows0, made=0, el, L, pb=false;
     function feedHas(s){ var F=(g.fd&&g.fd.lines)||[], c=0; for(var j=0;j<F.length;j++) if(String(F[j].txt).indexOf(s)>=0) c++; return c; }
     function onTop(s){ return !!(g.alert&&g.alert.T>0&&g.alert.m===s); }
     function logHas(s){ var M=g.msgLog||[]; for(var j=0;j<M.length;j++) if(M[j].m===s) return true; return false; }
     function clr(){ g.fd={t:0,seq:0,lines:[]}; g.alert=null; g.alertQ=[]; g.pick=[]; g.msgLog=[]; p.combatT=99; }
     function drawn(){ feedDraw(); return (FEEDBOX&&FEEDBOX.rows)?FEEDBOX.rows.length:-1; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.ents.length=0; g.waveT=-1e9;
       // ONE: the lines off the ladder draw nothing, and stay in the run log
       clr(); say('RUNNING SLOWLY','sys'); say('LOCATION REVEALED');
       if(feedHas('RUNNING SLOWLY')||onTop('RUNNING SLOWLY')) bad.push('RUNNING SLOWLY still draws a line');
       if(feedHas('LOCATION REVEALED')||onTop('LOCATION REVEALED')) bad.push('LOCATION REVEALED still draws a line');
       if(!logHas('RUNNING SLOWLY')) bad.push('control: RUNNING SLOWLY is not in the run log');
       for(ik in ITEMS) if(ITEMS[ik]&&ITEMS[ik].use==='gun'&&ITEMS[ik].gk){ GK=ik; break; }
       if(!GK) bad.push('control: no gun item to stage a codex entry');
       else {
         clr(); codexNote=function(w){ return w===ITEMS[GK].gk; }; saveProfile=function(){}; g.bag.push(GK);
         try{ codexScan(); } finally { codexNote=oCN; saveProfile=oSP; i=g.bag.lastIndexOf(GK); if(i>=0) g.bag.splice(i,1); }
         if(feedHas('CODEX ENTRY')||onTop('CODEX ENTRY')) bad.push('a codex entry still draws a line');
       }
       // TWO: danger draws at once
       clr(); say('ZQ DANGER','warn');
       if(!onTop('ZQ DANGER')) bad.push('a danger line does not draw at once');
       g.alert=null; say('ZQ CRIT','crit');
       if(!onTop('ZQ CRIT')) bad.push('a crit does not draw at once');
       // THREE (looting untouched, holds on both builds): a search of three items draws one pickup row per item
       for(ik in ITEMS){ it0=ITEMS[ik]; if(it0&&!it0.gk&&!it0.use&&it0.val>0) ks.push(ik); if(ks.length>=3) break; }
       for(i=0;i<g.containers.length;i++){ var c=g.containers[i]; if(c&&!c.opened&&!c.cache&&!c.strong&&!c.auto){ box=c; break; } }
       if(ks.length<3||!box) bad.push('control: no three items or no box to stage a search');
       else {
         clr(); box.loot=ks.slice(); rows0=[];
         for(i=0;i<3;i++){ box.loot.shift(); openContainer(box,[ks[i]]); for(var r0=0;r0<g.pick.length;r0++) if(rows0.indexOf(g.pick[r0])<0){ rows0.push(g.pick[r0]); made++; } }
         if(made!==3) bad.push('a search of three items drew '+made+' pickup rows, not one per item ('+JSON.stringify(g.pick.map(function(r){ return r.m+(r.sub?' / '+r.sub:''); }))+')');
       }
       // FOUR: one new feed line every 2.5 s; an answer and contract item nearby at once; teammate news that waited over 4 s is dropped
       clr(); say('ZQ ONE RECEIVED','info'); say('ZQ TWO RECEIVED','info');
       if(feedHas('ZQ ONE RECEIVED')!==1) bad.push('control: a teammate line did not reach the feed');
       if(feedHas('ZQ TWO RECEIVED')) bad.push('two lines in one second draw two feed lines');
       feedTick(2.6);
       if(feedHas('ZQ TWO RECEIVED')!==1) bad.push('the second line did not follow 2.5 s later');
       say('HEALTH FULL');
       if(feedHas('HEALTH FULL')!==1) bad.push('the answer HEALTH FULL waits behind another line');
       say('CONTRACT ITEM NEARBY','obj',{sub:'GOLD GLOW MARKS THE BOX',key:'needhint'});   // as the contract item hint says it
       if(feedHas('CONTRACT ITEM NEARBY')!==1) bad.push('contract item nearby no longer shows at once');
       clr(); say('ZQ A RECEIVED','info'); say('ZQ B RECEIVED','info'); say('ZQ C RECEIVED','info');
       for(i=0;i<4;i++) feedTick(2.6);
       if(feedHas('ZQ B RECEIVED')!==1) bad.push('control: the second waiting line never drew');
       if(feedHas('ZQ C RECEIVED')) bad.push('a teammate line that waited over 4 s still drew');
       // FIVE: a goal done waits until no shot was fired or taken for 4 s, then the goals done are one line
       clr(); p.combatT=0; say('CONTRACT DONE','obj'); say('GOAL DONE','obj');
       if(feedHas('CONTRACT DONE')||feedHas('GOAL DONE')) bad.push('a goal done line drew in the middle of a fight');
       p.combatT=1; feedTick(3);
       if(feedHas('CONTRACT DONE')||feedHas('GOAL DONE')) bad.push('a goal done line drew before the fight was over');
       p.combatT=5; feedTick(0.1);
       if(g.fd.lines.length!==1||feedHas('CONTRACT DONE')!==1||feedHas('GOAL DONE')!==1) bad.push('the goals done after the fight are not one line ('+JSON.stringify(g.fd.lines.map(function(l){ return l.txt; }))+')');
       // SIX: at most three feed lines, each gone after 5 s; a kill line still reaches the feed
       clr(); for(i=0;i<5;i++) feedAdd([{t:'ZQ LINE '+i,c:null}],'info',{});
       i=drawn(); if(i!==3) bad.push('five feed lines up draw '+i+' lines, not 3');
       feedTick(5.2); i=drawn(); if(i!==0) bad.push('feed lines 5.2 s old still draw ('+i+')');
       clr(); feedKillLine('YOU',true,false,'ZQ BOT',HUDC.danger,'');
       if(!feedHas('ZQ BOT')) bad.push('a kill line no longer reaches the feed');
       // EIGHT (his order 10-27 ~22:35): an exit far across the map closing draws nothing; the exit you are heading to closing still draws its line
       var zs=g.zones||[], zA=null, zB=null, sv=[], oTL=g.timeLeft, oAct=g.active, oX=p.x, oY=p.y, nm;
       function xHas(s){ var q=g.alertQ||[], j; if(onTop(s)||feedHas(s)) return true; for(j=0;j<q.length;j++) if(q[j].m===s) return true; return false; }
       for(i=0;i<zs.length&&!zA;i++) for(var j2=0;j2<zs.length;j2++) if(i!==j2&&dist(zs[i],zs[j2])>200*U_PER_M){ zA=zs[i]; zB=zs[j2]; break; }
       if(!zA) bad.push('control: no two exits 200 m apart');
       else {
         for(i=0;i<zs.length;i++) sv.push({z:zs[i],c:zs[i].closeAt,w:zs[i].warned,o:zs[i].open,b:zs[i].beaconT});
         try{
           clr(); g.msgT=0; g.msgQ=[]; p.x=zB.x; p.y=zB.y; g.active=zB;
           for(i=0;i<zs.length;i++){ zs[i].closeAt=undefined; zs[i].beaconT=null; }
           zA.closeAt=g.timeLeft-60; zA.warned=0; zA.open=true;   // inside its two minute warning, not shut yet
           tickExtractPoints(0); nm='EXTRACTION '+extLetter(zA)+' CLOSING';
           if(xHas(nm)) bad.push('an exit over 200 m away closing still draws '+nm);
           if(!logHas(nm)) bad.push('control: the far exit closing is not in the run log');
           clr(); g.msgT=0; g.msgQ=[]; zA.closeAt=undefined; zB.closeAt=g.timeLeft-60; zB.warned=0; zB.open=true;
           tickExtractPoints(0); nm='EXTRACTION '+extLetter(zB)+' CLOSING';
           if(!xHas(nm)) bad.push('the exit you are heading to closing no longer draws '+nm);
         } finally {
           for(i=0;i<sv.length;i++){ sv[i].z.closeAt=sv[i].c; sv[i].z.warned=sv[i].w; sv[i].z.open=sv[i].o; sv[i].z.beaconT=sv[i].b; }
           g.timeLeft=oTL; g.active=oAct; p.x=oX; p.y=oY;
         }
       }
       // SEVEN: the pause box lists the run log
       clr(); say('ZQ LOG ONLY');
       togglePauseBox(true); pb=true; el=document.getElementById('pauselog'); L=el?String(el.textContent):'';
       if(!el||el.style.display==='none'||L.toLowerCase().indexOf('zq log only')<0) bad.push('the pause box does not list the run log ('+JSON.stringify(L.slice(0,80))+')');
       togglePauseBox(false); pb=false;
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       codexNote=oCN; saveProfile=oSP; keys={};
       try{ if(pb) togglePauseBox(false); }catch(_e0){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
