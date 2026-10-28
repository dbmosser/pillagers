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

# PAGE WALLET STAYS HIDDEN IN THE NEW HUD FRAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  TRG.t=(typeof performance!=='undefined')?performance.now():Date.now();   // v35.xx (cw-quiethud): stamped with no rows too, so the page copy of the wallet stays clipped away in a raid
'@ @'
  TRG.t=(typeof performance!=='undefined')?performance.now():Date.now();   // v35.xx (cw-quiethud): stamped with no rows too, so the page copy of the wallet stays clipped away in a raid
  trHide();   // v28.xx (cw-cx-walletframe), HIS NOTE (2026-10-25): "Text collisions on the menu thing". Hide the page wallet in the frame that draws the corner, including the quiet hud with no rows: the loop hide check runs before drawing and can see an old stamp after a long frame.
'@

SubRx @'
var VER='35.45';
'@ @'
var VER='35.46';
'@

$pat = "(?m)^  now:'v35\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.46: The old corner money text stays hidden as soon as the raid HUD draws. Check 35.46 fails on v35.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
