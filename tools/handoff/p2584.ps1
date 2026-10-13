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

# SETTINGS IN THE DEMO PAUSE BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(_psb) _psb.style.display=_arcP?'none':'';
'@ @'
    // v25.xx (demosettings), HIS ORDER (2026-10-13): "settings should be accessible in demo mode". The DEMO pause box hid SETTINGS (arcade16),
    // so a guest or the owner could not turn the sound, the text size or a game option in a DEMO run. It is shown now and opens the same
    // Settings screen a CAREER raid does (the restore, the backup file and the tuning console are greyed out in any raid, as always).
    // A change applies at once in the DEMO and stays for the session; arcadeSandboxOut puts every dial and his profile back when the
    // demo is left (arcfixb), so nothing reaches his career. CLOSE and ESC return to this box.
    if(_psb) _psb.style.display='';
'@

SubRx @'
var VER='25.83';
'@ @'
var VER='25.84';
'@

$pat = "(?m)^  now:'v25\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.84: The demo pause box now has Settings, the same screen as in a career raid. Check 25.84 fails on v25.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
