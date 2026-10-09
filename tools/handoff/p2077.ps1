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

# THE STICK STEPS MENUS AT ONE SPEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  PAD.mrep=(PAD.mrep||0)-(1/60);
  if(!mv&&(Math.abs(lx)>0.6||Math.abs(ly)>0.6)&&PAD.mrep<=0){
    mv=(Math.abs(lx)>Math.abs(ly))?[lx>0?1:-1,0]:[0,ly>0?1:-1];
    PAD.mrep=0.20;
  }
'@ @'
  // v20.77, from the whole-game bug hunt of 2026-10-08 (H47): THE STICK REPEAT IN A MENU RUNS ON THE CLOCK. It took 1/60 off a
  // timer once per drawn frame, so it stepped every 12 frames: a fifth of a second at 60 Hz, but 83 ms at 144 Hz and 50 ms at
  // 240 Hz, where one quick flick moved the highlight two or three places, and 0.4 s with the frame cap at 30. It now waits a
  // fifth of a second of real time between steps at any frame rate, as the D-UP and bumper holds already do.
  var _mnow=netPadNow();
  if(!mv&&(Math.abs(lx)>0.6||Math.abs(ly)>0.6)&&!(PAD.mrepAt!=null&&_mnow-PAD.mrepAt<0.195)){
    mv=(Math.abs(lx)>Math.abs(ly))?[lx>0?1:-1,0]:[0,ly>0?1:-1];
    PAD.mrepAt=_mnow;
  }
'@

SubRx @'
var VER='20.76';
'@ @'
var VER='20.77';
'@

$pat = "(?m)^  now:'v20\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.77: On a fast monitor one flick of the stick in a menu moves the highlight one place. Check 20.77 fails on v20.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
