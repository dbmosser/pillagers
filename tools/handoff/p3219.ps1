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

# Racks column centred in the card (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #mfarrayhint, #root #mfslothint{ display:none !important; }
'@ @'
#root #mfarrayhint, #root #mfslothint{ display:none !important; }
/* v28.xx (cw-uc-rackscentre) b-31 step 7, critic on 14 (P1 "the 670px column sits left of centre in a 1720px card"): the racks pane takes the full card width so the 672px column is centred under the tabs. Looks only. */
#root #opane_mf{ width:100% !important; max-width:none !important; box-sizing:border-box; }
'@

SubRx @'
var VER='32.18';
'@ @'
var VER='32.19';
'@

$pat = "(?m)^  now:'v32\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.19: The racks column sits in the middle of the card. Check 32.19 fails on v32.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
