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

# ONE INBOUND LINE IN THE CALLED RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
       G.shipHold!==null&&G.shipHold!==undefined&&!p.downed&&dist(p,zz2)<zz2.r) continue;
'@ @'
       G.shipHold!==null&&G.shipHold!==undefined&&!p.downed&&dist(p,zz2)<zz2.r) continue;
    // v26.12 (nightfix3), found by the overnight regression run of 2026-10-13 (check 22.41, since the ring badges became caps callouts at v25.46): THE RING BADGE
    // STEPS ASIDE WHILE HE STANDS IN THE RING HE CALLED. v22.41 took the INBOUND prompt off his own character because the band above the belt says EXTRACT A INBOUND
    // with the same seconds. The ring badge now reads EXTRACTION A INBOUND 20S, over the ring he is standing in, so the same fact was on screen twice again. As in
    // the landed case just above, the badge is left out while the band shows it; from outside the ring, or for a ring he did not call, it is drawn as before.
    if(za&&G.active===zz2&&!G.over&&G.beaconT!==null&&G.beaconT!==undefined&&G.beaconT>0&&!p.downed&&dist(p,zz2)<zz2.r) continue;
'@

SubRx @'
var VER='26.11';
'@ @'
var VER='26.12';
'@

$pat = "(?m)^  now:'v26\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.12: Standing in the ring you called, the INBOUND countdown shows once, in the band, not twice. Check 26.12 fails on v26.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
