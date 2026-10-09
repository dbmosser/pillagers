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

if ($s.Contains("  {v:'21.36',what:")) { throw "check 21.36 is in the fixture already" }

SubRx @'
  {v:'21.35',what:
'@ @'
  {v:'21.36',what:'the run card button strip runs the full width of the card, so it never shows as a box inset behind the two buttons, and the card does not scroll sideways for it',
   run:function(){
     var oc=document.getElementById('outcome'), w=oc&&oc.querySelector('.ocwin'), a=oc&&oc.querySelector('.ocacts'), was=oc&&oc.classList.contains('on'), bad=[], cw, gl, gr;
     if(!oc||!w||!a) return 'SKIP: no run card here';
     try{
       oc.classList.add('on');
       cw=w.clientWidth;
       if(!(cw>200&&a.offsetWidth>50)) return 'SKIP: the run card is not laid out ('+cw+' wide)';
       if(a.offsetParent!==w) return 'SKIP: the button strip is not measured from the card here';
       gl=a.offsetLeft; gr=cw-(a.offsetLeft+a.offsetWidth);
       if(gl>3) bad.push('the button strip starts '+gl+' px in from the left edge of the card, so it shows as a box behind the buttons');
       if(gr>3) bad.push('the button strip stops '+gr+' px short of the right edge of the card');
       if(w.scrollWidth>cw+1) bad.push('the card scrolls sideways ('+w.scrollWidth+' of content in '+cw+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(!was) oc.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
