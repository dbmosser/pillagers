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

if ($s.Contains("  {v:'16.07',what:")) { throw "check 16.07 is in the fixture already" }

SubRx @'
  {v:'16.06',what:
'@ @'
  {v:'16.07',what:'the what is new card is current again: its version is within fifteen builds of the build, it still opens with the alpha line, and the line after it says what co-op gained (going up together, loot to whoever searched, pulling a teammate up, the host leaving)',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], L=wn.lines||[];
     var vNow=parseFloat(String(wn.build||'0').replace(/[^0-9.]/g,''))||0, vCard=parseFloat(String(wn.ver||'0').replace(/[^0-9.]/g,''))||0;
     if(!(vNow&&vCard)) return 'SKIP: no version on the card or the build';
     if(vNow-vCard>0.15) bad.push('the card is at v'+wn.ver+' against a build at v'+wn.build+', more than fifteen builds behind');
     if(!L[0]||String(L[0]).toUpperCase().indexOf('ALPHA')<0) bad.push('the card no longer opens with what an alpha is');
     var t=String(L[1]||'').toUpperCase();
     ['GOES UP TOGETHER','WHOEVER SEARCHED','PULL THEM UP','IF THE HOST LEAVES'].forEach(function(w){ if(t.indexOf(w)<0) bad.push('the second card line does not say '+w.toLowerCase()); });
     return bad.length?bad.join('; '):null; }},
  {v:'16.06',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
