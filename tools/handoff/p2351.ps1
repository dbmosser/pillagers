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

# ARCADE: THE HOST INITIALS CARD STAYS ON THE HOST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(ARCADE.ini&&!ARCADE.ini.mirror&&ARCADE.ini.run===run) return true;   // v23.45 (arcade22): the card from the extraction stays, letters and all
'@ @'
  if(ARCADE.ini&&!ARCADE.ini.mirror&&ARCADE.ini.run===run){ arcadeIniPost(); return true; }   // v23.45 (arcade22): the card from the extraction stays, letters and all (v23.51, arcade27: and player 2 sees it now, at RUN OVER)
'@

SubRx @'
function arcadeIniPost(){
  var n=ARCADE.ini;
  if(!n||n.mirror||ARCADE.role!=='host') return false;
'@ @'
// v23.51, HIS YES (2026-10-11) to the five recommendations, arcade27 (a low finding of the arcade 14-25 review): THE HOST INITIALS CARD
// STAYS ON THE HOST. The initials card the host opens at a top 10 extraction (arcade22) was sent to player 2 as arcinis like the
// RUN OVER card, so the player 2 window on its attract showed it and its pad went to the card (A sent arcini), and player 2 could
// not drop in while the host typed. Now the card is sent to player 2 only when no arcade raid is up here, that is at RUN OVER
// (arcade18); a card kept from the extraction is sent then. Only an arcade run reaches any of it.
function arcadeIniPost(){
  var n=ARCADE.ini;
  if(!n||n.mirror||ARCADE.role!=='host') return false;
  if(G&&G.arcade) return false;   // v23.51 (arcade27): an arcade raid is up, so the card stays on the host
'@

SubRx @'
var VER='23.50';
'@ @'
var VER='23.51';
'@

$pat = "(?m)^  now:'v23\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.51: In the arcade the initials card from a top 10 extraction stays on the host window, so player 2 can still drop in with A, and player 2 sees the card only at RUN OVER. Check 23.51 fails on v23.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
