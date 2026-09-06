$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# WIRT'S LIMITED TIME OFFER SOLD WHATEVER THE CLOCK SAID AT CLICK TIME. The card
# is drawn from wirtLotKey(), which the clock picks in five-minute windows, and
# it is named and priced before he pays: that is the whole point of it (v9.11).
# But the Buy button recomputed wirtLotKey() at click time, and the card never
# redraws on the window boundary, so a click after the roll took the money and
# pushed a different lot to the stash. It sells the lot it showed him.
SubRx @'
      var lot2=wirtLotKey();
'@ @'
      var lot2=lot;   // v11.53: the lot that was NAMED AND PRICED on the card, not the clock at click time
'@

# STAMPS.
SubRx @'
var VER='11.52';
'@ @'
var VER='11.53';
'@
SubRx @'
var WHATSNEW_VER='11.52';
'@ @'
var WHATSNEW_VER='11.53';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'WIRT SELLS YOU THE THING ON THE COUNTER. If the Limited Time Offer rolled over while you were reading it, Buy used to take your money and hand you the next offer instead. You get the one that was named and priced when you clicked.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.52:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.52 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.52:[^']*'",{ param($m) "now:'v11.53: Wirt Limited Time Offer sold whatever the clock said at click time. The card is drawn from wirtLotKey, which the clock picks in five-minute windows, and the Buy button recomputed wirtLotKey at click time while the card never redraws on the boundary, so a click after the roll took the money and pushed a different lot. Buy now sells the lot the card showed. From the v11.46 audit, P1.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
