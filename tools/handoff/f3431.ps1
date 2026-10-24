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

if ($s.Contains("  {v:'34.31',what:")) { throw "check 34.31 is in the fixture already" }

SubRx @'
  {v:'34.30',what:
'@ @'
  {v:'34.31',what:'pause box: the leave button is a danger ghost box, and every pause button shows the 3px lime focus ring, with one 16px gap above the leave button',
   run:function(){
     var pb=document.getElementById('pausebox'), bad=[], ids=['resumebtn','pausesetbtn','fbbtn','wnbtn','abandonbtn','arcendbtn','charselbtn'], i, b, s, shown=[], r, prev, gap, padWas=document.body.classList.contains('padon'), wasOn;
     if(!pb) return 'SKIP: no pause box here';
     wasOn=pb.classList.contains('on'); document.body.classList.remove('padon');
     try{
       b=document.getElementById('abandonbtn'); s=getComputedStyle(b);
       if(s.borderTopColor.replace(/\s/g,'')!=='rgb(229,72,47)') bad.push('the leave button has no danger box: '+s.borderTopColor);
       if(parseFloat(s.borderTopWidth)<1) bad.push('the leave button border is '+s.borderTopWidth);
       if(parseFloat(s.minHeight)!==56) bad.push('the leave button is held to '+s.minHeight);
       pb.classList.add('on');
       for(i=0;i<ids.length;i++){ b=document.getElementById(ids[i]); if(!b) continue; r=b.getBoundingClientRect(); if(r.height<1) continue; shown.push(b);
         b.classList.add('padfocus'); s=getComputedStyle(b);
         if(s.outlineStyle!=='solid'||parseFloat(s.outlineWidth)<2||s.outlineColor.replace(/\s/g,'')!=='rgb(230,255,61)') bad.push(ids[i]+' focus ring is '+s.outlineWidth+' '+s.outlineStyle+' '+s.outlineColor);
         b.classList.remove('padfocus'); }
       b=document.getElementById('abandonbtn'); if(b&&b.getBoundingClientRect().height>0){ prev=b.previousElementSibling; while(prev&&prev.getBoundingClientRect().height<1) prev=prev.previousElementSibling;
         if(prev){ gap=b.getBoundingClientRect().top-prev.getBoundingClientRect().bottom; if(gap>24) bad.push('the leave button floats '+gap+'px below the stack'); } }
     } finally { for(i=0;i<ids.length;i++){ b=document.getElementById(ids[i]); if(b) b.classList.remove('padfocus'); } if(!wasOn) pb.classList.remove('on'); document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
