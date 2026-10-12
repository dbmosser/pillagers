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

if ($s.Contains("  {v:'23.96',what:")) { throw "check 23.96 is in the fixture already" }

SubRx @'
  {v:'23.95',what:
'@ @'
  {v:'23.96',what:'graphics program gfx5: world text draws on the HUD canvas: in a drawn raid frame at 1920x1080 a loot label beside him is filled on the HUD canvas and never on the world canvas, at the screen height the world puts it, at the same device font size at Render resolution Low as at Full, the world canvas is handed back after the frame, and a HUD drawn on its own fills no world text',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__forceSize&&window.__pinDPR)||typeof render2D!=='function'||typeof drawHUD!=='function'||typeof label!=='function'||typeof resize!=='function'||typeof gfxScaleNow!=='function') return 'SKIP: this fixture cannot draw a raid frame at a set size';
     var bad=[], g=null, p=null, LB='ZQX '+'GFX5', OWN=Object.prototype.hasOwnProperty, W0=null, C0=null, sv=[], hits=[],
         s0=CFG.gfxScale, a0=CFG.gfxAuto, d0=JSON.stringify(DRS), dp0=window.devicePixelRatio||1,
         st=[cv.style.width,cv.style.height,hcv.style.width,hcv.style.height], forced=false, full=null, low=null, fh=null, lh=null, i, hr;
     function spy(){
       hits=[]; W0=wc; C0=ctx;
       [W0,C0].forEach(function(c){
         var own=OWN.call(c,'fillText'), of=c.fillText; sv.push({c:c,own:own,f:of});
         c.fillText=function(t,x,y){
           if(String(t)===LB){ var T=this.getTransform(), mm=(/([\d.]+)px/).exec(String(this.font)); hits.push({on:(this===C0)?'HUD':((this===W0)?'world':'other'),px:(mm?parseFloat(mm[1]):0)*Math.abs(T.d),y:T.b*x+T.d*y+T.f}); }
           return of.apply(this,arguments);
         };
       });
     }
     function unspy(){ while(sv.length){ var s=sv.pop(); try{ if(s.own) s.c.fillText=s.f; else delete s.c.fillText; }catch(_u){} } }
     function frame(sc){
       var lb;
       CFG.gfxAuto=0; DRS.scale=1; CFG.gfxScale=sc; resize();
       g.labels.length=0; label(p.x,p.y-30,LB,'#ffffff',0,true);
       lb=g.labels[g.labels.length-1];
       spy(); try{ render2D(0); } finally { unspy(); }
       return {h:hits.slice(), y:(lb&&lb.txt===LB)?(lb.y-VY)*ZOOM():NaN, back:(wc===W0)};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __pinDPR(1); __forceSize(1920,1080); forced=true;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false; p.iv=99;
       full=frame(1); low=frame(0.5);
       if(!full.h.length&&!low.h.length) return 'SKIP: staging: the label was not filled at all';
       [['Full',full],['Low',low]].forEach(function(r){
         var nm=r[0], o=r[1], j, hud=0;
         for(j=0;j<o.h.length;j++){ if(o.h[j].on==='HUD') hud++; else bad.push('at '+nm+' the loot label was filled on the '+o.h[j].on+' canvas'); }
         if(!hud) bad.push('at '+nm+' the loot label was not filled on the HUD canvas');
         if(!o.back) bad.push('at '+nm+' the world canvas was not handed back after the frame');
       });
       for(i=0;i<full.h.length;i++) if(full.h[i].on==='HUD'){ fh=full.h[i]; break; }
       for(i=0;i<low.h.length;i++) if(low.h[i].on==='HUD'){ lh=low.h[i]; break; }
       hr=(typeof DPRH==='number'&&DPRH>0)?DPRH:1;
       if(fh&&lh){
         if(!(fh.px>0)) bad.push('the label has no font size');
         else if(Math.abs(fh.px-lh.px)>0.05) bad.push('the label font is '+lh.px.toFixed(2)+' device px at Low against '+fh.px.toFixed(2)+' at Full');
         if(isFinite(full.y)&&Math.abs(fh.y/hr-full.y)>3) bad.push('at Full the label baseline is at '+(fh.y/hr).toFixed(1)+' on the screen, not '+full.y.toFixed(1)+' where the world puts it');
         if(isFinite(low.y)&&Math.abs(lh.y/hr-low.y)>3) bad.push('at Low the label baseline is at '+(lh.y/hr).toFixed(1)+' on the screen, not '+low.y.toFixed(1)+' where the world puts it');
       }
       CFG.gfxScale=1; resize();
       g.labels.length=0; label(p.x,p.y-30,LB,'#ffffff',0,true);
       spy(); try{ drawHUD(); } finally { unspy(); }
       if(hits.length) bad.push('a HUD drawn on its own filled the world label '+hits.length+' times, left over from an earlier frame');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={};
       CFG.gfxScale=s0; CFG.gfxAuto=a0;
       try{ var d=JSON.parse(d0), k; for(k in d) DRS[k]=d[k]; }catch(_d){}
       try{ var g2=__state(); if(g2){ g2.labels.length=0; if(!g2.over){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       if(forced){ cv.style.width=st[0]; cv.style.height=st[1]; hcv.style.width=st[2]; hcv.style.height=st[3]; }
       try{ __pinDPR(dp0); }catch(_p){} try{ resize(); }catch(_r){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
