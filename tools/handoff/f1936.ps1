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

if ($s.Contains("  {v:'19.36',what:")) { throw "check 19.36 is in the fixture already" }

SubRx @'
  {v:'19.35',what:
'@ @'
  {v:'19.36',what:'the run card buttons sit on a solid strip: the pinned button row has an opaque background, with the fade in a strip above it',
   run:function(){
     var a=document.querySelector('#outcome .ocacts'), oc=document.getElementById('outcome'), was=oc&&oc.classList.contains('on'), bad=[], s, b, m;
     if(!a||!oc) return 'SKIP: no run card here';
     try{
       oc.classList.add('on');
       s=getComputedStyle(a); b=getComputedStyle(a,'::before');
       m=(/rgba?\(([^)]*)\)/).exec(s.backgroundColor||'');
       if(/rgba\(0,\s*0,\s*0,\s*0\)/.test(s.backgroundImage||'')) bad.push('the button row background starts clear, so the tags show round the buttons');
       if(!m||(m[1].split(',').length>3&&parseFloat(m[1].split(',')[3])<0.95)) bad.push('the button row has no solid colour ('+s.backgroundColor+')');
       if(!(parseFloat(b.height)>10)) bad.push('there is no fade strip above the button row');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(!was) oc.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
