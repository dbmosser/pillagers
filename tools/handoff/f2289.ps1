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

if ($s.Contains("  {v:'22.89',what:")) { throw "check 22.89 is in the fixture already" }

SubRx @'
  {v:'22.88',what:
'@ @'
  {v:'22.89',what:'the batch 7 chatter lines are caps callouts with short details: a drink wearing off says LIQUOR WORE OFF or BLOTTER WORE OFF, the slow-frame rows carry Settings: Auto resolution and Settings: Render resolution, Effects as the detail, and the page no longer holds the sentences for a pillager calling extraction, the Survivor out, the Peddler setting up or back, a pillager seen first, a deer or bird shot, or a kill that was not yours; each new headline is in the page',
   run:function(){
     if(typeof tickBuzz!=='function'||typeof drsTick!=='function'||typeof perfNote!=='function'||typeof DRS==='undefined'||typeof PERF==='undefined') return 'SKIP: no drinks or frame notes here';
     var bad=[], oAny=sayAny, oSwf=sayWhenFree, lines=[], b0=P.buzz, c0=CFG.gfxAuto, s0=CFG.gfxScale, f0=CFG.fpsCap, d0=JSON.stringify(DRS), w0=PERF.win, ps0=PERF.said, i, t=0, t0, src, Q="'";
     function cap(what,l){
       if(!l){ bad.push(what+' said nothing'); return; }
       if(l.m!==l.m.toUpperCase()||l.m.length>34||/[.!?,;:]$/.test(l.m)) bad.push(what+' said '+JSON.stringify(l.m)+', not a caps callout');
       if(l.sub&&(/[.!?]$/.test(l.sub)||l.sub.length>40)) bad.push(what+' has the detail '+JSON.stringify(l.sub)+', a sentence, not a short detail');
     }
     try{
       sayAny=function(m,k){ lines.push({m:String(m),k:k,sub:''}); };
       sayWhenFree=function(m,k,o){ lines.push({m:String(m),k:k,sub:(o&&o.sub)?String(o.sub):''}); };
       P.buzz=[{id:'liquor',tag:'drunk',t:0.001,dur:180}]; lines.length=0; tickBuzz(0.05);
       cap('the liquor wearing off',lines[0]); if(lines[0]&&lines[0].m!=='LIQUOR WORE OFF') bad.push('the liquor wearing off said '+JSON.stringify(lines[0].m)+', not LIQUOR WORE OFF');
       P.buzz=[{id:'lsd',tag:'lsd',t:0.001,dur:180}]; lines.length=0; tickBuzz(0.05);
       cap('the Blotter wearing off',lines[0]); if(lines[0]&&lines[0].m!=='BLOTTER WORE OFF') bad.push('the Blotter wearing off said '+JSON.stringify(lines[0].m)+', not BLOTTER WORE OFF');
       CFG.gfxAuto=1; CFG.gfxScale=1; CFG.fpsCap=0; DRS.scale=1; DRS.ema=0; DRS.slowT=0; DRS.fastT=0; DRS.last=0; DRS.bounce=0; DRS.upAt=0; DRS.said=0;
       lines.length=0; for(i=0;i<200;i++){ t+=40; drsTick(40,t); }
       cap('the resolution step',lines[0]); if(lines[0]&&lines[0].sub!=='Settings: Auto resolution') bad.push('the resolution step has the detail '+JSON.stringify(lines[0].sub));
       PERF.win=[]; PERF.said=0; t0=performance.now()-9000; for(i=0;i<120;i++) PERF.win.push([t0+i*75,40]);
       lines.length=0; perfNote(40);
       cap('running slowly',lines[0]); if(lines[0]&&lines[0].sub!=='Settings: Render resolution, Effects') bad.push('running slowly has the detail '+JSON.stringify(lines[0].sub));
       src=[].slice.call(document.scripts).map(function(s){ return s.textContent||''; }).join('\n');
       [['say(e.name+'+Q+' called','a pillager calling extraction'],[Q+'The survivor'+' made it','the Survivor out'],[Q+'The Peddler'+' has set','the Peddler setting up'],[Q+'The Peddler'+' is back at','the Peddler back'],[Q+' nods'+' at','a pillager seen first'],[Q+' is watching'+' you.'+Q,'a pillager seen first'],[Q+'The deer'+' goes','a deer shot'],[Q+'You shot'+' a','a bird shot'],['{sub:'+Q+'Not on you','a survivor killed by someone else'],['{sub:'+Q+'Someone else did','the Peddler killed by someone else']].forEach(function(n){
         if(src.indexOf(n[0])>=0) bad.push(n[1]+' still says the old sentence');
       });
       [['PILLAGER CALLED','EXTRACTION'],['SURVIVOR','EXTRACTED'],['THE PEDDLER SET','UP SHOP'],['THE PEDDLER IS','BACK'],[' IS','FRIENDLY'],[' IS','WATCHING'],['DEER','DOWN'],['BIRD','DOWN'],['Not your','kill']].forEach(function(n){
         if(src.indexOf(Q+n[0]+' '+n[1]+Q)<0) bad.push('the page has no '+n[0]+' '+n[1]+' line');
       });
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       sayAny=oAny; sayWhenFree=oSwf; P.buzz=b0||[];
       CFG.gfxAuto=c0; CFG.gfxScale=s0; CFG.fpsCap=f0; try{ var d=JSON.parse(d0), k; for(k in d) DRS[k]=d[k]; }catch(_d){} try{ resize(); }catch(_r){}
       PERF.win=w0||[]; PERF.said=ps0;
       try{ saveProfile(); }catch(_s){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
