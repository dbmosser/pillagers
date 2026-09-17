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
  {v:'15.28',what:
'@ @'
  {v:'15.29',what:'a pillager going down sounds where he falls: one downed 60 units west of you is still heard close by on your left, and one downed 1400 units east of you plays the hit sound at his distance, out of earshot and on your right, or not at all, never the full volume centred hit you hear when you are hit (sound audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updateEnts!=='function'||typeof blip!=='function'||typeof raiderDownHp!=='function') return 'SKIP: no entity update, blip or downed pillager in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, e=null, keepE=null, keepEnts=null, _blip=blip, hits=[], i;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // One entity update with only this pillager in the raid, at no health, dx units east of you (west when dx is negative).
     var down=function(dx){
       var p=g.player, hp0=p.hp;
       e.x=p.x+dx; e.y=p.y; e.hp=0; e.downed=0; e.finished=0; e.state='loot'; e.bag=[]; e.healQ=0; e.kitT=99;
       g.ents=[e]; hits.length=0;
       updateEnts(0.016);
       return {took:(e.downed===1&&e.state==='down'), hurt:(p.hp!==hp0)};
     };
     var side=function(h){ return 'distance '+h.d.toFixed(1)+' and pan '+h.pan.toFixed(3); };
     // What a hit sound with no distance or no pan is, in words; null when it carries both.
     var unplaced=function(h,where){
       if(typeof h.d!=='number') return 'a pillager downed '+where+' of you played the hit sound with no distance, at full volume'+(typeof h.pan!=='number'?' and centred':'')+', the same hit you hear when you are hit';
       if(typeof h.pan!=='number') return 'a pillager downed '+where+' of you played the hit sound at distance '+h.d.toFixed(1)+' with no pan, centred';
       return null;
     };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.ents) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the raid is a sim, and a sim plays no sound';
       // CONTROL: pillagers go down rather than die here, so the downed branch is live.
       if(CFG.raiderDown===0) return 'SKIP: pillagers die outright here, so none goes down';
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].downed&&!g.ents[i].finished&&!g.ents[i].merc) e=g.ents[i];
       if(e) keepE={x:e.x,y:e.y,hp:e.hp,downed:e.downed,downT:e.downT,finished:e.finished,state:e.state,alert:e.alert,goal:e.goal,cd:e.cd,bag:e.bag,healQ:e.healQ,kitT:e.kitT};
       else if(typeof mkRaider==='function'){ try{ e=mkRaider(g.player.x,g.player.y,null,true); }catch(_m){ e=null; } }
       if(!e) return 'SKIP: no pillager to put on the floor';
       keepEnts=g.ents;
       blip=function(t,d,pan){ if(String(t)==='hit') hits.push({d:d,pan:pan}); try{ return _blip.apply(null,arguments); }catch(_b){} };
       // NEAR: 60 units west. CONTROL: he went down on that update, you took nothing, and the recorder heard exactly one hit
       // sound, on either build, so a man downed beside you is heard and this recorder hears it.
       var near=down(-60);
       if(!near.took) return skip('a pillager at no health 60 units west did not go down on one entity update here (downed '+e.downed+', state '+e.state+')');
       if(near.hurt) return skip('you lost health on the entity update, so the hit sound cannot be told from a hit on you here');
       if(hits.length!==1) return skip('the recorder heard '+hits.length+' hit sounds when a pillager went down 60 units west, not one, so it cannot hear this sound here');
       var hn=hits[0];
       // THE FIX, NEAR: still heard close by, on his side.
       var un=unplaced(hn,'60 units west');
       if(un) bad.push(un+', not close by on your left');
       else if(!(hn.d>=59&&hn.d<=150&&hn.pan<0)) bad.push('a pillager downed 60 units west of you played the hit sound at '+side(hn)+', not close by on your left');
       // FAR: 1400 units east, well past where blip fades to nothing (about 880).
       var far=down(1400);
       if(!far.took) return skip('a pillager at no health 1400 units east did not go down on one entity update here (downed '+e.downed+', state '+e.state+')');
       if(far.hurt) return skip('you lost health on the second entity update, so the hit sound cannot be told from a hit on you here');
       // THE FIX, FAR: no hit sound at all, or one at his distance, out of earshot, on your right.
       if(hits.length>1) bad.push('a pillager downed 1400 units east of you played the hit sound '+hits.length+' times');
       else if(hits.length===1){
         var hf=hits[0], uf=unplaced(hf,'1400 units east');
         if(uf) bad.push(uf+', with nothing on screen and no health lost');
         else if(!(hf.d>=882&&hf.pan>0)) bad.push('a pillager downed 1400 units east of you played the hit sound at '+side(hf)+', not out of earshot on your right');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       blip=_blip;
       try{ if(g&&keepEnts) g.ents=keepEnts; }catch(_n){}
       try{ if(e&&keepE){ e.x=keepE.x; e.y=keepE.y; e.hp=keepE.hp; e.downed=keepE.downed; e.downT=keepE.downT; e.finished=keepE.finished; e.state=keepE.state; e.alert=keepE.alert; e.goal=keepE.goal; e.cd=keepE.cd; e.bag=keepE.bag; e.healQ=keepE.healQ; e.kitT=keepE.kitT; } }catch(_k){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
