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

# A SPRINT TAKES YOU OUT OF FOCUS AIM (his order 2026-09-27, during his co-op session; both players, pad and keyboard).

SubRx @'
  if(_shHeld&&mg>0&&G.crouchTog&&!p.downed&&
'@ @'
  // v16.81, his order: A SPRINT TAKES YOU OUT OF FOCUS AIM. Holding sprint while moving did nothing in focus aim (player 2 on a
  // pad hit it at once, with focus aim on LT and a toggle on the right stick click). Sprint now wins: focus aim drops, and a pad
  // toggle and the settle after a shot are let go, so a held LT is the only thing that brings it back once the sprint ends.
  if(_shHeld&&mg>0&&p.ads&&!p.downed&&p.stam>2&&!p.stamLock&&!p.stamRelease){ p.ads=false; if(typeof PAD!=='undefined'&&PAD){ PAD.adsTog=false; PAD.adsT=0; } }
  if(_shHeld&&mg>0&&G.crouchTog&&!p.downed&&
'@

SubRx @'
  if(PAD.adsT>0||PAD.adsTog||(trig(6)>0.35&&!G.over&&!G.paused)){ G.player.ads=true; PAD.adsing=1; }
'@ @'
  if((PAD.adsT>0||PAD.adsTog||(trig(6)>0.35&&!G.over&&!G.paused))&&!(pressed(10)&&G.player&&G.player.moving)){ G.player.ads=true; PAD.adsing=1; }   // v16.81: never while sprinting
'@

SubRx @'
var VER='16.80';
'@ @'
var VER='16.81';
'@

$pat = "(?m)^  now:'v16\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.81: A SPRINT TAKES YOU OUT OF FOCUS AIM. His order during his co-op session: sprinting did nothing while in focus aim, and player 2 on a pad kept hitting it. Holding sprint while moving now drops focus aim, and on a pad it also lets go of the right stick toggle. Check 16.81 fails on v16.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
