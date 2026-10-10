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

if ($s.Contains("  {v:'22.32',what:")) { throw "check 22.32 is in the fixture already" }

SubRx @'
  {v:'22.31',what:
'@ @'
  {v:'22.32',what:'threats are alert headlines in the shooter voice: a Pillbox that sees him says THE PILLBOX HAS SEEN YOU as the alert, in the callout size on the danger plate with no end stop, while a line said in the same frame goes to the feed',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot deploy, step or draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof mkChoir!=='function'||typeof hudPlate!=='function') return 'SKIP: no Pillbox or no plate here';
     var bad=[], g, p, c, i, j, t0, f=0, realSay=say, oFT=ctx.fillText, oPl=hudPlate, ev=[], pl=[], PB=['THE','PILLBOX','HAS','SEEN','YOU'].join(' '), LOOT=['zq','loot'].join(' '),
         hit=null, loot=false, said=[], DP=String(HUDC.dangerPlate||''), HF=FS(TYPE.head), dang=false;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; hudPlate=oPl; }
     function fpx(s){ var m=(/([\d.]+)px/).exec(String(s)); return m?parseFloat(m[1]):0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9; p.iv=99;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[];
       say=function(m){ var s=String(m); said.push(s); if(s.indexOf('zq')===0||s.indexOf('THE PILLBOX')===0) return realSay.apply(this,arguments); };
       c=mkChoir(p.x+60,p.y); c.sang=0; g.ents.push(c);
       __ents(0.05);
       g.ents.length=0;   // nothing else speaks or shoots
       say(LOOT);         // in the same frame
       if(!said.some(function(s){ return s.indexOf('THE PILLBOX')===0; })) return 'SKIP: staging: the Pillbox said nothing (said: '+said.join(' | ').slice(0,120)+')';
       t0=Math.max(performance.now(),(typeof lastTs==="number"&&isFinite(lastTs))?lastTs:0);   // never behind the frame clock a check before left
       for(i=0;i<4;i++){ __loop(t0+(++f)*50); if(g.over) break; }   // past the fade in
       ev=[]; pl=[];
       ctx.fillText=function(t){ ev.push({t:String(t),font:String(ctx.font)}); return oFT.apply(this,arguments); };
       hudPlate=function(x,y,w,h,ac,fill){ pl.push(String(fill||'')); return oPl.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       for(j=0;j<ev.length;j++){ if(ev[j].t.indexOf('THE PILLBOX')===0&&!hit) hit=ev[j]; if(ev[j].t===LOOT) loot=true; }
       for(j=0;j<pl.length;j++) if(pl[j]===DP) dang=true;
       if(!hit) bad.push('the Pillbox line was not drawn');
       else {
         if(hit.t!==PB) bad.push('the Pillbox line reads '+JSON.stringify(hit.t)+', not the headline '+PB);
         if(Math.abs(fpx(hit.font)-fpx(HF))>0.2) bad.push('the Pillbox line is drawn in '+hit.font+', not the callout size '+HF);
       }
       if(!dang) bad.push('the Pillbox line is not on the danger plate');
       if(!(g.alert&&g.alert.m===PB&&g.alert.k==='warn')) bad.push('the alert lane does not hold the Pillbox line as a warning ('+JSON.stringify(g.alert&&{m:g.alert.m,k:g.alert.k})+')');
       if(!loot) bad.push('the line said in the same frame was not drawn');
       if(g.msg!==LOOT) bad.push('the line said in the same frame is not the feed row (G.msg '+JSON.stringify(g.msg)+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay; keys={};
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
