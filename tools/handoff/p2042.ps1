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

# SHOOTING THE PEDDLER LEAVES HIS STALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
              else if(en.kind!=='snitch'){ en.alert=2.6; en.state='chase'; en.tx=p.x; en.ty=p.y; }
'@ @'
              // v20.42, from the whole-game bug hunt of 2026-10-08 (H2): A ROUND INTO THE PEDDLER DOES NOT MOVE HIS STALL. His tx/ty
              // are his pitch, not a target, so this line set his table, stock and lantern down where you fired from, and left him
              // in 'chase' for the rest of the raid: the red mark, a place in the count coming for the ring, the threat music and the
              // heartbeat. He still bolts and comes home (his own branch reads his health). The Survivor is a fixture too. A blast
              // has skipped both since v11.36; a round now does the same.
              else if(en.kind!=='snitch'){ if(en.kind!=='peddler'&&en.kind!=='stray'){ en.alert=2.6; en.state='chase'; en.tx=p.x; en.ty=p.y; } }
'@

SubRx @'
  else if(e.kind!=='snitch'){ e.alert=2.6; e.state='chase'; e.tx=sx; e.ty=sy; }
'@ @'
  else if(e.kind!=='snitch'){ if(e.kind!=='peddler'&&e.kind!=='stray'){ e.alert=2.6; e.state='chase'; e.tx=sx; e.ty=sy; } }   // v20.42 (H2): a party round into the Peddler or the Survivor moves no stall and sets no chase, as your own round
'@

SubRx @'
var VER='20.41';
'@ @'
var VER='20.42';
'@

$pat = "(?m)^  now:'v20\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.42: Shooting the Peddler no longer moves his stall or marks him as hunting you. Check 20.42 fails on v20.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
