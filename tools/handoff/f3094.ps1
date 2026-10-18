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

if ($s.Contains("  {v:'30.94',what:")) { throw "check 30.94 is in the fixture already" }

SubRx @'
  {v:'30.93',what:
'@ @'
  {v:'30.94',what:'cw-nomimic, his note (2026-10-18, in a raid): "get rid of the mimics, its just too confusing". No box is a mimic: raids dealt in the career and the arcade on several seeds with an old profile that had mimic on, every closed box stood beside and then searched on the real hold E path. No faint tick, no crawler comes out, no MIMIC line, no void swirl, and no settings row for them',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof arcadeDeploy!=='function') return 'SKIP: no raid here';
     var bad=[], plan=[[0,6,0],[0,4242,0],[0,12,1],[0,7,1],[1,19,0]], r, i, j, k, g, p, ct, tag, boxes, lines=[], ticks=[], n, woke, ticked, said, oSay=say, oFoley=foley, ks=keys, md=mouse.down, cfg0=P.cfg, nBox=0, nOpen=0, rows='', x;
     function sweep(pr){
       tag=(pr[2]?'arcade':'career')+' map '+pr[0]+' seed '+pr[1];
       __topClear(); __runPrep(); __resetCfg();
       P.cfg={mimic:1}; try{ applyCfg(DEF,P.cfg); }catch(_ac){}   // an old save that had mimic on, loaded the way the game loads a profile
       if(CFG.mimic===1) bad.push(tag+': a profile that saved mimic on loaded it back as on');
       CFG.mimic=1;   // and even if something did carry it through, no box may be a mimic
       __pinDefaults(pr[0]); __cleanProfile();
       if(pr[2]){ if(!arcadeDeploy({mapIx:pr[0],seed:pr[1]})){ bad.push(tag+': arcadeDeploy built no arcade raid'); return; } }
       else __deploy({kit:[],safe:null,mapIx:pr[0],seed:pr[1]});
       g=__state(); if(!g||g.over||!g.player){ bad.push(tag+': no live raid'); return; }
       p=g.player; p.iv=99; p.hp=100; p.downed=false; keys={}; g.ents=[];
       boxes=g.containers.filter(function(c){ return c&&!c.opened&&!c.mercSrc; });
       if(pr[1]===19) boxes=boxes.filter(function(c,ix){ return ix%5===0; });   // the big map: one box in five
       woke=0; ticked=0; said=0; n=0; lines.length=0;
       for(i=0;i<boxes.length;i++){
         ct=boxes[i]; if(ct.opened) continue;
         n++; g.ents=[]; keys={}; p.vx=0; p.vy=0; ticks.length=0;
         if(ct.type==='crate'||ct.type==='locker'){   // a mimic ticks within 1.2 s of you coming near
           p.x=ct.x+60; p.y=ct.y;
           for(j=0;j<14;j++) __sim(0.1);
           if(ticks.some(function(t){ return Math.hypot(t.x-ct.x,t.y-ct.y)<2; })) ticked++;
         }
         g.ents=[]; g.bag.length=0; p.x=ct.x; p.y=ct.y; p.vx=0; p.vy=0; keys={KeyE:true};
         for(j=0;j<Math.ceil((ct.time||2)/0.1)+8&&!ct.opened;j++){ __sim(0.1); g.bag.length=0; }
         keys={};
         if(ct.opened) nOpen++; nBox++;
         for(k=0;k<g.ents.length;k++){ x=g.ents[k]; if(x&&(x.mimic||x.kind==='crawler'||/mimic/i.test(String(x.name)))){ woke++; break; } }
         if(ct.mim||ct.mimicDone||ct.mimicWake||ct.mimicVoid!==undefined) said++;
       }
       if(lines.some(function(t){ return /mimic/i.test(t); })) bad.push(tag+': the raid said MIMIC ('+lines.filter(function(t){ return /mimic/i.test(t); })[0]+')');
       if(woke) bad.push(tag+': '+woke+' of '+n+' boxes let a crawler out when searched');
       if(ticked) bad.push(tag+': '+ticked+' boxes ticked as a player stood near them');
       if(said) bad.push(tag+': '+said+' boxes carry a mimic mark');
       for(k=0;k<g.containers.length;k++) if(g.containers[k].mimicVoid>0){ bad.push(tag+': a spent box is swirling away'); break; }
     }
     try{
       say=function(t){ lines.push(String(t)); };
       foley=function(role,x,y,o){ if(role==='pinClick'&&typeof x==='number'&&typeof y==='number') ticks.push({x:x,y:y}); return true; };
       try{ rows=JSON.stringify(window.__opts?__opts.rows():[]).toLowerCase(); }catch(_rw){ rows=''; }
       if(rows.indexOf('mimic')>=0) bad.push('the settings still have a row for mimics');
       if('mimic' in DEF) bad.push('the settings defaults still carry mimic');
       for(r=0;r<plan.length;r++){
         try{ sweep(plan[r]); }catch(x2){ bad.push('threw on raid '+(r+1)+': '+(x2&&x2.message||x2)); }
         try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
         try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       }
       if(nOpen<nBox*0.8) bad.push('only '+nOpen+' of '+nBox+' boxes opened on the hold E path, so the sweep tested little');
       return bad.length?bad.slice(0,8).join('; '):null;
     } finally {
       say=oSay; foley=oFoley; keys=ks; mouse.down=md; P.cfg=cfg0; try{ delete CFG.mimic; }catch(_d){}
       try{ if(typeof ARCADE==='object'){ if(ARCADE.on) arcadeLeave(); ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_l2){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       __resetCfg(); __topClear();
     } }},
  {v:'30.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
