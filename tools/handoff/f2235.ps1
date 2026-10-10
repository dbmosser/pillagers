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

if ($s.Contains("  {v:'22.35',what:")) { throw "check 22.35 is in the fixture already" }

SubRx @'
  {v:'22.34',what:
'@ @'
  {v:'22.35',what:'party emergencies never wait: a teammate going down while two rows and three waiting lines are up shows TEAMMATE DOWN as the alert on the next frame with his name in the detail, it holds past its normal life while he stays down, and it goes once he is up',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot deploy, step or draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof netOnState!=='function'||typeof padRumble!=='function'||typeof NET!=='object'||!NET) return 'SKIP: this build has no party words';
     var NK={}, k, bad=[], g, realSay=say, oRum=padRumble, oName=netSeatName, oFT=ctx.fillText, peer={seat:1,state:'in'}, w, gg=null, t0, f=0, i, j, ev=[], TD=['TEAMMATE','DOWN'].join(' '), drawn=false, a;
     function step(){ __loop(t0+(++f)*50); }
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       NET.on=false; NET.role=null; NET.peers=[];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9; g.player.iv=99;
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('MOTH')===0||s.indexOf('TEAMMATE')===0) return realSay.apply(this,arguments); };
       padRumble=function(){ return 'test'; };
       netSeatName=function(s){ return s===1?'MOTH':(s===0?'HOST':null); };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.msgAt=undefined; g.msgKey=''; g.alert=null; g.alertQ=[];
       say('zq r1'); say('zq r2');
       sayWhenFree('zq q1'); sayWhenFree('zq q2'); sayWhenFree('zq q3');
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.up=[]; NET.floor=NET.floor||[];
       w={t:'st',k:'r',x:Math.round(g.player.x)+60,y:Math.round(g.player.y),f:0,sd:g.seed>>>0,dn:0,hp:100,mh:100};
       netOnState(peer,w); netOnState(peer,w); w.dn=1; netOnState(peer,w);
       gg=NET.up&&NET.up[1];
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       step(); step(); step();   // the next frames, past the fade in
       ev=[]; ctx.fillText=function(t){ ev.push(String(t)); return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       for(j=0;j<ev.length;j++) if(ev[j]===TD) drawn=true;
       a=g.alert;
       if(!drawn) bad.push('a teammate going down behind two rows and three waiting lines did not draw '+TD+' within 0.15 s (alert '+JSON.stringify(a&&a.m)+')');
       if(!(a&&a.m===TD&&a.k==='crit'&&String(a.sub||'').indexOf('MOTH')>=0)) bad.push('the alert is not '+TD+' as a critical line naming MOTH ('+JSON.stringify(a&&{m:a.m,k:a.k,sub:a.sub})+')');
       if(!gg) bad.push('SKIP: staging: the teammate state was not filed');
       else {
         for(i=0;i<100;i++){ step(); if(g.over) break; }   // 5 s more, past the 4.5 s of a critical line, while he stays down
         a=g.alert;
         if(!(a&&a.T>0&&a.m===TD)) bad.push('with the teammate still down after 5 s, '+TD+' is gone (alert '+JSON.stringify(a&&{m:a.m,T:a.T})+')');
         gg.dn=0;
         for(i=0;i<12;i++){ step(); if(g.over) break; }
         a=g.alert;
         if(a&&a.T>0&&a.m===TD) bad.push('0.6 s after the teammate is up, '+TD+' still shows');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; padRumble=oRum; netSeatName=oName; keys={};
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgKey=''; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
