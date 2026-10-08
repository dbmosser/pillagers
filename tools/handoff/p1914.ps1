$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# A FIRST BLOTTER DOSE DRAWS THE MELT ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BUZZRNDP=null, BUZZRNDTO=null, BUZZRNDAT=0, BUZZRNDFADE=8;
'@ @'
var BUZZRNDP=null, BUZZRNDTO=null, BUZZRNDAT=0, BUZZRNDFADE=8;
var BUZZLASTK=0;   // v19.14, from the review (2026-10-07): how strongly the trip showed on the last frame; a dose arms the melt fade only when there was a melt to fade out of
'@

SubRx @'
  var k=_kx*(1.5-0.5*_kx*_kx);
'@ @'
  var k=_kx*(1.5-0.5*_kx*_kx);
  BUZZLASTK=ac*k;
'@

SubRx @'
  if(typeof P==='undefined'||!P||!P.buzz||!P.buzz.length){ buzzMenuFx(0,0); return; }
'@ @'
  if(typeof P==='undefined'||!P||!P.buzz||!P.buzz.length){ BUZZLASTK=0; buzzMenuFx(0,0); return; }
'@

SubRx @'
if(!(_bw>=0&&_bw<0.5)) BUZZRNDP=BUZZRND;
'@ @'
if(!(_bw>=0&&_bw<0.5)) BUZZRNDP=(BUZZLASTK>0.05)?BUZZRND:null;
'@

SubRx @'
var VER='19.13';
'@ @'
var VER='19.14';
'@

$pat = "(?m)^  now:'v19\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.14: Taking a first Blotter dose costs less drawing for its first seconds. Check 19.14 fails on v19.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
