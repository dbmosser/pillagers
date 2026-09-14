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

# v14.99, copies audit finding 3: THE DATA CORE PRICE ON THE MAINFRAME IS THE PRICE IT SELLS FOR. The line said $520 whatever the
# How much is out there setting, while the stash hover and Sell one pay ival('core'), which that setting scales. Only the branch with
# a core in the stash changes: the branch with none is his baked key and stays byte for byte.
SubRx @'
    :('Spend a Data Core ($520 on the shelf) and your next raid deploys knowing things: every locked-room key location and every elite, live on the M map. '+(P.stash.indexOf('core')>=0?'One is in the stash.':'None in the stash right now.')); }
'@ @'
    :(P.stash.indexOf('core')>=0
      ?('Spend a Data Core ($'+ival('core').toLocaleString()+' on the shelf) and your next raid deploys knowing things: every locked-room key location and every elite, live on the M map. One is in the stash.')
      :'Spend a Data Core ($520 on the shelf) and your next raid deploys knowing things: every locked-room key location and every elite, live on the M map. None in the stash right now.'); }   // v14.99
'@
SubRx @'
var VER='14.98';
'@ @'
var VER='14.99';
'@

$pat = "(?m)^  now:'v14\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.99: THE DATA CORE PRICE ON THE MAINFRAME IS THE PRICE IT SELLS FOR. The Mainframe said 520 on the shelf at every loot value setting, while the stash hover and Sell one pay the scaled value, 702 on Rich. With a core in the stash the line now names the real price; the line with none is his baked wording and is untouched. Check 14.99 reads the line on Rich with a core; it fails on v14.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
