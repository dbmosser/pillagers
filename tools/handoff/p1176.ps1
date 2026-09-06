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

# HIS ORDER, 2026-09-06: "scav pistol should be cheaper in the shop". It stood
# at 3600 credits against a starting purse of 900, so the cheapest gun on the
# shelf was four raids of saving for the weakest thing there, and every player
# already owns one. 1800 is my number, not his: half of what it was, one good
# haul rather than four, and still six percent of the Compact SMG beside it so
# the ladder is unchanged. HE SET THE NO-BALANCING-BEFORE-ALPHA RULE AND HE HAS
# OVERRULED IT HERE; this is the only dial that moves in this build.
SubRx @'
  {k:'pistol',kind:'wep',price:3600,rep:0},{k:'smg',kind:'wep',price:13200,rep:0}
'@ @'
  // v11.76, HIS ORDER: cheaper. Was 3600 against a 900 credit start.
  {k:'pistol',kind:'wep',price:1800,rep:0},{k:'smg',kind:'wep',price:13200,rep:0}
'@

# STAMPS.
SubRx @'
var VER='11.75';
'@ @'
var VER='11.76';
'@
SubRx @'
var WHATSNEW_VER='11.75';
'@ @'
var WHATSNEW_VER='11.76';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE SCAV PISTOL IS HALF PRICE IN THE SHOP: 1800 credits, down from 3600. Say the number you want and it moves again.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.75:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.75 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.75:[^']*'",{ param($m) "now:'v11.76: HIS ORDER of 2026-09-06, the Scav Pistol should be cheaper in the shop. It was 3600 credits against a 900 credit start, four raids of saving for the weakest gun on the shelf, and every player already owns one. Now 1800, which is my number and not his: half, one good haul rather than four, and still well under the Compact SMG at 13200 so the ladder is unchanged. He set the no-balancing rule and has overruled it here; this build moves that one dial and nothing else. Check 11.76 reads the shop row and requires the new price and that it is below the SMG.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
