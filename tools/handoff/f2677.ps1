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

if ($s.Contains("  {v:'26.77',what:")) { throw "check 26.77 is in the fixture already" }

SubRx @'
  {v:'26.76',what:
'@ @'
  {v:'26.77',what:'his yes (suggestion 27): rarely a crate or locker is a mimic (a fixed few per raid, chosen by position and seed with no random draw): starting to search it wakes a crawler that goes for the player, a faint tick sounds near it, it wakes once, and an ordinary box does nothing',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof mkCrawler!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, i, k, ct, n=0, tot=0, nBox=0, mim=null, plain=null, seed0, found=false, crawlers, calls=[], oFoley, hadFoley, c2, s;
     function mimicCrawlers(){ var q=0, j; for(j=0;j<g.ents.length;j++) if(g.ents[j].mimic) q++; return q; }
     try{
       if(typeof isMimic!=='function'||typeof mimicTick!=='function') return 'there are no mimic containers';
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false; all=g.ents.slice(); seed0=G.seed;
       for(i=0;i<g.containers.length;i++){
         ct=g.containers[i];
         if(ct.type==='crate'||ct.type==='locker'){ nBox++; if(isMimic(ct)){ n++; if(!mim) mim=ct; } else if(!plain&&!ct.opened) plain=ct; }
         else if(isMimic(ct)) bad.push('a '+ct.type+' is a mimic (only crates and lockers can be)');
       }
       tot=0; for(s=1;s<=40;s++){ G.seed=s; for(i=0;i<g.containers.length;i++){ ct=g.containers[i]; if((ct.type==='crate'||ct.type==='locker')&&isMimic(ct)) tot++; } }
       G.seed=seed0;
       if(!(tot>=nBox*40*0.008&&tot<=nBox*40*0.045)) bad.push('across 40 seeds '+tot+' of '+(nBox*40)+' crates and lockers are mimics; expected about 2 percent');
       if(mim&&(isMimic(mim)!==true||isMimic(mim)!==true)) bad.push('whether a box is a mimic changes from one ask to the next');
       if(!mim){
         for(s=1;s<4000&&!found;s++){
           G.seed=s;
           for(i=0;i<g.containers.length&&!found;i++){ ct=g.containers[i]; if(ct.type==='crate'&&!ct.opened&&isMimic(ct)){ mim=ct; found=true; } }
         }
         if(!found) return bad.length?bad.join('; '):'SKIP: could not find a mimic';
       }
       // wake: a mimic being searched produces one crawler for the player, and only one
       for(k in keys) keys[k]=false;
       delete mim.mim; delete mim.mimicDone; mim.prog=0; mim.opened=false; mim.loot=mim.loot||[]; mim.pulled=0;
       g.ents=[]; p.x=mim.x+60; p.y=mim.y; p.vx=0; p.vy=0;
       __sim(1/60);
       if(mimicCrawlers()) bad.push('a mimic woke before anyone searched it');
       mim.prog=0.2;
       for(i=0;i<30;i++) __sim(1/60);
       if(mimicCrawlers()) bad.push('the mimic woke in half a second; it should wait 0.8 s');
       for(i=0;i<40;i++) __sim(1/60);
       if(mimicCrawlers()!==1) bad.push('0.8 s after the search began the mimic made '+mimicCrawlers()+' crawlers, not 1');
       else {
         c2=g.ents.filter(function(x){ return x.mimic; })[0];
         if(c2.state!=='chase') bad.push('the crawler out of the mimic is '+c2.state+', not hunting');
         if(dist(c2,mim)>160) bad.push('the crawler appeared '+Math.round(dist(c2,mim))+' from the box');
       }
       for(i=0;i<200;i++) __sim(1/60);
       if(mimicCrawlers()>1) bad.push('the mimic woke more than once');
       // an ordinary box does nothing
       if(plain){
         G.seed=seed0; delete plain.mim;
         if(isMimic(plain)) { /* seed restored may make it a mimic: pick by hash instead */ plain=null; }
       }
       if(plain){
         g.ents=[]; plain.prog=0.3; p.x=plain.x+60; p.y=plain.y;
         for(i=0;i<120;i++) __sim(1/60);
         if(g.ents.some(function(x){ return x.kind==='crawler'; })) bad.push('searching an ordinary crate woke a crawler');
         plain.prog=0;
       }
       // the faint tick
       G.seed=seed0; g.ents=[];
       hadFoley=Object.prototype.hasOwnProperty.call(window,'foley'); oFoley=foley;
       foley=function(role,x,y,o){ calls.push({r:role,g:o&&o.g}); return true; };
       try{
         mim.mimicDone=0; mim.mimicWake=0; mim.prog=0; mim.mim=1; mim.tkT=undefined; p.x=mim.x+60; p.y=mim.y; p.downed=false;
         for(i=0;i<420;i++) __sim(1/60);
         if(!calls.some(function(c){ return c.r==='pinClick'&&c.g>0&&c.g<=0.3; })) bad.push('standing 60 from a sleeping mimic for seven seconds made no faint tick');
         calls.length=0; p.x=mim.x+400; p.y=mim.y; mim.tkT=undefined;
         for(i=0;i<420;i++) __sim(1/60);
         if(calls.some(function(c){ return c.r==='pinClick'; })) bad.push('a mimic ticked at a player 400 away');
       } finally { foley=oFoley; }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof oFoley==='function') foley=oFoley; }catch(_e0){}
       try{ if(typeof seed0!=='undefined') G.seed=seed0; }catch(_e1){}
       try{ if(g&&all){ g.ents=all; g.bullets.length=0; } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
