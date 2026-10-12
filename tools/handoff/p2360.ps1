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

# A MISS TURNS A RUNNING PILLAGER TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
              // A man running for the ring keeps running, v2.93, exactly as he
              // does when the round actually lands on him.
              if(en.state!=='extract'){ en.state='chase'; en.tx=p.x; en.ty=p.y; }
            }
'@ @'
              // A man running for the ring is turned by the line below this block (v23.xx), as a round that lands turns him (v23.59).
              if(en.state!=='extract'){ en.state='chase'; en.tx=p.x; en.ty=p.y; }
            }
            // v23.xx, HIS NOTE (2026-10-12): "a 'running' pillager bot should turn hostile when fired on". v23.59 turned a running
            // pillager (state extract) on the round that LANDS. A round that goes past him inside missWake, the same ear the peaceful
            // test above uses, is still being fired on, and he kept running for the ring through a whole magazine of misses; a man
            // already hostile was not even made alert by it. It now turns him the same way (runnerTurns: hostile, coming for you,
            // firing back, cornered). Hires never reach this line and pillagers who joined you are refused by runnerTurns.
            if(CFG.missWake>0&&en.kind==='raider'&&en.state==='extract'&&!en.downed&&!en.finished&&
               dist(b,en)<en.r+CFG.missWake) runnerTurns(en,p.x,p.y);
'@

SubRx @'
var VER='23.59';
'@ @'
var VER='23.60';
'@

$pat = "(?m)^  now:'v23\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.60: A fleeing pillager you shoot at now turns and fights back even when you miss. Check 23.60 fails on v23.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
