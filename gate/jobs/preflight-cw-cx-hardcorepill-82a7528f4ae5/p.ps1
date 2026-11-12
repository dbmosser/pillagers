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

# HARDCORE TITLE SWITCH USES THE SHARED PILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #title #slotpanel button, #root #title #pnamein{ min-height:var(--btn-h-xs); border-radius:var(--rad) !important; font:600 var(--fs-label)/1 var(--f-cond) !important; }
'@ @'
/* v28.xx (cw-cx-hardcorepill): title action buttons leave shared toggles their pill size, radius and centred knob. */
#root #title #slotpanel button:not(.ui-toggle), #root #title #pnamein{ min-height:var(--btn-h-xs); border-radius:var(--rad) !important; font:600 var(--fs-label)/1 var(--f-cond) !important; }
'@

SubRx @'
var VER='37.69';
'@ @'
var VER='37.70';
'@

$pat = "(?m)^  now:'v37\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.70: The hardcore switch keeps the shared pill shape and sliding knob on the title. Check 37.70 fails on v37.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
