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

if ($s.Contains("  {v:'22.13',what:")) { throw "check 22.13 is in the fixture already" }

SubRx @'
  {v:'22.12',what:
'@ @'
  {v:'22.13',what:'the alert lane: the Crier line is an alert headline on the danger plate at a steady alpha, the flashing marked row is gone, and an ordinary line said under it goes to the feed and does not displace it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot deploy, step or draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof mkSnitch!=='function'||typeof hudPlate!=='function') return 'SKIP: no Crier or no plate here';
     var bad=[], g, p, cr, i, j, t0, f=0, realSay=say, oFT=ctx.fillText, oPl=hudPlate, ev=[], pl=[], KW='KNOW WHERE YOU '+'ARE', RV='CRIER '+'REVEALED', LOOT=['zq','loot'].join(' '),
         head='', alphas=[], dangerN=0, kw=false, after=null, lootSeen=false, DP=String(HUDC.dangerPlate||'');
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; hudPlate=oPl; }
     function draw(){
       ev=[]; pl=[];
       ctx.fillText=function(t){ ev.push({t:String(t),a:ctx.globalAlpha}); return oFT.apply(this,arguments); };
       hudPlate=function(x,y,w,h,ac,fill){ pl.push(String(fill||'')); return oPl.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       for(var k=0;k<ev.length;k++) if(ev[k].t.indexOf(KW)>=0) kw=true;
     }
     function rv(){ for(var k=0;k<ev.length;k++) if(ev[k].t.indexOf(RV)===0) return ev[k]; return null; }
     function step(){ __loop(t0+(++f)*50); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9; p.iv=99;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[]; g.marked=0;
       // only the Crier lines and the probe line may speak
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('CRIER')===0||s.indexOf('A CRIER')===0) return realSay.apply(this,arguments); };
       cr=mkSnitch(p.x+240,p.y); cr.state='alarm'; cr.wind=0.01; cr.lost=0; cr.markX=p.x; cr.markY=p.y; g.ents.push(cr);
       __ents(0.05);
       g.ents.length=0;   // the Crier and the machines it called are gone, so nothing else speaks
       if(!(g.marked>0)) return 'SKIP: staging: the Crier did not fire its mark';
       t0=Math.max(performance.now(),(typeof lastTs==="number"&&isFinite(lastTs))?lastTs:0);   // never behind the frame clock a check before left
       for(i=0;i<4;i++){ step(); if(g.over) break; }   // past the fade in
       for(i=0;i<4&&!g.over;i++){
         step(); draw();
         var e=rv();
         if(!e){ bad.push('frame '+i+': no Crier headline was drawn'); continue; }
         head=e.t; alphas.push(Math.round(e.a*1000)/1000);
         for(j=0;j<pl.length;j++) if(pl[j]&&pl[j]===DP){ dangerN++; break; }
       }
       if(head&&!/^CRIER REVEALED YOUR (LAST )?LOCATION$/.test(head)) bad.push('the Crier headline reads '+JSON.stringify(head));
       for(i=1;i<alphas.length;i++) if(Math.abs(alphas[i]-alphas[0])>0.001){ bad.push('the Crier line flickers: its alpha over four frames 0.05 s apart is '+alphas.join(', ')); break; }
       if(alphas.length&&alphas[0]<0.99) bad.push('the Crier line is drawn at alpha '+alphas[0]+', not full');
       if(dangerN<4) bad.push('the Crier line sat on the danger plate in '+dangerN+' of 4 frames');
       if(kw) bad.push('a drawn line still says '+KW);
       if(!(g.alert&&g.alert.k==='warn'&&String(g.alert.m).indexOf(RV)===0)) bad.push('the alert lane does not hold the Crier line as a warning ('+JSON.stringify(g.alert&&{m:g.alert.m,k:g.alert.k})+')');
       // an ordinary line said under it goes to the feed and the alert stays
       say(LOOT);
       step(); step(); draw();
       after=rv();
       for(j=0;j<ev.length;j++) if(ev[j].t===LOOT) lootSeen=true;
       if(!after) bad.push('an ordinary line said 0.4 s after the Crier line took it off the screen');
       else if(after.a<0.99) bad.push('an ordinary line said under the Crier line dimmed it to alpha '+after.a);
       if(!lootSeen) bad.push('the ordinary line said under the alert was not drawn');
       if(g.msg!==LOOT) bad.push('the ordinary line is not the feed row (G.msg '+JSON.stringify(g.msg)+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; keys={};
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.marked=0; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
