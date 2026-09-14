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

SubRx @'
    if(e.kind==='listener') continue;             // it does not take orders from noise twice
'@ @'
    if(e.kind==='listener') continue;             // it does not take orders from noise twice
    // v14.33, weather audit finding 3: NOISE DOES NOT ALERT THE PEDDLER OR THE STRAY. Their update branches never decay alert,
    // so one shot or bolt within earshot left them alerted for the rest of the raid, and the ambient bed counts any alerted
    // entity as a threat: standing at the stall played the sound of a machine on top of you. Skipped the way the hire and
    // raider target loops skip them since v8.23. No random draw here, so the seeded stream is unchanged.
    if(e.kind==='peddler'||e.kind==='stray'||e.neutral) continue;
'@
SubRx @'
var VER='14.32';
'@ @'
var VER='14.33';
'@

$pat = "(?m)^  now:'v14\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.33: NOISE DOES NOT ALERT THE PEDDLER OR THE STRAY. A noise set every entity in earshot to alerted, and the Peddler and the Stray never let it decay, so after one shot nearby the ambient sound played at full threat at the stall for the rest of the raid. Noise now skips them, as the target loops already do. Check 14.33 makes a noise beside the Peddler, a stray and a crawler; it fails on v14.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
