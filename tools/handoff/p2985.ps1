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

# End cards: equal stat cells, plain chips, a Haul label line (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocach.ocok{ border-left-color:var(--ok); }
'@ @'
  #root .ocach.ocok{ border-left-color:var(--ok); }
  /* v28.xx (cw-endcard-polish), the critic on the Extracted and Killed cards (3 of 5): "the stat cells are unequal widths driven by label length", "three amber accents on a screen whose amber marks the one primary", "Haul has the same size and weight as the number", "How did that run feel is 13px bold grey". Four equal 140px cells (560px) with no dividers, a 1px chip border with no amber bar, a 20px Haul label over the 56px figure, and the feedback link in 18px body type. */
  #root .ocstat{ width:560px; max-width:100%; }
  #root .ocstat > div{ flex:1 1 0; min-width:0; border-left:0; padding:16px 8px; }
  #root .ocach, #root .ocach.ocok{ border:1px solid var(--ui-line-hi); }
  #root .haultot .htl{ display:block; margin-bottom:4px; font-size:20px; font-weight:600; letter-spacing:.04em; line-height:1.2; color:var(--tx-2); }
  #root .ocwin .fbhead{ font-family:inherit; font-weight:600; font-size:18px; letter-spacing:.02em; text-transform:none; }
'@

SubRx @'
  el.textContent=(el.hasAttribute('data-pre')?el.getAttribute('data-pre'):'HAUL  ')+'$'+Math.round(R.sum).toLocaleString();
'@ @'
  // v28.xx (cw-endcard-polish): "Haul has the same size and weight as the number": the label is its own 20px line over the figure; the text is the same.
  el.innerHTML='<span class="htl">'+(el.hasAttribute('data-pre')?el.getAttribute('data-pre'):'HAUL  ')+'</span>\x24'+Math.round(R.sum).toLocaleString();
'@

SubRx @'
var VER='29.84';
'@ @'
var VER='29.85';
'@

$pat = "(?m)^  now:'v29\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.85: End cards: tidier stat row and chips, the Haul label above the figure. Check 29.85 fails on v29.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
