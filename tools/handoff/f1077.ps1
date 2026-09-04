$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== AND MY OWN v10.74 CHECK CANNOT RUN AT 1440p OR 4K. Its control fires when
# ==== a full bag does not make the card scroll, which is a true statement about
# ==== the setup and NOT a fault in the build, and it reported it as a failure.
# ==== Measured: at 2560x1440 and at 3840x2160 the card has room for the whole
# ==== ledger, so the situation the check tests cannot be produced there and it
# ==== failed the build for it. A check that cannot make its case must SKIP and
# ==== say why; a SKIP is not a PASS and stays visible in the run.
SubRx @'
       if(!top.scrolls) bad.push('control: a full bag did not make the card scroll, so this check is not testing what it says');
'@ @'
       // v10.77: a taller screen gives the card room for the whole ledger, so
       // the case simply does not arise there. That is not the build failing.
       if(!top.scrolls) return 'SKIP: on a '+(window.innerHeight||0)+' pixel screen a full bag does not fill the card, so the buttons cannot be pushed off it';
'@

SubRx @'
  {v:'10.76',what:'his ten stash layouts can be reached again, the button cycles and wraps, and the stash grid really changes when it does',
'@ @'
  {v:'10.77',what:'the title screen fills the same share of the monitor at 1080p, at 1440p and at 4K, because the cap is worked out from the zoom rather than written in css',
   run:function(){
     var bad=[];
     if(!window.__vpAlive||!__vpAlive()) return 'SKIP: the page is not laid out';
     var t=document.getElementById('title');
     if(!t) return 'SKIP: this build has no title screen';
     var col=t.querySelector('.titlecol');
     if(!col) return 'SKIP: the title screen has no column to measure';
     if(typeof applyMenuZoom!=='function') return 'SKIP: no zoom fitter to drive';
     var W=window.innerWidth||0, H=window.innerHeight||0;
     if(W<1600) return 'SKIP: the pane is only '+W+' wide, so a monitor cannot be measured';
     var wasOn=t.classList.contains('on'), shut=[];
     Array.prototype.forEach.call(document.querySelectorAll('.modal.on'),function(e){ shut.push(e); e.classList.remove('on'); });
     try{
       __pinDPR(1);
       t.classList.add('on');
       applyMenuZoom();
       var r=col.getBoundingClientRect();
       var used=Math.round(100*r.width/W);
       var zoom=parseFloat(getComputedStyle(t).zoom)||1;
       // THE POINT OF THIS CHECK: the same share whatever the monitor. v10.73
       // hit 81 percent at 1080p and 45 at 4K because the cap was a css number
       // and the zoom that multiplies it is not the same at both.
       if(used<72) bad.push('the title screen paints '+used+' percent of a '+W+' by '+H+' screen, leaving '+Math.round(r.left)+' pixels empty down each side');
       if(used>92) bad.push('the title screen paints '+used+' percent of a '+W+' by '+H+' screen, which is wall to wall');
       if(Math.round(r.right)>W+1) bad.push('the title screen runs '+(Math.round(r.right)-W)+' pixels off the right at '+W+' by '+H);
       if(Math.round(r.height)>H) bad.push('the title screen is '+Math.round(r.height)+' tall on a '+H+' pixel screen, so it has to be scrolled');
       // AND THE CAP REALLY IS DERIVED, not a constant that happens to suit this
       // one screen: it must be the width the zoom needs to paint that share.
       var cap=parseFloat(getComputedStyle(col).maxWidth);
       var wantCap=Math.max(820,Math.round(W*0.80/zoom));
       if(!(cap>0)) bad.push('control: the column has no width cap at all');
       else if(Math.abs(cap-wantCap)>Math.max(24,wantCap*0.04))
         bad.push('the cap is '+Math.round(cap)+' css pixels where the zoom of '+zoom+' on a '+W+' pixel screen needs about '+wantCap);
     } finally {
       if(!wasOn) t.classList.remove('on');
       for(var i=0;i<shut.length;i++) shut[i].classList.add('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.76',what:'his ten stash layouts can be reached again, the button cycles and wraps, and the stash grid really changes when it does',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
