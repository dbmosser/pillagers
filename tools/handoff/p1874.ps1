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

# THE OVERSEER HEALTH BAR WAITS UNTIL YOU SEE HIM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!e||!(e.hp>0)||Math.hypot(e.x-p.x,e.y-p.y)>900) return;
'@ @'
  if(!e||!(e.hp>0)||Math.hypot(e.x-p.x,e.y-p.y)>900) return;
  // v18.74, HIS NOTE (2026-10-07): "dont show the overseers health bar until the player actually sees the overseer". Being within
  // 900 was enough, so the bar announced THE OVERSEER through walls and behind your back. It now waits until this player has
  // seen him once (canSee: the same view cone, range, darkness and walls that decide what you see), and from then on shows as
  // before while he is alive and near. Each window keeps its own: player 2 sees the bar when player 2 has seen him.
  if(!e.barSeen){ var _bsv=false; try{ _bsv=canSee(p.x,p.y,p.face,e.x,e.y,G.vseg); }catch(_bs){ _bsv=false; } if(!_bsv) return; e.barSeen=1; }
'@

SubRx @'
var VER='18.73';
'@ @'
var VER='18.74';
'@

$pat = "(?m)^  now:'v18\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.74: The Overseer health bar only appears once you have actually seen the Overseer. Check 18.74 fails on v18.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
