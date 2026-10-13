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

# ONE TILE SIZE ON EVERY RACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI REDESIGN ui5q2l (his #50, from the AAA judge of the Fashion shot): ONE TILE SIZE ON EVERY RACK. The rack tiles were
     132px columns, so eight outfits left the right 30 percent of the rack empty, a long requirement (PUT 3 WARDENS DOWN (0 OF 3))
     broke into three lines, and the tiles were 145px high on OUTFIT, 128 on BUILD and 95 on SKIN, so the racks jumped in height.
     The columns are at least 184px now, so eight share the whole rack width and a requirement fits in two even lines at most, and every
     tile on every rack is the same 156px high, its name under the picture and its requirement at its foot. */
  #root #appavatarpicker > div:has(> .costile){ grid-template-columns:repeat(auto-fill,minmax(184px,1fr)); }
  #root #appavatarpicker .costile{ min-height:156px; box-sizing:border-box; }
  #root #appavatarpicker .costile .cosreq{ text-wrap:balance; }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
var VER='25.16';
'@ @'
var VER='25.17';
'@

$pat = "(?m)^  now:'v25\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.17: Fashion rack tiles are one size on every rack and fill the rack width. Check 25.17 fails on v25.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
