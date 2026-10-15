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

# THE OVERSEER RAMPAGE ENDS WHEN THE HOST LEAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.searching=null; G.searchT=0;   // v16.53: and a box the host was searching when his run ended is let go, not held for ever
'@ @'
  G.searching=null; G.searchT=0;   // v16.53: and a box the host was searching when his run ended is let go, not held for ever
  try{ (function(L){ var j, ev, b;   // v28.42 (cloud-coop-spectate-event-buffs-end), CLOUD HUNT 2026-10-15: the spectating host keeps moving the bodies for player 2 but never ticks the raid events, so a live Overseer rampage kept the Overseer fast with its lair moved for good: it ends here as its def.end restores it (no line, nothing removed, no reward)
    for(j=0;j<L.length;j++){ ev=L[j]; if(!ev||ev.ph!=='live'||ev.id!=='rampage'||!ev.d) continue;
      b=ev.d.b; if(b&&b.rmp){ b.rmp=0; if(b.rmpL){ b.lairX=b.rmpL[0]; b.lairY=b.rmpL[1]; } if(b.rmpSpd) b.spd=b.rmpSpd; }
      ev.ph='end'; ev.et=0; }
  })((G.flow&&G.flow.ev&&G.flow.ev.live)||[]); }catch(_sev){}
'@

SubRx @'
var VER='28.41';
'@ @'
var VER='28.42';
'@

$pat = "(?m)^  now:'v28\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.42: If your host extracts or goes down during an Overseer rampage, the Overseer now goes back to its lair at its normal speed instead of roaming fast for the rest of the raid. Check 28.42 fails on v28.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
