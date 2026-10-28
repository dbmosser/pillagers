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

# PAUSE SP GOLD TOKEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    --r-common:#9da3a8; --r-uncommon:#5fbf6a; --r-rare:#3f9de9; --r-elite:#a866e0; --r-gold:#ffc72e;
'@ @'
    --r-common:#9da3a8; --r-uncommon:#5fbf6a; --r-rare:#3f9de9; --r-elite:#a866e0; --r-gold:#ffc72e;
    --score-gold:#ffc04a; --seat-one:#ffb454; --seat-two:#53d9e8; /* v28.xx (cw-cx-pausesp-gold): preserve the pause sp and run-over seat colours as root tokens. */
'@

SubRx @'
#root #pausebox #pausesp .psph b{ font:700 var(--fs-title)/1 var(--f-cond); color:#ffc04a; font-variant-numeric:tabular-nums; }
'@ @'
#root #pausebox #pausesp .psph b{ font:700 var(--fs-title)/1 var(--f-cond); color:var(--score-gold); font-variant-numeric:tabular-nums; }
'@

SubRx @'
#root #pausebox #pausesp .psprow b, #root #pausebox #pausesp .psprule b{ text-align:right; color:#ffc04a; font-variant-numeric:tabular-nums; }
'@ @'
#root #pausebox #pausesp .psprow b, #root #pausebox #pausesp .psprule b{ text-align:right; color:var(--score-gold); font-variant-numeric:tabular-nums; }
'@

SubRx @'
html body #attract[style*="block"]:has(.arcover[style*="block"]){background:rgba(6,7,8,.80);-webkit-backdrop-filter:blur(6px);backdrop-filter:blur(6px);}
'@ @'
html body #attract[style*="block"]:has(.arcover[style*="block"]){background:var(--scrim);-webkit-backdrop-filter:blur(6px);backdrop-filter:blur(6px);}
'@

SubRx @'
html body #attract .arcover .aosn[data-seat="1"], html body #attract .arcover .aowho[data-seat="p1"]{color:#ffb454;}
'@ @'
html body #attract .arcover .aosn[data-seat="1"], html body #attract .arcover .aowho[data-seat="p1"]{color:var(--seat-one);}
'@

SubRx @'
html body #attract .arcover .aosn[data-seat="2"], html body #attract .arcover .aowho[data-seat="p2"]{color:#53d9e8;}
'@ @'
html body #attract .arcover .aosn[data-seat="2"], html body #attract .arcover .aowho[data-seat="p2"]{color:var(--seat-two);}
'@

SubRx @'
var VER='36.03';
'@ @'
var VER='36.04';
'@

$pat = "(?m)^  now:'v36\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.04: Pause score gold and run-over seat colours use root tokens; the overlay uses the existing identical scrim token. All colours stay the same and the full shared-look check runs again. Check 36.04 fails on v36.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
