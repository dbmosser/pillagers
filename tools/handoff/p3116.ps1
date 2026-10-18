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

# THE SHOP FILLS ITS CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #tradermodal .vend, #root #opmodal .vend{ max-width:none; width:100%; }
'@ @'
  #root #tradermodal .vend, #root #opmodal .vend{ max-width:none; width:100%; }
  /* v28.xx (cw-shopfill), his Q43 (2026-10-18, a card that takes nearly the whole screen) and the critic on the shop shot (2/5: "body stops at y740 leaving 280px of void"): the shop grid and detail now stretch to the bottom of the card, the buy button stays pinned at the foot of the detail, the subtitle line goes (it only repeated the tab), and the answer line sits inside the card instead of across its bottom border. */
  #root #tradermodal .tpane > .vend{ flex:1 1 0; max-height:none; }
  #root #tradermodal #tpane_buy .msub{ display:none; }
  body:has(#tradermodal.on) #hubtoast{ bottom:calc(5vh + 14px); }
'@

SubRx @'
var VER='31.15';
'@ @'
var VER='31.16';
'@

$pat = "(?m)^  now:'v31\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.16: The shop, craft and hire body fills the card. Check 31.16 fails on v31.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
