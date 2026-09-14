$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
    e.vT=(e.vT===undefined)?rnd(0,V.idle[1]):e.vT-dt;
'@ @'
    // v14.35, audio audit finding 1: THE SOUND OF THE MACHINES DRAWS FROM THE COSMETIC DICE. These voice timers, and the
    // crawler skitter in blip, drew from the seeded stream, and only a live raid with working audio ever reached them: the
    // bot returns on G.sim and the fixture has no audio context. So the same seed gave a different raid with sound on,
    // shifting every later seeded roll (weather turns, lightning, finds, loot) and breaking stream parity and every paired
    // A/B. fxn and fxi are the cosmetic stream v7.69 made for exactly this.
    e.vT=(e.vT===undefined)?fxn(0,V.idle[1]):e.vT-dt;
'@
SubRx @'
    e.vT=rnd(win[0],win[1]);
'@ @'
    e.vT=fxn(win[0],win[1]);
'@
SubRx @'
    var nCl=hn2?ri(5,8):ri(2,4);
'@ @'
    var nCl=hn2?fxi(5,8):fxi(2,4);   // v14.35: the cosmetic dice, not the seeded stream
'@
SubRx @'
var VER='14.34';
'@ @'
var VER='14.35';
'@

$pat = "(?m)^  now:'v14\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.35: THE SOUND OF THE MACHINES NO LONGER MOVES THE SEEDED WORLD. The machine voice timers and the crawler skitter drew from the seeded stream, and only a live raid with working audio reached them, so the same seed played differently with sound on than in the bot or the fixture, shifting weather, lightning, finds and loot. They now draw from the cosmetic stream. Check 14.35 counts seeded draws while a crawler voices with a fake audio context; it fails on v14.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
