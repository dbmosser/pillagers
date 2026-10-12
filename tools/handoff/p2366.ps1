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

# A FRAGGED RUNNER TURNS FOR GOOD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(e.state!=='alarm'&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.downed&&!e.merc){   // v13.96, AI audit: a blast never turns your hire on you
        e.state='chase'; e.alert=2.5;
        if(_fMine){ e.tx=p.x; e.ty=p.y; } else { e.tx=f.x; e.ty=f.y; }
      }
'@ @'
      var _fRun=(e.kind==='raider'&&e.state==='extract');   // v23.xx: was he running for a ring when the charge went off?
      if(e.state!=='alarm'&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.downed&&!e.merc){   // v13.96, AI audit: a blast never turns your hire on you
        e.state='chase'; e.alert=2.5;
        if(_fMine){ e.tx=p.x; e.ty=p.y; } else { e.tx=f.x; e.ty=f.y; }
      }
      // v23.xx, his note (2026-10-12): "a 'running' pillager bot should turn hostile when fired on". Your own charge into a man running
      // for a ring set him chasing, but not cornered, so the low health rule sent him running again on the very next frame. He now
      // turns for good, as a round does since v23.59 (runnerTurns: hostile, cornered, firing back).
      if(_fMine&&_fRun&&e.hp>0&&!e.downed) runnerTurns(e,p.x,p.y);
'@

SubRx @'
var VER='23.65';
'@ @'
var VER='23.66';
'@

$pat = "(?m)^  now:'v23\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.66: A fleeing pillager hit by your frag now turns and fights instead of running again. Check 23.66 fails on v23.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
