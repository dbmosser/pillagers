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

if ($s.Contains("  {v:'29.55',what:")) { throw "check 29.55 is in the fixture already" }

SubRx @'
  {v:'29.54',what:
'@ @'
  {v:'29.55',what:'the pause card is a title and one column of 56px sentence-case buttons at the menu width, with no key legend or feedback sentence on a keyboard card',
   run:function(){
     var pb=document.getElementById('pausebox'), box, rs, ab, pk, fs, padWas, bad=[], cs, s, i, ids=['resumebtn','pausesetbtn','fbbtn','wnbtn'], b;
     if(!pb) return 'SKIP: no pause box here';
     padWas=document.body.classList.contains('padon'); document.body.classList.remove('padon');
     try{
       rs=document.getElementById('resumebtn'); ab=document.getElementById('abandonbtn'); pk=document.getElementById('pausekeys'); box=rs&&rs.parentNode;
       if(!box||!ab||!pk) return 'no pause buttons or key line';
       if(getComputedStyle(box).flexDirection!=='column') bad.push('the pause buttons are a '+getComputedStyle(box).flexDirection+', not a column');
       for(i=0;i<ids.length;i++){ b=document.getElementById(ids[i]); if(!b) continue; s=getComputedStyle(b);
         if(parseFloat(s.minHeight)!==56) bad.push(ids[i]+' is held to '+s.minHeight+', not 56px');
         if(s.textTransform!=='none') bad.push(ids[i]+' is drawn in '+s.textTransform); }
       if(getComputedStyle(pk).display!=='none') bad.push('the key legend still sits on the keyboard pause card');
       fs=[].filter.call(pb.children,function(c){ return c.tagName==='DIV'&&/Please provide feedback/.test(c.textContent); })[0];
       if(fs&&getComputedStyle(fs).display!=='none') bad.push('the feedback sentence still sits on the pause card');
       if(parseFloat(getComputedStyle(ab).marginTop)<24) bad.push('Abandon is not set apart ('+getComputedStyle(ab).marginTop+')');
       document.body.classList.add('padon');
       if(getComputedStyle(pk).display==='none') bad.push('a pad loses its legend');
     } finally { document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'29.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
