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

# WITH THE WHOLE PARTY PAUSED A TEAMMATE SEARCH STANDS STILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(NET.role==='host') netSrchTick(dt); else if(NET.role==='join') netSrchSync();   // v15.91: the host runs every search one of the party holds; a linked window tells the host when its own hold ended
'@ @'
  // v16.96, co-op hunt 2026-09-28: a party search on the host ran on the raw frame time, so with the whole party paused and the
  // world stopped a teammate box kept filling, paying out and sounding. It now stands still whenever the world does, as in netSpecTick.
  if(NET.role==='host') netSrchTick((G.paused&&!netPauseLive())?0:dt); else if(NET.role==='join') netSrchSync();   // v15.91: the host runs every search one of the party holds; a linked window tells the host when its own hold ended
'@

SubRx @'
var VER='16.95';
'@ @'
var VER='16.96';
'@

$pat = "(?m)^  now:'v16\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.96: Co-op hunt 2026-09-28, loot: netUpTick runs every raid frame before any pause test and handed the raw frame time to netSrchTick, so on the host a search one of the party held kept filling, paying out, pinging and sounding the strongbox alarm with every player paused and the world stopped; the paused teammate window runs no updatePlayer, so his hold was never let go either. The host now hands netSrchTick no time while the whole party is paused (G.paused and not netPauseLive, the same test that stops the world), as netSpecTick already does for a spectating host. The held and free bookkeeping still runs. No number moved and no new words. Check 16.96 fails on v16.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
