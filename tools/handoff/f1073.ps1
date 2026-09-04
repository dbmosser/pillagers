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
  {v:'10.72',what:'the death screen counts the gun it says you lost, in the number and in the money, and still leaves an issued loaner out of both',
'@ @'
  {v:'10.73',what:'the title screen uses a wide monitor instead of painting a narrow column down the middle, and its prose keeps a readable measure',
   run:function(){
     var bad=[];
     if(!window.__vpAlive||!__vpAlive()) return 'SKIP: the page is not laid out';
     var t=document.getElementById('title');
     if(!t) return 'SKIP: this build has no title screen';
     var col=t.querySelector('.titlecol');
     if(!col) return 'SKIP: the title screen has no column to measure';
     if(typeof __forceSize!=='function'||typeof __pinDPR!=='function') return 'SKIP: cannot pin the viewport';
     var wasOn=t.classList.contains('on');
     var shut=[];
     Array.prototype.forEach.call(document.querySelectorAll('.modal.on'),function(e){ shut.push(e); e.classList.remove('on'); });
     try{
       __pinDPR(1); __forceSize(1920,1080);
       t.classList.add('on');
       // The screen paints inside a zoom, so the honest measure is the painted
       // rectangle against the real viewport, not the css width.
       if(typeof applyMenuZoom==='function') applyMenuZoom();
       var W=window.innerWidth||1920, H=window.innerHeight||1080;
       if(W<1600) return 'SKIP: the pane is only '+W+' wide, so a wide monitor cannot be measured';
       var r=col.getBoundingClientRect();
       var used=Math.round(100*r.width/W);
       // v10.72 measured 56 percent here with 427 pixels dead on each side. The
       // floor is well under what this build paints, 81, and well over what the
       // old one did, so it names the fault rather than the exact layout.
       if(used<72) bad.push('the title screen paints '+used+' percent of a '+W+' pixel monitor, leaving '+Math.round(r.left)+' pixels empty down each side');
       if(Math.round(r.right)>W+1) bad.push('the title screen runs '+(Math.round(r.right)-W)+' pixels off the right of the screen');
       if(Math.round(r.left)<0) bad.push('the title screen starts '+Math.round(r.left)+' pixels off the left of the screen');
       // AND IT MUST STILL FIT DOWNWARDS, which is v9.53's rule and the reason
       // the column was narrow in the first place.
       if(col.scrollHeight*1>0&&Math.round(r.height)>H) bad.push('the title screen is '+Math.round(r.height)+' tall on a '+H+' screen, so it has to be scrolled');
       // THE PROSE KEEPS A MEASURE. Widening the column turned two sentences
       // into one 1,496 pixel line, which is worse to read than the narrow
       // column was, so the one block of real prose is capped.
       var intro=null;
       Array.prototype.forEach.call(col.children,function(d){
         if(/elites left the surface/.test(d.textContent||'')) intro=d; });
       if(!intro) bad.push('control: the opening sentence is not on the title screen any more, so its measure cannot be checked');
       else{
         var ir=intro.getBoundingClientRect();
         if(ir.width>1100) bad.push('the opening sentence runs '+Math.round(ir.width)+' pixels wide, which is one long line rather than a readable measure');
         if(ir.width<400) bad.push('control: the opening sentence measures only '+Math.round(ir.width)+' pixels, so something else has gone wrong');
       }
     } finally {
       if(!wasOn) t.classList.remove('on');
       for(var i=0;i<shut.length;i++) shut[i].classList.add('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.72',what:'the death screen counts the gun it says you lost, in the number and in the money, and still leaves an issued loaner out of both',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
