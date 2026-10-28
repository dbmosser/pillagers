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

if ($s.Contains("  {v:'35.35',what:")) { throw "check 35.35 is in the fixture already" }

SubRx @'
  {v:'35.34',what:
'@ @'
  {v:'35.35',what:'cw-f1left, his order 2026-10-27 ("hitting f1 to get the controls should be over on the left, not the middle of the screen"; on the picture he picked a: "just the f1 key list moves to the left side"): the compact list, the full list and the undercroft controls card draw at the left side, the feed lines step right of the opened list, and the list stays clear of the vitals, at 1080p and 4K',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__forceSize) return 'SKIP: no raid in this fixture';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], r0=P.runs, oSay=say, g=null, proto=CanvasRenderingContext2D.prototype, o=proto.fillText, od=drawLegend, inL=0, rec=[], sz=[[1920,1080],[3840,2160]], s, i, j, L, fx, rw, tag, hbOn, hud0;
     function hit(a,b){ return a&&b&&a.w>0&&b.w>0&&a.x<b.x+b.w&&b.x<a.x+a.w&&a.y<b.y+b.h&&b.y<a.y+a.h; }
     function grab(fn,all){ rec=[]; proto.fillText=function(t,x,y){ if(all||inL){ var m=this.getTransform(), cw=(this.canvas&&this.canvas.width)||1; rec.push({t:String(t).toLowerCase(),f:(m.a*x+m.c*y+m.e)/cw}); } return o.apply(this,arguments); }; try{ fn(); } finally { proto.fillText=o; } }
     function fr(re){ var a=[], k; for(k=0;k<rec.length;k++) if(re.test(rec[k].t)) a.push(rec[k].f); return a; }
     function pc(a){ return Math.round(Math.max.apply(null,a)*100); }
     try{
       drawLegend=function(){ inL++; try{ return od.apply(this,arguments); } finally { inL--; } };
       say=function(){};
       P.runs=0; __runPrep(); __topClear(); try{ __pinDPR(1); }catch(_d){} __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: staging: no raid';
       g.career=1; g.arcade=0; g.legendAutoDone=true; g.bagOpen=false; g.mapOpen=false; keys={}; hud0=P.hud; P.hud={};
       say=oSay; for(i=0;i<4;i++) say('FEED LINE '+i,'info'); say=function(){};
       for(s=0;s<sz.length;s++){
         __forceSize(sz[s][0],sz[s][1]); tag=sz[s][0]+'x'+sz[s][1]+': ';
         g.legendOn=1; for(i=0;i<12;i++) __frame(0.016);
         grab(function(){ __frame(0.016); });
         fx=fr(/^(move|sprint|crouch|roll|fire|sights|reload|melee|next gun|item wheel|guns|backpack|use item|map|search|extract)$/);
         if(fx.length<8) bad.push(tag+'the compact list rows were not drawn ('+fx.length+')');
         else if(Math.max.apply(null,fx)>0.2) bad.push(tag+'the compact list is not on the left: its words reach '+pc(fx)+' percent of the width');
         L=HUDBOX.legend;
         if(!L||!(L.w>0)) bad.push(tag+'no list box');
         else {
           if(L.x>W*0.05) bad.push(tag+'the list box starts at x '+Math.round(L.x)+', not at the left edge');
           if(hit(L,HUDBOX.body)) bad.push(tag+'the opened list overlaps the vitals');
           rw=FEEDBOX.rows||[]; if(!rw.length) bad.push(tag+'control: no feed line was laid out');
           for(j=0;j<rw.length;j++) if(hit(L,rw[j])){ bad.push(tag+'the feed line '+rw[j].t+' is under the opened list'); break; }
         }
         g.legendOn=2; for(i=0;i<6;i++) __frame(0.016);
         grab(function(){ __frame(0.016); });
         fx=fr(/^(move|fight|gear|world|team|also)$/);
         if(fx.length<5) bad.push(tag+'the full list headings were not drawn ('+fx.length+')');
         else if(Math.max.apply(null,fx)>0.1) bad.push(tag+'the full list is not on the left: its headings stand at '+pc(fx)+' percent of the width');
         g.legendOn=0; for(i=0;i<4;i++) __frame(0.016);
       }
       __forceSize(1920,1080);
       __endRaid('abandon'); __topClear(); __runPrep();
       G=null; keys={}; __showScreen('hub'); __hubEnter(); if(window.__wnseen) __wnseen(1);
       if(typeof HB!=='object'||!HB) bad.push('no undercroft floor to draw');
       else {
         hbOn=HB.legend; HB.legend=false; grab(function(){ __hubFrame(0.016); },1);
         if(fr(/^controls$/).length) bad.push('control: a controls card was drawn on the floor with F1 off');
         HB.legend=true; grab(function(){ __hubFrame(0.016); },1); HB.legend=hbOn;
         fx=fr(/^controls$/);
         if(!fx.length) bad.push('the undercroft controls card was not drawn with F1 on');
         else if(Math.max.apply(null,fx)>0.35) bad.push('the undercroft controls card is not on the left: its title stands at '+pc(fx)+' percent of the width');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; drawLegend=od; say=oSay; P.runs=r0; if(hud0!==undefined) P.hud=hud0; try{ if(typeof HB==='object'&&HB) HB.legend=false; }catch(_h){} try{ __forceSize(1920,1080); }catch(_f){} try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(_c){} __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
