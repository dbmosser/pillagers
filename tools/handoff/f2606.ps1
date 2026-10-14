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

if ($s.Contains("  {v:'26.06',what:")) { throw "check 26.06 is in the fixture already" }

SubRx @'
  {v:'26.05',what:
'@ @'
  {v:'26.06',what:'his note: the crowbar swing is larger and more prominent: the bar is drawn 1.6 times as long and thick, a pale crescent swoosh sweeps 140 degrees behind it, a hit adds an impact flash, sparks and a small kick of the screen, and the body leans into the blow',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawOp!=='function'||typeof meleeStrike!=='function'||typeof mkSentry!=='function'||typeof fireWeapon!=='function') return 'SKIP: this fixture cannot stage a swing';
     if(typeof wc.getTransform!=='function') return 'SKIP: the world context has no getTransform';
     var bad=[], g=null, p=null, S=null, E0=null, b0=null, b1=null, b2=null, mx=null, nSp0=0, nSp1=0, nFl0=0, nFl1=0, sh1=0, kk;
     function clr(){ for(var q in keys) keys[q]=false; }
     function extra(o){ var cnt={}, k, i, mxw=0; for(i=0;i<b0.ws.length;i++){ k=b0.ws[i]; cnt[k]=(cnt[k]||0)+1; } for(i=0;i<o.ws.length;i++){ k=o.ws[i]; if(cnt[k]>0) cnt[k]--; else mxw=Math.max(mxw,+k); } return mxw; }
     function meas(barT){
       var m0=wc.getTransform(), s0=Math.hypot(m0.a,m0.b)||1, o={ws:[],arc:0,sw:0,cur:0,tx:-1e9},
           oFR=wc.fillRect, oAr=wc.arc, oFi=wc.fill, oBP=wc.beginPath, oTr=wc.translate;
       function sc(){ var m=wc.getTransform(); return Math.hypot(m.a,m.b)/s0; }
       wc.fillRect=function(x,y,w,h){ o.ws.push((Math.abs(w)*sc()).toFixed(3)); return oFR.apply(wc,arguments); };
       wc.beginPath=function(){ o.cur=0; return oBP.apply(wc,arguments); };
       wc.arc=function(x,y,r){ var rr=Math.abs(r)*sc(); o.arc=Math.max(o.arc,rr); o.cur=Math.max(o.cur,rr); return oAr.apply(wc,arguments); };
       wc.translate=function(tx,ty){ if(Math.abs(tx-p.x)<12&&ty>p.y-30&&ty<p.y-14) o.tx=Math.max(o.tx,tx); return oTr.apply(wc,arguments); };
       wc.fill=function(){
         var c=String(wc.fillStyle), mm=/^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)$/.exec(c), hx=/^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(c), r=0, gg=0, bb=0, al=wc.globalAlpha;
         if(mm){ r=+mm[1]; gg=+mm[2]; bb=+mm[3]; if(mm[4]!==undefined) al*=+mm[4]; } else if(hx){ r=parseInt(hx[1],16); gg=parseInt(hx[2],16); bb=parseInt(hx[3],16); }
         if(o.cur>=30&&Math.min(r,gg,bb)>=180&&al>=0.05) o.sw++;
         return oFi.apply(wc,arguments); };
       try{ g.punchT=0.2; g.barT=barT; drawOp(p.x,p.y,0,0,'#242832',0,0,'fist',0,{hero:1,own:p,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:armorById(p.rig).bulk,healLeft:0,healTot:0,healSec:0,rl:0}); }
       finally{ delete wc.fillRect; delete wc.beginPath; delete wc.arc; delete wc.translate; delete wc.fill; g.punchT=0; g.barT=0; }
       return o;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.zones||!g.zones.length||!g.ents||!g.sparks||!g.flashes||!g.puffs) return 'SKIP: no live raid';
       E0=g.ents; clr(); g.paused=false; p.downed=false; p.dying=false; p.roll=0; p.iv=99; g.searching=null; g.trade=null;
       // the drawn swing, a third and then over half way through, against the plain fist punch (no crowbar)
       b0=meas(0); b1=meas(0.22*(1-0.35)); b2=meas(0.22*(1-0.6));
       // the crowbar is every rectangle the swing draws that the plain punch does not (the body draws some as wide as 24 itself)
       mx={bar:Math.max(extra(b1),extra(b2)), arc:Math.max(b1.arc,b2.arc), sw:b1.sw+b2.sw, tx:Math.max(b1.tx,b2.tx)};
       if(mx.bar+mx.arc<1.5*(20.6+17)) bad.push('the drawn swing reaches '+(mx.bar+mx.arc).toFixed(1)+' (bar '+mx.bar.toFixed(1)+' plus swoosh '+mx.arc.toFixed(1)+'), under 1.5 times the old 37.6');
       if(mx.bar<1.5*20.6) bad.push('the crowbar is drawn '+mx.bar.toFixed(1)+' long, under 1.5 times the old 20.6');
       if(mx.sw<2) bad.push('no pale swoosh crescent is filled in the swing (fills '+mx.sw+')');
       if(b0.sw>0||b0.arc>=30) bad.push('the plain fist punch draws a swoosh (arc '+b0.arc.toFixed(1)+', swoosh '+b0.sw+')');
       if(!(mx.tx-b0.tx>=1.5)) bad.push('the body does not lean into the swing (arm pivot '+mx.tx.toFixed(2)+' against '+b0.tx.toFixed(2)+' at rest)');
       // a landed blow: the crowbar adds a flash and more sparks than the plain punch, and a small kick of the screen
       p.x=g.zones[0].x; p.y=g.zones[0].y; p.face=0; S=mkSentry(p.x+40,p.y); S.hp=80; g.ents=[S]; g.searching=null; p.cooking=0; clr();
       g.barT=0; g.punchT=0; g.sparks.length=0; g.flashes.length=0; g.puffs.length=0; g.shake=0;
       fireWeapon(p,WEAPONS.fists,p.x+100,p.y,true);
       nSp0=g.sparks.length; nFl0=g.flashes.length;
       g.sparks.length=0; g.flashes.length=0; g.puffs.length=0; g.shake=0; p.meleeAt=undefined; p.lastShot=undefined;
       if(!meleeStrike()) bad.push('Q did not swing');
       nSp1=g.sparks.length; nFl1=g.flashes.length; sh1=g.shake||0;
       if(!(nSp0>0&&nSp1>=1.5*nSp0)) bad.push('a crowbar hit threw '+nSp1+' sparks against '+nSp0+' for the plain punch (wanted 1.5 times as many)');
       if(!(nFl1>nFl0)) bad.push('a crowbar hit added no impact flash ('+nFl1+' against '+nFl0+')');
       if(!(sh1>=1&&sh1<=4)) bad.push('a crowbar hit kicked the screen '+sh1+' (wanted a small kick, 1 to 4)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(kk in keys) keys[kk]=false; }catch(_k){}
       try{ if(g){ g.barT=0; g.punchT=0; g.shake=0; g.sparks.length=0; g.flashes.length=0; g.puffs.length=0; if(E0) g.ents=E0; } }catch(_g){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
