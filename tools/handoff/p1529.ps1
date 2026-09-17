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
          label(e.x,e.y-16,(e.name||'PILLAGER')+' DOWNED','#ffc04a',0,true);
          blip('hit');
'@ @'
          label(e.x,e.y-16,(e.name||'PILLAGER')+' DOWNED','#ffc04a',0,true);
          // v15.29, sound audit finding: A PILLAGER GOING DOWN SOUNDS WHERE HE FALLS. The hit sound here was played with no
          // distance and no pan, which blip plays at full volume and centred: the very sound damagePlayer makes when you are
          // hit. Machines fight pillagers anywhere on the map (machVsRaider), so a sentry dropping one 2000 units away played
          // your own hit with nothing on screen and no health lost, and taught you to ignore the one sound that means you are
          // being hit. It now plays at his distance and pan from you (earsOf), so a man downed beside you is still heard and
          // one downed out of earshot, past about 880 units, is not. The DOWNED label and everything else are unchanged.
          var _dnE=earsOf(e.x,e.y); blip('hit',_dnE.d,_dnE.pan);
'@
SubRx @'
var VER='15.28';
'@ @'
var VER='15.29';
'@

$pat = "(?m)^  now:'v15\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.29: A PILLAGER GOING DOWN SOUNDS WHERE HE FALLS. A pillager put on the floor anywhere on the map played the hit sound you hear when you are hit, at full volume and centred, so a machine downing one far away sounded like a hit on you with nothing on screen. It now plays at his distance and pan from you, so one downed beside you is still heard and one out of earshot is not. Check 15.29 downs a pillager 60 units west and then 1400 units east in one entity update each and requires the hit sound at his distance and on his side; it fails on v15.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
