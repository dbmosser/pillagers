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

SubRx @'
      P.wirtLotBought=lotHr;   // v13.60: the window of the lot he bought, not the clock at the click
      P.gambleLog=P.gambleLog||[]; P.gambleLog.push(lot2[0]);
      if(P.gambleLog.length>40) P.gambleLog.shift();
'@ @'
      P.wirtLotBought=lotHr;   // v13.60: the window of the lot he bought, not the clock at the click
      // v15.04, wirt audit finding: BUYING THE LIMITED TIME OFFER IS NOT LOGGED AS A GAMBLE ROLL. This handler pushed the lot's
      // first item onto P.gambleLog, the history renderGamble lists under THE GAMBLE, so a 10,000 purchase showed as a 2,500 roll
      // he never made, and only the headline item of the lot. The gamble button's own push is the only writer of that history now.
'@
SubRx @'
var VER='15.03';
'@ @'
var VER='15.04';
'@

$pat = "(?m)^  now:'v15\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.04: BUYING THE LIMITED TIME OFFER IS NOT LOGGED AS A GAMBLE ROLL. Buying the offer put the first item of its lot in the roll history under THE GAMBLE, as if a roll had produced it, though nothing was rolled. The purchase no longer writes to that history, and a real roll still does. Check 15.04 buys the offer with nothing rolled and reads the roll history; it fails on v15.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
