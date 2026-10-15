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

if ($s.Contains("  {v:'28.27',what:")) { throw "check 28.27 is in the fixture already" }

SubRx @'
  {v:'28.26',what:
'@ @'
  {v:'28.27',what:'partyp7, his words on the power-ups (i never saw one, floating icon): each pickup is a big floating icon over a tall beam, floating well above its ground spot, spinning, with a ring on the ground at the pickup reach, a picture of its own for each kind, a beam that shows from just off the screen, and a blink over its last seconds',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof pwrDraw!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, S, i, j, k, q, z, sp, proto, oArc, oSc, oLt, oFt, arcs, sc, lts, ks=['clip','dmg','rapid','shield','pulse'], sig={}, big, ring, w, dsc, seen1, seen2, bl, top, dy, cnt;
     function hook(){ proto.arc=function(){ arcs.push({x:arguments[0],y:arguments[1],r:arguments[2]}); return oArc.apply(this,arguments); }; proto.scale=function(){ sc.push([arguments[0],arguments[1]]); return oSc.apply(this,arguments); }; proto.lineTo=function(){ lts.push([arguments[0],arguments[1]]); return oLt.apply(this,arguments); }; }
     function unhook(){ proto.arc=oArc; proto.scale=oSc; proto.lineTo=oLt; }
     function frame(){ arcs=[]; sc=[]; lts=[]; hook(); try{ pwrDraw(ctx,p); } finally { unhook(); } }
     function alphas(left){
       var seen={}, kk;
       S.items.length=0; S.items.push({k:'rapid',x:p.x+120,y:p.y-30,t:16-left,life:16,id:5});
       for(kk=0;kk<16;kk++){
         g.t=3+kk*0.037; S.items[0].t=16-left;
         Object.defineProperty(proto,'globalAlpha',{get:dsc.get,set:function(v2){ seen[(+v2).toFixed(2)]=1; dsc.set.call(this,v2); },configurable:true});
         try{ pwrDraw(ctx,p); } finally { Object.defineProperty(proto,'globalAlpha',dsc); }
       }
       return seen;
     }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof PWRI==='undefined') return 'there is no floating icon in this build';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; g.pwr=null; S=pwrS(); render2D(0);
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc; oSc=proto.scale; oLt=proto.lineTo; oFt=proto.fillText; q=ZOOM(); z=Math.max(1,hudRes());
       dsc=Object.getOwnPropertyDescriptor(proto,'globalAlpha');
       // ONE: the icon is big and floats well above its ground spot, and a ring marks the pickup reach on the ground
       S.items.length=0; S.items.push({k:'dmg',x:p.x+120,y:p.y-30,t:3,life:16,id:5}); sp=w2s(S.items[0].x,0,S.items[0].y);
       frame();
       big=0; ring=0;
       for(i=0;i<arcs.length;i++){
         if(Math.abs(arcs[i].x-sp.x)<1&&arcs[i].r>=PWRI.R*q*2&&arcs[i].y<sp.y-20*q) big++;
         if(Math.abs(arcs[i].x-sp.x)<1&&Math.abs(arcs[i].y-sp.y)<1&&Math.abs(arcs[i].r-PWR.pick*q)<1) ring++;
       }
       if(!big) bad.push('ONE: no big glow was drawn round an icon floating high above its ground spot ('+arcs.length+' arcs)');
       if(!ring) bad.push('ONE: no ring on the ground at the pickup reach ('+PWR.pick+')');
       // TWO: it spins: the medallion is drawn at different widths at different moments
       w=[]; for(k=0;k<8;k++){ g.t=3+k*0.31; frame(); for(i=0;i<sc.length;i++) if(sc[i][1]===1&&sc[i][0]>0.2&&sc[i][0]<0.999) w.push(sc[i][0]); }
       if(w.length<4||Math.max.apply(null,w)-Math.min.apply(null,w)<0.3) bad.push('TWO: the icon does not spin (widths '+w.slice(0,5).map(function(v){ return v.toFixed(2); }).join(',')+')');
       // THREE: a picture of its own for each of the five kinds
       for(j=0;j<ks.length;j++){
         cnt={arc:0,line:0,txt:''};
         proto.arc=function(){ cnt.arc++; return oArc.apply(this,arguments); }; proto.lineTo=function(){ cnt.line++; return oLt.apply(this,arguments); }; proto.fillText=function(){ cnt.txt+=String(arguments[0]); return oFt.apply(this,arguments); };
         try{ pwrGlyph(ctx,ks[j],0,0,15,pwrDef(ks[j]),z); } finally { proto.arc=oArc; proto.lineTo=oLt; proto.fillText=oFt; }
         sig[ks[j]]=cnt.arc+'/'+cnt.line+'/'+cnt.txt;
       }
       for(j=0;j<ks.length;j++) for(k=j+1;k<ks.length;k++) if(sig[ks[j]]===sig[ks[k]]) bad.push('THREE: '+ks[j]+' and '+ks[k]+' have the same picture');
       if(sig.dmg.indexOf('2X')<0) bad.push('THREE: the double damage icon has no 2X');
       // FOUR: a pickup just below the screen still shows its beam, from the ground spot up
       S.items.length=0; sp=w2s(p.x,0,p.y); top=w2s(p.x,0,p.y+100); dy=(H+60-sp.y)/Math.max(0.01,(top.y-sp.y)/100); S.items.push({k:'clip',x:p.x,y:p.y+dy,t:3,life:16,id:7}); sp=w2s(S.items[0].x,0,S.items[0].y); bl=PWRI.beam*q;
       if(!(sp.y>H&&sp.y-bl<H)) bad.push('FOUR: staging: the test pickup is at y '+Math.round(sp.y)+' of '+H);
       else { frame(); top=0; for(i=0;i<lts.length;i++) if(Math.abs(lts[i][1]-(sp.y-bl))<1.5) top++; if(!top) bad.push('FOUR: a pickup just below the screen drew no beam'); }
       // FIVE: it blinks over its last seconds, and not before
       seen1=alphas(1.0); seen2=alphas(9.0);
       if(!seen1['0.30']||!seen1['1.00']) bad.push('FIVE: a pickup with one second left does not blink ('+Object.keys(seen1).join(',')+')');
       if(seen2['0.30']) bad.push('FIVE: a pickup with nine seconds left blinks');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(proto){ proto.arc=oArc; proto.scale=oSc; proto.lineTo=oLt; proto.fillText=oFt; if(dsc) Object.defineProperty(proto,'globalAlpha',dsc); } }catch(_p){}
       keys={};
       try{ if(g){ g.pwr=null; } }catch(_gp){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; ARCADE.streak=null; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'28.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
