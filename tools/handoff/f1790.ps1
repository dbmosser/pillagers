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

if ($s.Contains("  {v:'17.90',what:")) { throw "check 17.90 is in the fixture already" }

SubRx @'
  {v:'17.89',what:
'@ @'
  {v:'17.90',what:'the WELCOME PACK shows each item with its icon beside its name, not a bare list',
   run:function(){
     if(typeof maybeWelcome!=='function'||typeof netUpSnapP!=='function') return 'SKIP: no welcome pack in this fixture';
     var bad=[], snap=netUpSnapP(), md=document.getElementById('welcomemodal'), cvs, d, k, lit=0;
     try{
       P.welcomed=0; P.runs=0; P.stash=[]; P.weapons=[];
       maybeWelcome();
       cvs=document.querySelectorAll('#welcomelist canvas.wpic');
       if(cvs.length<5) bad.push('the welcome pack draws '+cvs.length+' icons');
       else{ d=cvs[0].getContext('2d').getImageData(0,0,cvs[0].width,cvs[0].height).data; for(k=3;k<d.length;k+=4*7) if(d[k]>0) lit++; if(lit<10) bad.push('the first icon is blank'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(md) md.classList.remove('on'); }catch(_m){} try{ if(snap) netUpPutP(snap); }catch(_p){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
