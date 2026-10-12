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

# A RUNNING PILLAGER FIRED ON FIGHTS BACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
              if(en.kind==='raider'&&en.state==='extract'){ en.alert=2.6; }
'@ @'
              if(en.kind==='raider'&&en.state==='extract'){ if(!runnerTurns(en,p.x,p.y)) en.alert=2.6; }   // v23.xx, his note: a running pillager fired on turns and fights
'@

SubRx @'
  if(e.kind==='raider'&&e.state==='extract'){ e.alert=2.6; }
'@ @'
  if(e.kind==='raider'&&e.state==='extract'){ if(!runnerTurns(e,sx,sy)) e.alert=2.6; }   // v23.xx: the same for a round from one of the party
'@

SubRx @'
if(e.kind==='raider'&&e.state!=='extract'&&e.hp<e.maxhp*0.3){
'@ @'
if(e.kind==='raider'&&e.state!=='extract'&&!e.cornered&&e.hp<e.maxhp*0.3){   // v23.xx: a man who turned on the one shooting him (runnerTurns) does not bolt again
'@

SubRx @'
// v21.62, his note: a hostile pillager hit by a round turns to the shooter
'@ @'
// v23.xx, HIS NOTE (2026-10-12): "a 'running' pillager bot should turn hostile when fired on". Since v2.93 a pillager running for a
// ring (state extract, under 30 percent health) was only made more alert by a round and kept running. Fired on by the player or one of
// the party, he now turns: hostile, chasing the shooter, firing back (returnFire), and cornered, so the low-health rule does not send
// him running again on the next frame. Hires and pillagers who threw in with you keep the old rule. No draw on any stream.
function runnerTurns(e,sx,sy){
  if(!e||e.kind!=='raider'||e.merc||e.friendlyPC||e.downed||e.hp<=0) return false;
  e.cornered=1; e.hostile=true; e.state='chase'; e.alert=2.6; e.tx=sx; e.ty=sy;
  returnFire(e,sx,sy);
  return true;
}
// v21.62, his note: a hostile pillager hit by a round turns to the shooter
'@

SubRx @'
var VER='23.58';
'@ @'
var VER='23.59';
'@

$pat = "(?m)^  now:'v23\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.59: A fleeing pillager you shoot now turns and fights back instead of running. Check 23.59 fails on v23.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
