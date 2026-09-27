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

# SEARCHES KEEP RUNNING WHILE THE HOST SPECTATES (stability pass before his co-op session, 2026-09-27).

SubRx @'
    refreshVseg(); updateEnts(dt); updateBullets(dt); updateThrowables(dt);
'@ @'
    refreshVseg(); updateEnts(dt); updateBullets(dt); updateThrowables(dt);
    // v16.53, stability (co-op review): the host runs every search the party holds, but only in netUpTick, which stops once
    // the host run is over. So after the host died or extracted, a teammate search was granted and never moved: the bar
    // filled and nothing came out, on every box for the rest of the raid.
    netSrchTick(dt);
'@

SubRx @'
  if(G.player) G.player.specOut=1;
'@ @'
  if(G.player) G.player.specOut=1;
  G.searching=null; G.searchT=0;   // v16.53: and a box the host was searching when his run ended is let go, not held for ever
'@

SubRx @'
var VER='16.52';
'@ @'
var VER='16.53';
'@

$pat = "(?m)^  now:'v16\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.53: SEARCHES KEEP RUNNING WHILE THE HOST SPECTATES. Stability pass before a co-op session. The host window runs every search the party makes, but it stopped doing so once the host died or extracted, so for the rest of the raid a teammate search bar filled and nothing came out. A box the host was searching at that moment also stayed held by the host for ever. Both now work while the host spectates. Check 16.53 fails on v16.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
