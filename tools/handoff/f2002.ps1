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

if ($s.Contains("  {v:'20.02',what:")) { throw "check 20.02 is in the fixture already" }

SubRx @'
  {v:'20.01',what:
'@ @'
  {v:'20.02',what:'a Curved body jiggles and settles: when the torso jumps the chest spring moves, and after two seconds still it is back at rest',
   run:function(){
     if(typeof bodyJiggle!=='function') return 'control: there is no jiggle spring in this build';
     var o={}, t=1000, i, J, peak=0, bad=[];
     J=bodyJiggle(o,100,t);
     for(i=0;i<10;i++){ t+=16.7; J=bodyJiggle(o,100,t); }
     if(Math.abs(J.c)>0.001) bad.push('a still body jiggles ('+J.c.toFixed(3)+')');
     for(i=0;i<6;i++){ t+=16.7; J=bodyJiggle(o,100-i*2.5,t); peak=Math.max(peak,Math.abs(J.c)); }
     for(i=0;i<6;i++){ t+=16.7; J=bodyJiggle(o,85,t); peak=Math.max(peak,Math.abs(J.c)); }
     if(!(peak>0.2)) bad.push('the chest did not move when the torso jumped (peak '+peak.toFixed(3)+')');
     for(i=0;i<120;i++){ t+=16.7; J=bodyJiggle(o,85,t); }
     if(!(Math.abs(J.c)<0.05&&Math.abs(J.h)<0.05)) bad.push('the spring did not settle ('+J.c.toFixed(3)+', '+J.h.toFixed(3)+')');
     var J2=bodyJiggle(o,85,t+1);
     if(J2!==J||J2.c!==J.c) bad.push('a second draw in the same frame stepped the spring');
     return bad.length?bad.join('; '):null; }},
  {v:'20.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
