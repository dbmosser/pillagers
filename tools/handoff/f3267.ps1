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

if ($s.Contains("  {v:'32.67',what:")) { throw "check 32.67 is in the fixture already" }

SubRx @'
  {v:'32.66',what:
'@ @'
  {v:'32.67',what:'pillager bots (his art picks a18 A, a19 D, a21 B, a22 A+B, a23 B): every hostile bot in the same dark red coat, the golden one solid gold with a shine, a hop and red eye flare when it notices you, and a fall as itself when it dies',
   run:function(){
     var g, p, keepWc, keepT, cv, cx, d, i, n, bad=[], fk, mc, gk, tok, a, bx, kk, cols, c1, c2, e, ents;
     if(typeof raiderCoat!=='function') return 'no raiderCoat';
     function mkE(o){ var z={kind:'raider',x:0,y:0,r:14,face:0,coat:'#336699',wep:WEAPONS.rifle,hp:50,maxhp:50,bag:[],ident:'botlook',state:'idle',build:'lean'}, q; for(q in o) z[q]=o[q]; return z; }
     function stat(dd,f){ var k=0, j; for(j=0;j<dd.length;j+=4) if(dd[j+3]>128&&f(dd[j],dd[j+1],dd[j+2])) k++; return k; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player; keepWc=wc; keepT=g.t;
       cv=document.createElement('canvas'); cv.width=240; cv.height=240; cx=cv.getContext('2d',{willReadFrequently:true});
       function clear(){ cx.setTransform(1,0,0,1,0,0); cx.globalAlpha=1; cx.globalCompositeOperation='source-over'; cx.filter='none'; cx.clearRect(0,0,240,240); }
       // a18 A and a19 D: one crew colour for every hostile bot, whatever its gun; hires and neutrals keep their own
       for(i=0;i<5;i++){ fk=['shotgun','rifle','lmg','sniper','carbine'][i]; c1=raiderCoat(mkE({wep:WEAPONS[fk]||WEAPONS.rifle,coat:'#'+(i*3)+'a'+(i*3+3)+'44'+(i*2+1)+'0'})); if(c1!=='#7a2f2a') bad.push('a hostile bot with the '+fk+' wears '+c1+' (every hostile bot wears #7a2f2a)'); }
       if(raiderCoat(mkE({merc:1,friendly:1}))!=='#336699') bad.push('a hire lost its own coat');
       if(raiderCoat(mkE({hostile:false}))==='#7a2f2a') bad.push('a neutral wears the enemy red');
       if(raiderCoat(mkE({golden:1}))==='#7a2f2a') bad.push('the golden bot wears the crew red');
       // a22: the tell is stored the moment the state reads chase, runs 0.45 s, a bot first seen already hunting does not hop
       e=mkE({}); g.t=10;
       if(raiderTellF(e)!==0) bad.push('a22: a bot that was never hunting shows the tell');
       e.state='chase'; g.t=10.1;
       if(!(raiderTellF(e)>0)) bad.push('a22: no tell the moment a bot reads chase');
       g.t=10.4; if(!(raiderTellF(e)>0)) bad.push('a22: the tell ended before 0.45 s');
       g.t=10.6; if(raiderTellF(e)!==0) bad.push('a22: the tell is still running after 0.45 s');
       e=mkE({state:'chase'}); g.t=20; if(raiderTellF(e)!==0) bad.push('a22: a bot first drawn already hunting hopped');
       // a22: the red eye flare and the tighter brows are on the face
       function shot(tl){ clear(); wc=cx; cx.setTransform(5,0,0,5,120,200); try{ drawOp(0,0,0,0,'#7a2f2a',0,0,'none',0,{own:mkE({}),team:'foe',moving:false,sprint:false,ads:false,hurt:0,bulk:0,tell:tl,build:'lean'}); } finally{ wc=keepWc; } return cx.getImageData(0,0,240,240).data; }
       n=stat(shot(0.5),function(r,gg,b){ return r>=235&&gg<=90&&b<=80; })-stat(shot(0),function(r,gg,b){ return r>=235&&gg<=90&&b<=80; });
       if(n<4) bad.push('a22: no red eye flare while the tell runs ('+n+' px more than at rest)');
       // a23 B: the death is the real figure, tipped flat, gone by 0.7 s
       g.deathAnims=[]; e=mkE({x:0,y:0}); p.x=-80; p.y=0; deathAnimAdd(e); a=g.deathAnims[g.deathAnims.length-1];
       if(!a||!a.op) bad.push('a23: a dying hostile bot keeps no figure to fall');
       else {
         g.t=a.t0+0.3; clear(); wc=cx; cx.setTransform(5,0,0,5,120,150);
         try{ drawDeathAnims(); } finally{ wc=keepWc; }
         d=cx.getImageData(0,0,240,240).data; cols={}; var x0=999,x1=-1,y0=999,y1=-1,r,c,o4;
         for(r=0;r<240;r++) for(c=0;c<240;c++){ o4=(r*240+c)*4; if(d[o4+3]>60){ cols[(d[o4]>>5)+'-'+(d[o4+1]>>5)+'-'+(d[o4+2]>>5)]=1; if(c<x0)x0=c; if(c>x1)x1=c; if(r<y0)y0=r; if(r>y1)y1=r; } }
         n=Object.keys(cols).length;
         if(n<8) bad.push('a23: the fallen bot is a flat shape ('+n+' colours, the figure has many)');
         if(!((x1-x0)>1.15*(y1-y0))) bad.push('a23: the bot is not lying flat at 0.3 s (box '+(x1-x0)+' wide, '+(y1-y0)+' tall)');
         g.t=a.t0+0.75; clear(); wc=cx; cx.setTransform(5,0,0,5,120,150);
         try{ drawDeathAnims(); } finally{ wc=keepWc; }
         if(stat(cx.getImageData(0,0,240,240).data,function(){ return true; })>0) bad.push('a23: a body is still drawn 0.75 s after the death');
       }
       // a21 B: a golden body is gold all through, with a shine strip that comes and goes
       gk=mkE({golden:1,r:17});
       function gshot(t){ var tk; clear(); g.t=t; wc=cx; cx.setTransform(4,0,0,4,120,170); try{ tk=goldBodyBegin(gk); if(!tk) return null; wc.fillStyle=raiderCoat(gk); wc.fillRect(-10,-30,20,30); goldBodyEnd(tk); } finally{ wc=keepWc; } return cx.getImageData(0,0,240,240).data; }
       if(typeof goldBodyBegin!=='function') bad.push('a21: no solid gold body');
       else {
         d=gshot(1.0);
         if(!d) bad.push('a21: the gold body could not start');
         else {
           n=stat(d,function(r,gg,b){ return r>=200&&gg>=110&&r>gg+25&&gg>b+35; });
           if(n<400) bad.push('a21: the golden body is not gold ('+n+' gold px)');
           n=d[(158*240+120)*4]+d[(158*240+120)*4+1]+d[(158*240+120)*4+2];
           c1=stat(d,function(r,gg,b){ return r+gg+b>n+45; });
           var d2=gshot(0.2), mx=0, j2, df=0;
           for(j2=0;j2<d2.length;j2++) if(d2[j2]!==d[j2]) df++;
           for(j2=0;j2<d2.length;j2+=4) if(d2[j2+3]>128&&d2[j2]+d2[j2+1]+d2[j2+2]>mx) mx=d2[j2]+d2[j2+1]+d2[j2+2];
           c2=stat(d2,function(r,gg,b){ return r+gg+b>n+30; });
           c1=stat(d,function(r,gg,b){ return r+gg+b>n+30; });
           if(c2-c1<20) bad.push('a21: no shine strip across the golden body ('+c2+' bright px mid sweep, '+c1+' between sweeps; centre sum '+n+', brightest mid sweep '+mx+', '+df+' values differ)');
         }
         if(goldBodyBegin(mkE({}))) { goldBodyAbort(); bad.push('a21: an ordinary bot is drawn through the gold filter'); }
       }
       // the real frame draws a golden bot beside the player without a render fault
       g.t=keepT; ents=g.ents;
       for(i=0;i<ents.length;i++) if(ents[i]&&ents[i].kind==='raider'&&!ents[i].merc&&!ents[i].friendlyPC&&ents[i].hostile!==false){ e=ents[i]; break; }
       if(e){ p.x=e.x-70; p.y=e.y; e.golden=1; e.state='chase'; g.drawErr=null; __frame(); __frame(); if(g.drawErr) bad.push('the frame threw drawing the golden bot: '+g.drawErr); e.golden=0; }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ wc=keepWc; g.t=keepT; goldBodyAbort(); g.deathAnims=[]; }catch(_k){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
