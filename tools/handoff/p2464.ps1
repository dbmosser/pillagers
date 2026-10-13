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

# THE STASH KEEPS THE TEXT FLOOR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1d (his #50, from the AAA judge and the lint of the stash shot): THE STASH KEEPS THE 13 PIXEL FLOOR. The
     stash is drawn at 0.92 of the window size (his v9.67 note: text in the Undercroft only slightly smaller), and its smallest labels
     were set at the 13px floor, so 28 of them painted at 11.9px: the tabs, SORT, STASH and LOADOUT, the counts, the key bar, the hint
     lines, the brand and the version. Those smallest labels are set at 14.2px now, which the 0.92 brings to the 13px floor; every
     larger word keeps his slight reduction. The tabs are 16px, so the stash filters read at a glance. No word changed. */
  #root #hub .brand, #root #hub #verlabel, #root #hub #reptop, #root #hub #stashsort, #root #hub .lohead, #root #hub #invcols em,
  #root #hub #kitcol em, #root #hub #kitcol b, #root #hub .cell .cnt, #root #hub .loslab, #root #hub #invkeybar kbd, #root #hub #invkeybar div,
  #root #hub #stashdetail span, #root #hub #sellhint, #root #hub #firstkit, #root #hub #sellall, #root #hub #stashsearch,
  #root #hub #hotplanwrap span, #root #hubfreekit b, #root #hubfreekit span, #root #hub [style*="font-size:13px"]{ font-size:14.2px !important; }
  #root #hub #stashtabs .invtab{ font-size:16px !important; }
'@

SubRx @'
var VER='24.63';
'@ @'
var VER='24.64';
'@

$pat = "(?m)^  now:'v24\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.64: No label on the stash paints under 13 pixels, and the stash tabs are bigger. Check 24.64 fails on v24.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
