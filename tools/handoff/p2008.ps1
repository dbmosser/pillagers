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

# THE JIGGLE FOLLOWS THE BODY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  J.t=now; v=(ty-J.py)/dt; a=v-J.pv; J.py=ty; J.pv=v;
  if(a>400) a=400; else if(a<-400) a=-400;
  J.vc-=a*0.40; J.vh-=a*0.26;
  J.vc+=(-320*J.c-9*J.vc)*dt; J.c+=J.vc*dt;
  J.vh+=(-240*J.h-9*J.vh)*dt; J.h+=J.vh*dt;
'@ @'
  // v20.08, measured walking in a raid (2026-10-08): the first spring rang at 2.85 a second, and a walk lands a foot 2.9 times a
  // second (a bob of 9 a second), so every step pumped it until it sat on its stop. It is a quicker spring now, about 6 a second,
  // clear of the walk (2.9) and the sprint (4.8), damped so each wobble is gone before the next step, and stepped in slices of
  // 16 ms so a slow frame cannot throw it. It is fed only the body's own rise and fall (see drawOp), never the walk across the map.
  J.t=now; v=(ty-J.py)/dt; a=v-J.pv; J.py=ty; J.pv=v;
  if(a>400) a=400; else if(a<-400) a=-400;
  J.vc-=a*0.85; J.vh-=a*0.50;
  var _n=Math.max(1,Math.ceil(dt/0.016)), _h=dt/_n, _i;
  for(_i=0;_i<_n;_i++){
    J.vc+=(-1400*J.c-18*J.vc)*_h; J.c+=J.vc*_h;
    J.vh+=(-1000*J.h-16*J.vh)*_h; J.h+=J.vh*_h;
  }
'@

SubRx @'
_JG=(_BLD==='curved')?bodyJiggle(st.own,ty):JIG0;
'@ @'
_JG=(_BLD==='curved')?bodyJiggle(st.own,ty-y):JIG0;
'@

SubRx @'
var VER='20.07';
'@ @'
var VER='20.08';
'@

$pat = "(?m)^  now:'v20\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.08: The Curved jiggle bounces with each step and settles, instead of shaking. Check 20.08 fails on v20.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
