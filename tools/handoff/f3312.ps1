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

if ($s.Contains("  {v:'33.12',what:")) { throw "check 33.12 is in the fixture already" }

SubRx @'
  {v:'33.11',what:
'@ @'
  {v:'33.12',what:'top-edge ? and ! boxes stay clear of the whole bot nameplate; middle-view and idle plates retain their old positions',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__textTrace&&window.__forceSize)||typeof mkRaider!=='function') return 'SKIP: no raid drawing harness';
     var g=null,e=null,oldSee=canSee,mx=mouse.x,my=mouse.y,forced=false,bad=[];
     function close(a,b){ return Math.abs(a-b)<0.6; }
     function sample(state,baseline){
       var z=ZOOM(),ph=Math.ceil(msgPx(FS(TYPE.micro))*1.35),lift=spriteTop(e)+8;
       e.state=state; e.x=VX+W*0.35/z; e.y=VY+(baseline+lift*z)/z;
       var tr=__textTrace(function(){ __frame(0); }),n=null,m=null;
       tr.forEach(function(t){ if(t.t===e.name) n=t; if(t.t==='?'||t.t==='!') m=t; });
       if(!n) { bad.push(state+' at '+baseline+': no bot name drawn'); return; }
       var raw=w2s(e.x,(lift+ph-3)*z+LH(4)*Math.max(1,hudRes()),e.y);
       var minY=Math.round(msgPx(hudFS(TYPE.head))+LH(2));
       var shift=state==='idle'?0:Math.max(0,minY-raw.y);
       if(!close(n.x,e.x*z-VX*z-n.w/2)||!close(n.y,baseline+shift)) bad.push(state+': name moved by the wrong amount');
       if(state==='idle'){ if(m) bad.push('idle bot has an alert mark'); return; }
       if(!m){ bad.push(state+': no alert mark drawn'); return; }
       if(!close(m.x,raw.x)||!close(m.y,Math.max(raw.y,minY))) bad.push(state+': alert mark position changed');
       // Use the actual name backplate and measured mark ink, including its outline.
       var nb={x:n.x-4*z,y:n.y-(ph-3)*z,w:n.w+8*z,h:ph*z};
       ctx.save(); ctx.font=m.font; var mt=ctx.measureText(m.t); ctx.restore();
       var pad=Math.max(1,hudRes()),asc=mt.actualBoundingBoxAscent,desc=mt.actualBoundingBoxDescent;
       if(!isFinite(asc)||!isFinite(desc)){ bad.push('no ink bounds for alert mark'); return; }
       var mb={x:m.x-m.w/2-pad,y:m.y-asc-pad,w:m.w+2*pad,h:asc+desc+2*pad};
       if(Math.min(nb.x+nb.w,mb.x+mb.w)>Math.max(nb.x,mb.x)&&Math.min(nb.y+nb.h,mb.y+mb.h)>Math.max(nb.y,mb.y)) bad.push(state+': mark overlaps nameplate at baseline '+baseline);
       if(nb.y<0) bad.push(state+': nameplate is clipped at the top');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __pinDPR(1); __forceSize(1920,1080); forced=true;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no raid';
       keys={}; mouse.down=false; mouse.x=W/2; mouse.y=H/2;
       g.bagOpen=false; g.mapOpen=false; g.mapFirst=0; g.paused=false;
       g.player.iv=999; g.player.ads=false; g.shake=0; GFX.tr=0; GFX.sx=0; GFX.sy=0;
       g.anchX=g.player.x; g.anchY=g.player.y; g.leanSX=0; g.leanSY=0;
       e=mkRaider(g.player.x,g.player.y); e.name='afk_in_the_bushes'; e.hp=e.maxhp; e.parley=0; e.friendlyPC=false;
       g.ents.length=0; g.ents.push(e);
       canSee=function(px,py,face,x,y){ if(x===e.x&&y===e.y) return true; return oldSee.apply(this,arguments); };
       __frame(0);
       var edge=Math.round(msgPx(hudFS(TYPE.head))+LH(2));
       ['investigate','chase','alarm'].forEach(function(s){ sample(s,edge); sample(s,H/2); });
       sample('idle',edge);
       return bad.length?bad.join('; '):null;
     } finally {
       canSee=oldSee; mouse.x=mx; mouse.y=my; keys={};
       try{ if(g){ g.ents.length=0; g.paused=false; } __endRaid('abandon'); }catch(_e){}
       if(forced){ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }
       __topClear(); __cleanProfile();
     }
   }},
  {v:'33.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
