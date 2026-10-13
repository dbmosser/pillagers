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

if ($s.Contains("  {v:'24.72',what:")) { throw "check 24.72 is in the fixture already" }

SubRx @'
  {v:'24.71',what:
'@ @'
  {v:'24.72',what:'his #50 (UI redesign ui5q1f, from the AAA judge of the raid pause shot): in the pause box RESUME RUN is the amber primary, the buttons are at least 46px tall with 16px labels, ABANDON RUN is not filled amber, and the key legend is 15px with its keys drawn as keycaps',
   run:function(){
     var pb=document.getElementById('pausebox'), rs=document.getElementById('resumebtn'), ab=document.getElementById('abandonbtn'), pk=document.getElementById('pausekeys'), bad=[], s, b, acc;
     if(!pb||!rs||!pk) return 'SKIP: no pause box here';
     try{
       if(typeof keysLegendApply==='function') keysLegendApply();
       acc=getComputedStyle(document.documentElement).getPropertyValue('--acc').trim()||'#f5b73b';
       s=getComputedStyle(rs);
       if(s.backgroundColor!=='rgb(245, 183, 59)') bad.push('RESUME RUN is not the amber primary ('+s.backgroundColor+', the accent is '+acc+')');
       if(!(parseFloat(s.fontSize)>=16)) bad.push('RESUME RUN is '+s.fontSize);
       if(!(parseFloat(s.minHeight)>=46)) bad.push('RESUME RUN is held to '+s.minHeight);
       if(ab&&getComputedStyle(ab).backgroundColor==='rgb(245, 183, 59)') bad.push('ABANDON RUN is filled amber too');
       if(!(parseFloat(getComputedStyle(pk).fontSize)>=15)) bad.push('the key legend is '+getComputedStyle(pk).fontSize);
       b=document.createElement('b'); b.textContent='K'; pk.appendChild(b); s=getComputedStyle(b); var bw=parseFloat(s.borderBottomWidth), bs=s.borderBottomStyle; pk.removeChild(b);   // a key as the legend writes it
       if(!(bw>0.5)||bs==='none') bad.push('the legend keys are bold words, not keycaps ('+bw+' '+bs+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
