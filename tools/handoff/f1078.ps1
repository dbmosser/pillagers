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

SubRx @'
  {v:'10.77',what:'the title screen fills the same share of the monitor at 1080p, at 1440p and at 4K, because the cap is worked out from the zoom rather than written in css',
'@ @'
  {v:'10.78',what:'no window pushes its own contents past its own box with nothing able to scroll to them, and the Depot can still reach SURPRISE ME and its three saved looks',
   run:function(){
     var bad=[];
     if(!window.__vpAlive||!__vpAlive()) return 'SKIP: the page is not laid out';
     var mods=Array.prototype.map.call(document.querySelectorAll('.modal'),function(e){ return e.id; }).filter(Boolean);
     if(!mods.length) return 'SKIP: this build has no windows to sweep';
     __pinDPR(1);
     var open=[];
     Array.prototype.forEach.call(document.querySelectorAll('.modal.on'),function(e){ open.push(e); e.classList.remove('on'); });
     function shutAll(){ Array.prototype.forEach.call(document.querySelectorAll('.modal.on'),function(e){ e.classList.remove('on'); }); }
     try{
       // 1. EVERY WINDOW: nothing may sit past the box when the box itself cannot
       //    scroll. v5.31's rule is that the window holds still and the list
       //    inside it scrolls, so a window with content past its own edge and
       //    overflow hidden has content NOBODY can reach.
       mods.forEach(function(id){
         shutAll();
         var m=document.getElementById(id); m.classList.add('on');
         if(typeof applyMenuZoom==='function') applyMenuZoom();
         m.scrollTop=0;
         var cut=m.scrollHeight-m.clientHeight;
         if(cut>2&&getComputedStyle(m).overflowY==='hidden')
           bad.push(id+' pushes '+cut+' pixels past its own box and cannot be scrolled, so that much of it cannot be reached');
       });
       // 2. THE DEPOT IN PARTICULAR, because that is where it cost a feature:
       //    SURPRISE ME and the three LOOKS slots sat 412 to 643 pixels below
       //    the window. They must be reachable by scrolling something.
       shutAll();
       var ap=document.getElementById('appearmodal');
       if(!ap) bad.push('control: there is no Depot window to check');
       else{
         ap.classList.add('on');
         try{ if(typeof renderAvatar==='function') renderAvatar('appavatar','appavatarpicker'); }catch(_r){}
         if(typeof applyMenuZoom==='function') applyMenuZoom();
         var g=ap.querySelector('.hubgrid');
         var sur=document.getElementById('looksurprise');
         if(!sur) bad.push('control: SURPRISE ME is not on the Depot at all, so this cannot test reaching it');
         else if(!g) bad.push('control: the Depot has no grid to scroll');
         else{
           var mr=ap.getBoundingClientRect();
           g.scrollTop=0;
           var atTop=sur.getBoundingClientRect().bottom-mr.bottom;
           g.scrollTop=g.scrollHeight;
           var atBot=sur.getBoundingClientRect().bottom-mr.bottom;
           g.scrollTop=0;
           if(atBot>1) bad.push('SURPRISE ME is still '+Math.round(atBot)+' pixels below the Depot window even scrolled all the way down');
           // AND THE WHEEL CAN DO IT: the game only scrolls a box whose overflow
           // is auto or scroll, so hidden would leave it unreachable in play.
           var ov=getComputedStyle(g).overflowY;
           if(g.scrollHeight>g.clientHeight+2&&ov!=='auto'&&ov!=='scroll')
             bad.push('the Depot grid overflows by '+(g.scrollHeight-g.clientHeight)+' pixels and its overflow is '+ov+', which the wheel will not scroll');
           // 3. AND THE FOOTER STAYS, which is the whole point of v5.31.
           var cl=document.getElementById('closeappear');
           if(cl){ var cr=cl.getBoundingClientRect();
             if(cr.bottom>mr.bottom+1) bad.push('CLOSE has been pushed '+Math.round(cr.bottom-mr.bottom)+' pixels off the bottom of the Depot');
             if(atTop<=1) bad.push('control: SURPRISE ME was already in view at the top, so this check proves nothing');
           }
         }
       }
     } finally {
       shutAll();
       for(var i=0;i<open.length;i++) open[i].classList.add('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.77',what:'the title screen fills the same share of the monitor at 1080p, at 1440p and at 4K, because the cap is worked out from the zoom rather than written in css',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
