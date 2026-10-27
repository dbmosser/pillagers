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

if ($s.Contains("  {v:'34.94',what:")) { throw "check 34.94 is in the fixture already" }

SubRx @'
  {v:'34.93',what:
'@ @'
  {v:'34.94',what:'the difficulty button in Settings has the same two arrows as every other switch in the list (it read as a link to another page)',
   run:function(){
     if(typeof diffRowHtml!=='function') return 'no difficulty row';
     var bad=[], b, g, i, p, x, y;
     try{
       __topClear(); __runPrep(); SETSUB=''; renderSettings();
       b=document.getElementById('set_diff'); g=document.querySelector('#setlist .row > button[id^="go_"]');
       if(!b) bad.push('no difficulty button on the Settings page');
       else if(!g) bad.push('no other switch on the Settings page to compare with');
       else {
         for(p=['::before','::after'],i=0;i<p.length;i++){
           x=getComputedStyle(b,p[i]).content; y=getComputedStyle(g,p[i]).content;
           if(!x||x==='none'||x==='normal') bad.push('the difficulty button has no '+(i?'right':'left')+' arrow');
           else if(x!==y) bad.push('the difficulty button '+(i?'right':'left')+' arrow is '+x+', the other switches show '+y);
         }
         if(getComputedStyle(b).display!==getComputedStyle(g).display) bad.push('the difficulty button lays out as '+getComputedStyle(b).display+', the other switches as '+getComputedStyle(g).display);
       }
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ SETSUB=''; try{ renderSettings(); __topClear(); }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'34.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
