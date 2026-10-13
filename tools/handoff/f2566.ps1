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

if ($s.Contains("  {v:'25.66',what:")) { throw "check 25.66 is in the fixture already" }

SubRx @'
  {v:'25.65',what:
'@ @'
  {v:'25.66',what:'his note (text at top mid is colliding): with an alert or the location tag, a feed row, the boss bar and the final minute showing, no two text boxes in the top centre intersect, in a CAREER and a DEMO raid at 1080p and 4K',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof __loop!=='function'||typeof __forceSize!=='function') return 'SKIP: no raid here';
     var bad=[], rf=ctx.fillText, own=false, rec=[], kSay=say, sizes=[[1920,1080],[3840,2160]], modes=['career','demo'], states=['alert','loc','final'];
     function startRec(){ rec=[]; own=true; ctx.fillText=function(s,x,y){ var m=/([\d.]+)px/.exec(String(ctx.font||'')), px=m?+m[1]:12, w=0, t=null, al=ctx.textAlign, asc=0.78*px, dsc=0.22*px;
         try{ var tm=ctx.measureText(String(s)); w=tm.width; if(isFinite(tm.actualBoundingBoxAscent)){ asc=tm.actualBoundingBoxAscent; dsc=tm.actualBoundingBoxDescent; } }catch(_e){} try{ t=ctx.getTransform(); }catch(_t){}
         var a=t?t.a:1, d=t?t.d:1, e=t?t.e:0, f=t?t.f:0, x0=x, x1=x+w;
         if(al==='center'){ x0=x-w/2; x1=x+w/2; } else if(al==='right'||al==='end'){ x0=x-w; x1=x; }
         rec.push({s:String(s),x0:a*x0+e,x1:a*x1+e,y0:d*(y-asc)+f,y1:d*(y+dsc)+f});
         return rf.apply(this,arguments); }; }
     function stopRec(){ if(own){ delete ctx.fillText; if(ctx.fillText!==rf) ctx.fillText=rf; own=false; } }
     function measure(tag,W2,H2){
       var keep=rec.filter(function(r){ return r.y0<H2*0.36&&r.x1>W2*0.30&&r.x0<W2*0.70&&r.s.trim().length>0; }), i, j, a, b, hasClk=false, hasCmp=false, hasAl=false;
       for(i=0;i<keep.length;i++){ if(/^\d+:\d\d$/.test(keep[i].s)) hasClk=true; if(/^EXTRACT/.test(keep[i].s)) hasCmp=true; if(/PILLAGER SPOTTED|THE COLD MILE|RADIO CHECK/.test(keep[i].s)) hasAl=true; }
       if(!hasClk||!hasCmp||!hasAl) bad.push(tag+': an element is not drawn (clock '+hasClk+', compass '+hasCmp+', alert or feed '+hasAl+')');
       for(i=0;i<keep.length;i++) for(j=i+1;j<keep.length;j++){ a=keep[i]; b=keep[j]; if(a.s===b.s) continue;
         if(a.x0<b.x1&&b.x0<a.x1&&a.y0<b.y1+1&&b.y0<a.y1+1) bad.push(tag+': "'+a.s.slice(0,14)+'" ('+Math.round(a.y0)+'-'+Math.round(a.y1)+') and "'+b.s.slice(0,14)+'" ('+Math.round(b.y0)+'-'+Math.round(b.y1)+') collide'); }
     }
     function stage(mode,state,Wd,Hd){
       var g, p, e, tag=mode+' '+state+' '+Wd+'x'+Hd, f;
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(Wd,Hd);
       if(mode==='demo'){ if(typeof arcadeDeploy!=='function'||!arcadeDeploy({mapIx:0,seed:4242})){ bad.push(tag+': no demo raid'); return; } }
       else { __deploy({kit:[],safe:null,mapIx:0,seed:4242}); if(typeof careerPostBuild==='function'&&__state()&&!__state().career){ careerPostBuild(__state()); __state().cs.s=4200; __state().cs.k=17; } }
       g=__state(); if(!g||g.over||!g.player){ bad.push(tag+': no raid'); return; } p=g.player; p.iv=99; g.ents.length=0;
       try{ if(g.arcade&&typeof ARCADE==='object'){ ARCADE.holdT=0; ARCADE.banner=null; } }catch(_a){}
       if(state==='final') g.timeLeft=40;
       if(state==='loc'){ g.loc={m:'THE COLD MILE',T:5,at:(g.t||0)-1}; } else { say('PILLAGER SPOTTED','warn',{sub:'NORTH WEST OF YOU'}); }
       say('RADIO CHECK','info'); say('2 MINUTES LEFT','obj',{sub:'GET TO AN EXTRACTION'});
       if(typeof mkWarden==='function'&&typeof BOSS_NAME!=='undefined'){ e=mkWarden(p.x+240,p.y); e.boss=1; e.name=BOSS_NAME; e.r=44; e.barSeen=1; e.hp=e.maxhp||300; g.ents.push(e); g.bossRef=e; }
       for(f=0;f<6;f++){ if(f===5) startRec(); __loop(performance.now()+f*16.7); }
       stopRec(); measure(tag,Wd,Hd);
       try{ if(g.arcade&&typeof arcadeLeave==='function') arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
     }
     try{
       sizes.forEach(function(SZ){ modes.forEach(function(mo){ states.forEach(function(st){ stage(mo,st,SZ[0],SZ[1]); }); }); });
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ stopRec(); say=kSay; try{ __forceSize(1920,1080); }catch(_f){} try{ if(typeof arcadeLeave==='function'&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on) arcadeLeave(); }catch(_a2){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){} __topClear(); }
     return bad.length?bad.slice(0,6).join('; '):null; }},
  {v:'25.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
