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

if ($s.Contains("  {v:'22.93',what:")) { throw "check 22.93 is in the fixture already" }

SubRx @'
  {v:'22.92',what:
'@ @'
  {v:'22.93',what:'? and ! sit above the nameplate at every size: at 4K the ! over a chasing Sentry has its baseline above the top of the Sentry nameplate plate, and a winding Crier in view gets no ! at all',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace&&window.__forceSize&&window.__frame)||typeof mkSentry!=='function'||typeof mkSnitch!=='function'||typeof canSee!=='function') return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g=null, p=null, forced=false, s, c, f0, k, ok=false, tr, i, sn=null, cn=null, bangS=null, bangC=0, sx, cx, t;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(3840,2160); forced=true;
       if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false; p.iv=99; p.hp=p.maxhp;
       refreshVseg();
       f0=p.face||0;
       // side by side across the screen (the two marks are told apart by their x), above or below him
       var OFS=[[70,-160],[70,160],[110,-120],[110,120],[60,-220],[60,220]];
       for(k=0;k<OFS.length&&!ok;k++){
         p.face=Math.atan2(OFS[k][1],0);
         var ax=p.x-OFS[k][0], ay=p.y+OFS[k][1], bx=p.x+OFS[k][0], by=p.y+OFS[k][1];
         if(canSee(p.x,p.y,p.face,ax,ay,g.vseg)&&canSee(p.x,p.y,p.face,bx,by,g.vseg)){ ok=true; s=mkSentry(ax,ay); c=mkSnitch(bx,by); }
       }
       if(!ok) return 'SKIP: staging: no open view from the spawn';
       s.state='chase'; s.alert=1; c.state='alarm'; c.wind=3; c.lost=0; c.markX=p.x; c.markY=p.y;
       g.ents.length=0; g.ents.push(s); g.ents.push(c);
       __frame(0.016);
       tr=__textTrace(function(){ __frame(0.016); });
       if(VIS.indexOf(s)<0||VIS.indexOf(c)<0) return 'SKIP: staging: the Sentry and the Crier were not both in view';
       for(i=0;i<tr.length;i++){ t=tr[i].t; if(!sn&&t.indexOf(String(s.name))===0) sn=tr[i]; if(!cn&&t.indexOf(String(c.name))===0) cn=tr[i]; }
       if(!sn||!cn) return 'SKIP: staging: a nameplate was not drawn';
       sx=sn.x+sn.w/2; cx=cn.x+cn.w/2;
       for(i=0;i<tr.length;i++){
         if(tr[i].t!=='!') continue;
         if(Math.abs(tr[i].x-sx)<6&&tr[i].y<sn.y+sn.px*4&&tr[i].y>sn.y-sn.px*30&&!bangS) bangS=tr[i];
         if(Math.abs(tr[i].x-cx)<6&&tr[i].y<cn.y+cn.px*4&&tr[i].y>cn.y-cn.px*30) bangC++;
       }
       if(!bangS) bad.push('no ! was drawn over the chasing Sentry');
       else if(bangS.y>sn.y-sn.px*1.25) bad.push('at 4K the ! over the Sentry has its baseline at '+Math.round(bangS.y)+', inside or under its nameplate (name baseline '+Math.round(sn.y)+', '+sn.px.toFixed(1)+' px)');
       if(bangC) bad.push('a ! was drawn over a Crier winding up ('+bangC+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       try{ var g2=__state(); if(g2){ g2.ents.length=0; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       if(forced){ try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_f){} }
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
