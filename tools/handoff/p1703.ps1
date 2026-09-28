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

# LETTING GO OF THE RIGHT STICK NOW ENDS AIMING, SO SUPERHOT TIME STOPS AND KID FIRING COMES BACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var rx=padAxis(ax[2]||0),ry=padAxis(ax[3]||0);
'@ @'
  var rx=padAxis(ax[2]||0),ry=padAxis(ax[3]||0);
  if(G&&!G.over) PAD.aiming=!!(rx||ry);   // v17.03, co-op hunt 2026-09-28: the aiming flag follows the right stick every raid frame; only the left stick cleared it, so with both sticks let go Superhot time ran on for the party and kid firing stayed off
'@

SubRx @'
  if(PAD.aiming) PAD.afRsT=G.t;   // v16.83, his rule: player 2 aiming with the right stick takes over from kid firing
'@ @'
  if(PAD.afRsT!=null&&PAD.afRsT>G.t) PAD.afRsT=null;   // v17.03, co-op hunt 2026-09-28: a take-over time from an earlier raid (the raid clock starts at 0 each raid) held kid firing off
  if(PAD.aiming) PAD.afRsT=G.t;   // v16.83, his rule: player 2 aiming with the right stick takes over from kid firing
'@

SubRx @'
var VER='17.02';
'@ @'
var VER='17.03';
'@

$pat = "(?m)^  now:'v17\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.03: The right stick aiming flag (PAD.aiming) was set when the right stick moved but only cleared when the left stick moved with the right stick idle, so with both sticks let go it stayed on. The Superhot gate counts it as acting, so time kept running for this window and, through the sa flag in the state word, for the other window too; and netAutoFire took it as the stick still aiming, so kid firing never came back while player 2 stood still. In a raid pollPad now sets the flag from the right stick every frame (the crosshair keeps its own PAD.aimA and PAD.curOwn). PAD.afRsT was also never cleared while the raid clock starts at 0 each raid, so a value from late in one raid held kid firing off for that many seconds of the next; netAutoFire now drops a take-over time that is ahead of the raid clock. Check 17.03 fails on v17.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
