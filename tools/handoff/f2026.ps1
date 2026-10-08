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

if ($s.Contains("  {v:'20.26',what:")) { throw "check 20.26 is in the fixture already" }

SubRx @'
  {v:'20.25',what:
'@ @'
  {v:'20.26',what:'the stat cards are readable: titles 13px, figures 28px and the lines under them 14px',
   run:function(){
     if(typeof renderStatCards!=='function') return 'SKIP: no stats page here';
     var bad=[], c, f;
     try{ renderStatCards(); }catch(e){ return 'threw: '+(e&&e.message||e); }
     c=document.querySelector('#statgrid .scard'); if(!c) return 'SKIP: no stat cards';
     f=function(sel){ var e=c.querySelector(sel); return e?parseFloat(getComputedStyle(e).fontSize):0; };
     if(!(f('.sk')>=12.9)) bad.push('the title is '+f('.sk')+'px');
     if(!(f('.sv')>=27.9||(c.querySelector('.sv.word')&&f('.sv')>=18.9))) bad.push('the figure is '+f('.sv')+'px');
     if(c.querySelector('.ss')&&!(f('.ss')>=13.9)) bad.push('the line under it is '+f('.ss')+'px');
     return bad.length?bad.join('; '):null; }},
  {v:'20.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
