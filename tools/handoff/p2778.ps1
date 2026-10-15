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

# UI VOLUME SILENCES THE FIND SOUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ g=a.createGain(); g.gain.value=B.gain.value; o=netSndOut(a)||a.destination; g.connect(o); }catch(e){ return null; }
'@ @'
  // v27.78 (cloud-menus-ui-volume-finds), CLOUD HUNT 2026-10-15: a find sound is a pickup, so UI VOLUME scales it too; it skips the UI bus, so OFF never silenced it
  try{ g=a.createGain(); g.gain.value=B.gain.value*volOf('volUi'); o=netSndOut(a)||a.destination; g.connect(o); }catch(e){ return null; }
'@

SubRx @'
var VER='27.77';
'@ @'
var VER='27.78';
'@

$pat = "(?m)^  now:'v27\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.78: UI VOLUME now turns down the pickup sounds for rare finds and guns too. Check 27.78 fails on v27.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
