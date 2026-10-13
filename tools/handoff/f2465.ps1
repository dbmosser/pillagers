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

if ($s.Contains("  {v:'24.65',what:")) { throw "check 24.65 is in the fixture already" }

SubRx @'
  {v:'24.64',what:
'@ @'
  {v:'24.65',what:'his #50 (UI redesign ui5q1e, from the AAA judge of the stash shot): on the stash the answer line sits in the footer bar, level with CLOSE (within 6px), and not across the footer hairline',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], hub, t, tr, hr, line, t0;
     try{
       __topClear(); __hubEnter(); __station('term','KeyE');
       hub=document.getElementById('hub'); t=document.getElementById('hubtoast');
       if(!hub||!hub.classList.contains('on')||!t) return 'SKIP: the stash did not open';
       t0=t.innerHTML; t.textContent='A LINE '+'FOR THE CHECK';
       tr=t.getBoundingClientRect(); t.innerHTML=t0; hr=(document.getElementById('stashclose')||{getBoundingClientRect:function(){return null;}}).getBoundingClientRect();
       if(!hr||!(hr.height>0)) return 'SKIP: the stash has no CLOSE to line up with';
       line=Math.abs((tr.top+tr.bottom)/2-(hr.top+hr.bottom)/2)/(((typeof menuScale==='function')&&menuScale())||1);
       if(!(tr.height>0)) bad.push('the answer line has no box');
       else if(line>6) bad.push('the answer line is '+Math.round(line)+'px off the level of CLOSE in the footer');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
