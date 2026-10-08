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

if ($s.Contains("  {v:'20.55',what:")) { throw "check 20.55 is in the fixture already" }

SubRx @'
  {v:'20.54',what:
'@ @'
  {v:'20.55',what:'the top centre stacks: with a message up, THE OVERSEER near and seen, a trade offer open and the controller paused word showing, the message plate, the boss bar, the offer line and the controller word each keep a band of their own, at 1080p and at 4K',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawBossBar!=='function'||typeof drawGiftLine!=='function'||typeof netPadHud!=='function'||typeof netPadDead!=='function'||typeof BOSS_NAME==='undefined'||typeof ctx.getTransform!=='function') return 'SKIP: no boss bar, offer line or controller word here';
     var bad=[], g, p, i, e=null, oFR=ctx.fillRect, oFT=ctx.fillText, oPD=netPadDead, oSay=say, rec=[], MSG='ZQX PROBE LINE THIRTY EIGHT', CP=['CONTROLLER','PAUSED'].join(' '), SZ=[[1920,1080],[3840,2160]], si, forced=false, at, nm, M, B, O, C;
     function wrap(){
       ctx.fillRect=function(x,y,w,h){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, a=(m.b*x+m.d*y+m.f)/d, b=(m.b*x+m.d*(y+h)+m.f)/d; rec.push({r:1,fs:String(ctx.fillStyle),y0:Math.min(a,b),y1:Math.max(a,b)}); return oFR.apply(this,arguments); };
       ctx.fillText=function(s){ rec.push({t:String(s)}); return oFT.apply(this,arguments); };
     }
     function unwrap(){ delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     // the plate of a line: the n rectangles painted just before its text, as one band
     function band(test,n){
       var j, q, got=0, o=null;
       for(j=rec.length-1;j>=0;j--) if(rec[j].t!==undefined&&test(rec[j].t)) break;
       if(j<0) return null;
       for(q=j-1;q>=0&&got<n;q--) if(rec[q].r){ got++; if(!o) o={y0:rec[q].y0,y1:rec[q].y1}; else { o.y0=Math.min(o.y0,rec[q].y0); o.y1=Math.max(o.y1,rec[q].y1); } }
       return got===n?o:null;
     }
     // the boss plate: the rectangle painted just before the dark red of the bar, with the bar
     function bossBand(){ var j; for(j=1;j<rec.length;j++) if(rec[j].r&&rec[j].fs==='#3a0d0d'&&rec[j-1].r) return {y0:Math.min(rec[j-1].y0,rec[j].y0),y1:Math.max(rec[j-1].y1,rec[j].y1)}; return null; }
     function hit(a,b){ return a.y0<b.y1-0.5&&b.y0<a.y1-0.5; }
     function rd(a){ return Math.round(a.y0)+' to '+Math.round(a.y1); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false;
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].name===BOSS_NAME&&g.ents[i].hp>0){ e=g.ents[i]; break; }
       if(!e&&typeof bossTick==='function'){ g.t=Math.max(g.t||0,2.5); try{ e=bossTick(true); }catch(_bt){ e=null; } }
       if(!e) return 'SKIP: no Overseer in this raid';
       e.x=p.x+150; e.y=p.y; g.bossRef=e; e.barSeen=1;   // seen: this check is about the layout, not when the bar first shows
       nm=String(e.name);
       netPadDead=function(){ return true; };
       say=function(){};   // nothing replaces the probe message mid-frame
       for(si=0;si<SZ.length;si++){
         if(window.__forceSize){ __forceSize(SZ[si][0],SZ[si][1]); forced=true; } else if(si) break;
         at=W+'x'+H;
         g.msg=MSG; g.msgT=3; g.giftOut=null; g.giftIn={id:'zq38',k:'bandage',from:1,t:g.t};
         rec=[]; wrap();
         try{ __frame(0.016); netPadHud(); } finally { unwrap(); }
         M=band(function(s){ return s===MSG; },1);
         B=bossBand();
         O=band(function(s){ return s.indexOf(' offers you ')>=0; },1);
         C=band(function(s){ return s.indexOf(CP)===0; },1);
         if(!M||!B||!O||!C){ bad.push('control at '+at+': not all four were drawn (message '+!!M+', boss bar '+!!B+', offer '+!!O+', controller word '+!!C+')'); continue; }
         if(hit(M,B)) bad.push('at '+at+' the message plate ('+rd(M)+') covers the boss bar ('+rd(B)+')');
         if(hit(O,C)) bad.push('at '+at+' the offer line ('+rd(O)+') and the controller word ('+rd(C)+') print on top of each other');
         if(hit(B,O)) bad.push('at '+at+' the boss bar ('+rd(B)+') and the offer line ('+rd(O)+') overlap');
         if(hit(B,C)) bad.push('at '+at+' the boss bar ('+rd(B)+') and the controller word ('+rd(C)+') overlap');
         if(hit(M,O)) bad.push('at '+at+' the message plate ('+rd(M)+') and the offer line ('+rd(O)+') overlap');
         if(hit(M,C)) bad.push('at '+at+' the message plate ('+rd(M)+') and the controller word ('+rd(C)+') overlap');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unwrap(); netPadDead=oPD; say=oSay; keys={};
       if(forced){ try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_f){} }
       try{ var g2=__state(); if(g2){ g2.giftIn=null; g2.msgT=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
