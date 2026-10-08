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

if ($s.Contains("  {v:'20.00',what:")) { throw "check 20.00 is in the fixture already" }

SubRx @'
  {v:'19.99',what:
'@ @'
  {v:'20.00',what:'the PARTY frame stays clear of the corner readout: in a window about 830 menu pixels tall its top line sits at least 60 pixels down, below CREDITS',
   run:function(){
     var pm=document.getElementById('partymodal'), bad=[], on0, h0, b0, fh, top;
     if(!pm) return 'SKIP: no PARTY window here';
     on0=pm.classList.contains('on'); h0=pm.style.height; b0=pm.style.bottom;
     try{
       pm.classList.add('on'); pm.style.bottom='auto'; pm.style.height='831px';
       fh=parseFloat(getComputedStyle(pm,'::before').height);
       if(!(fh>0)) return 'SKIP: the frame did not lay out';
       top=(pm.offsetHeight-fh)/2;
       if(!(top>=60)) bad.push('in an 831 pixel window the PARTY frame top is '+Math.round(top)+' pixels down, under the readout');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ pm.style.height=h0; pm.style.bottom=b0; pm.classList.toggle('on',on0); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
