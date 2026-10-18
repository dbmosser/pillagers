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

# End cards: a 40px title, bigger loss tiles, a clear Abandoned line (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocwin .fbhead{ font-family:inherit; font-weight:600; font-size:18px; letter-spacing:.02em; text-transform:none; }
'@ @'
  #root .ocwin .fbhead{ font-family:inherit; font-weight:600; font-size:18px; letter-spacing:.02em; text-transform:none; }
  /* v28.xx (cw-endcard-clean), the critic on the KIA and Abandoned cards (3 and 2 of 5): "the title is too small to lead, the hero beats it", "two stacked 15px grey lines, the XP line competes with the title", "tiles are small, 8px from the hero", "dividers are low contrast", "the Abandoned card has no focal line". Title 40px with 8px under it; the XP line is quiet tx-2; tiles 72px with a 52px picture and 24px above the figure; the stat row rules in the brighter line; the Abandoned loot line is its own 24px bone line with 24px around it. Words unchanged. */
  #root .outcome h1{ font-size:40px; font-weight:700; margin-bottom:8px; }
  #root #oc_manifest span[style*="var(--amber)"]{ color:var(--tx-2) !important; }
  #root .octile{ width:72px; height:72px; }
  #root .octile img{ width:52px !important; height:52px !important; }
  #root .octiles{ margin:24px 0 8px; }
  #root .ocloss{ margin:24px 0 32px; }
  #root .ocstat{ border-top-color:var(--ui-line-hi); border-bottom-color:var(--ui-line-hi); }
  #root .ocnote{ display:block; margin:24px 0; font-family:var(--f-cond); font-size:24px; font-weight:700; line-height:1.2; color:var(--tx-1); }
'@

SubRx @'
    lines.push('Run abandoned. '+'$'+haul.toLocaleString()+' left behind.');
'@ @'
    lines.push('<span class="ocnote">Run abandoned. '+'$'+haul.toLocaleString()+' left behind.</span>');   // v28.xx (cw-endcard-clean): the same words, its own bone line (critic on screen 60: no focal line)
'@

SubRx @'
var VER='29.94';
'@ @'
var VER='29.95';
'@

$pat = "(?m)^  now:'v29\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.95: End cards: bigger title and loss tiles, a clear loot line on Abandoned. Check 29.95 fails on v29.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
