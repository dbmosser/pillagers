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

# The end card total is the hero (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocwin .haulit[data-r="gold"]{ border-bottom-color:var(--r-gold) !important; }
'@ @'
  #root .ocwin .haulit[data-r="gold"]{ border-bottom-color:var(--r-gold) !important; }
  /* v28.xx (cw-endcard-hero): the critic, second pass on the Extracted and KIA cards (2 of 5): "no hero line, the HUD still bleeds through the scrim,
     the feedback chip is a third competing control with an amber plus". The haul total is the hero now: 56px, bone, no tracking, 16px above and 24px
     below. The scrim is near solid (.94) so the HUD cannot read through. The feedback prompt is a quiet 16px text link in tx-2 with no box and no amber. */
  #root .outcome{ background:rgba(6,7,8,.94); }
  #root .haultot{ font-size:56px; line-height:1.05; letter-spacing:0; color:var(--tx-1); text-transform:none; margin:16px 0 24px; }
  #root .ocwin .fbhead{ background:transparent; border:0; color:var(--tx-2); font-size:16px; padding:8px 16px; margin-top:16px; }
  #root .ocwin .fbhead::after{ color:var(--tx-2); }
'@

SubRx @'
var VER='29.52';
'@ @'
var VER='29.53';
'@

$pat = "(?m)^  now:'v29\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.53: The end card shows the haul big, with a cleaner backdrop. Check 29.53 fails on v29.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
