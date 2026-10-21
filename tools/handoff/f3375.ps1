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

if ($s.Contains("  {v:'33.75',what:")) { throw "check 33.75 is in the fixture already" }

SubRx @'
  {v:'33.74',what:
'@ @'
  {v:'33.75',what:'cw-cx-pixhubframe: real Undercroft frames reset the sprite budget once, allowing a cold FASHION preview to become pixel art without test-only pixFrame calls; bodies stay nearest at 4x while their unchanged ground shadow stays smooth',
   run:function(){
     if(!(window.__hubEnter&&window.__hubFrame)) return 'SKIP: no hub frame staging';
     var oldPix=CFG.xfPix, oldFrame=pixFrame, oldBlit=pxBlit, oldShadow=shadowE, oldAngle=AVANG, oldPhase=AVPH, oldTimer=AVTMR, oldState=state, oldHB=HB, oldWc=wc, oldFB=PIX.fB, oldMs=PIX.fMs, hubSnap={}, playerSnap={}, modals=[], oldHubClass='', bad=[], c, made=false, frames=0, layers=0, soft=0, i, k, f0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); CFG.xfPix=1;
       modals=[].slice.call(document.querySelectorAll('.modal')).map(function(e){ return {e:e,cls:e.className}; });
       oldHubClass=document.getElementById('hub').className;
       if(oldHB){ for(k in oldHB) hubSnap[k]=oldHB[k]; if(oldHB.player) for(k in oldHB.player) playerSnap[k]=oldHB.player[k]; }
       __hubEnter();
       // One ordinary crowd body plus the player exercises the real frame path without warming the whole town for a preview check.
       HB.crowd=(HB.crowd||[]).slice(0,1);
       [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(e){ e.classList.remove('on'); });
       c=document.getElementById('avcv');
       if(!c){ c=document.createElement('canvas'); c.id='avcv'; c.width=380; c.height=470; c.style.display='none'; document.body.appendChild(c); made=true; }
       AVANG=0; AVPH=0; f0=pixFaults();
       pixFrame=function(){ frames++; return oldFrame(); };
       pxBlit=function(s,x,y,m){
         var answer=oldBlit.apply(this,arguments);
         if(wc.canvas===c){ layers++; if(m.a!==4||wc.imageSmoothingEnabled) bad.push('a body layer is not nearest 4x'); }
         return answer;
       };
       shadowE=function(){ if(wc.canvas===c){ soft++; if(!wc.imageSmoothingEnabled) bad.push('the existing soft preview shadow was made blocky'); } return oldShadow.apply(this,arguments); };
       // A real previous frame has spent its budget. Only drawHubWorld may reset it here.
       PIX.fB=PIXSTORE.maxBuilds; PIX.fMs=PIXSTORE.maxMs;
       for(i=0;i<24;i++){
         __hubFrame(0); drawAvatarCanvas();
         if(frames!==i+1){ bad.push('hub frame '+i+' reset its budget '+frames+' times, wanted '+(i+1)); break; }
         if(PIX.fB>PIXSTORE.maxBuilds) bad.push('hub and preview exceeded the shared sprite build cap');
         if(layers>=2) break;
       }
       if(layers<2) bad.push('a cold preview stayed vector through real hub frames');
       if(!soft) bad.push('the preview ground shadow did not draw');
       if(pixFaults()>f0) bad.push('a pixel builder threw');
       return bad.length?bad.slice(0,8).join('; '):null;
     } finally {
       pixFrame=oldFrame; pxBlit=oldBlit; shadowE=oldShadow; AVANG=oldAngle; AVPH=oldPhase;
       if(AVTMR!==oldTimer){ if(AVTMR) clearInterval(AVTMR); AVTMR=oldTimer; }
       if(made&&c&&c.parentNode) c.parentNode.removeChild(c);
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=oldPix;
       if(oldHB){ for(k in oldHB) if(!Object.prototype.hasOwnProperty.call(hubSnap,k)) delete oldHB[k]; for(k in hubSnap) oldHB[k]=hubSnap[k]; if(oldHB.player){ for(k in oldHB.player) if(!Object.prototype.hasOwnProperty.call(playerSnap,k)) delete oldHB.player[k]; for(k in playerSnap) oldHB.player[k]=playerSnap[k]; } }
       HB=oldHB; state=oldState; wc=oldWc; PIX.fB=oldFB; PIX.fMs=oldMs;
       [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(e){ e.classList.remove('on'); });
       modals.forEach(function(m){ m.e.className=m.cls; });
       document.getElementById('hub').className=oldHubClass;
     } }},
  {v:'33.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
