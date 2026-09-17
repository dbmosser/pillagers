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
    var _ce=G.ents[_ci];
    if(_ce.dead||_ce.kind==='peddler'||_ce.kind==='stray') continue;
'@ @'
    var _ce=G.ents[_ci];
    // v15.42, hud audit finding: CROUCHED BESIDE YOUR HIRE OR A DOWNED PILLAGER, THE READOUT SAYS HIDDEN. The nearest body here
    // skipped only the Peddler and a survivor, so your own hire counted as someone standing too close to hide from. He starts on
    // FOLLOW and walks back whenever he is more than 120 away, inside the 170 of the crouch rule, so crouched in a quiet spot with
    // every hostile far off the plate read PARTLY HIDDEN, TOO CLOSE in amber while nothing could find him: updateEnts never lets a
    // hire into the branch that turns a body that sees him on him, and its crouch rule already hides him from everything past 170.
    // A pillager lying downed did the same, though the downed branch there skips his sight entirely, and a finished one did for
    // its last frame. All three are skipped now, so TOO CLOSE names only a body that can give him away. The crouch rule, the 170,
    // every word on the plate and every number are unchanged.
    if(_ce.dead||_ce.merc||_ce.downed||_ce.finished||_ce.kind==='peddler'||_ce.kind==='stray') continue;
'@
SubRx @'
var VER='15.41';
'@ @'
var VER='15.42';
'@

$pat = "(?m)^  now:'v15\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.42: CROUCHED BESIDE YOUR HIRE OR A DOWNED PILLAGER, THE READOUT SAYS HIDDEN. Crouched in a quiet spot with his hire following, the plate read PARTLY HIDDEN, TOO CLOSE in amber, because the hire and any downed pillager counted as someone close enough to see him, though neither can give him away. The plate now counts only bodies that can, so it reads HIDDEN, CROUCHED there and still warns TOO CLOSE for a standing pillager. Check 15.42 crouches with a hire and then a downed pillager 60 units away and reads the drawn plate, a standing pillager at 60, the hire at 400 and the hire beside a standing pillager as controls; it fails on v15.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
