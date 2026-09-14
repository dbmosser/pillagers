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

# UNDERCROFT AUDIT OF 2026-09-14, finding 2: BUYING WIRT'S LOT JUST AFTER IT CHANGED MARKED THE
# NEXT LOT AS BOUGHT. The card captures its lot when it is drawn and v11.61 buys that exact
# lot at the click, but the bought stamp used the clock at the click. Nothing redraws the
# card on a timer, so a click after the five minute change paid for the old lot and stamped
# the new window: the card read Bought and he was locked out of a lot he never saw. The
# card now remembers the window it was drawn for and the purchase stamps that window.
SubRx @'
  var lot=wirtLotKey(), k=lot[0], it=ITEMS[k];
'@ @'
  var lot=wirtLotKey(), k=lot[0], it=ITEMS[k], lotHr=wirtLotHour();   // v13.60: the window this card was drawn for
'@
SubRx @'
      P.wirtLotBought=wirtLotHour();
'@ @'
      P.wirtLotBought=lotHr;   // v13.60: the window of the lot he bought, not the clock at the click
'@
SubRx @'
var VER='13.59';
'@ @'
var VER='13.60';
'@

$pat = "(?m)^  now:'v13\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.60: BUYING WIRT S LOT NEVER LOCKS YOU OUT OF THE NEXT ONE. Undercroft audit of 2026-09-14, finding 2: the lot card captures its lot when drawn and v11.61 buys that lot at the click, but the bought stamp used the clock at the click, and nothing redraws the card on a timer, so a click after the five minute change paid for the old lot and stamped the new window, locking him out of a lot he never saw. The card now remembers the window it was drawn for and the purchase stamps that window. Check 13.60 draws the card in one window, moves the clock to the next before the click, and requires the stamp to name the window drawn, with no change of window as the control; it fails on v13.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
