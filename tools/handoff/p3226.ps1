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

# PAUSE BOX BUTTONS ALL 56PX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox:not(.asking) > div:has(> #resumebtn) > #abandonbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #arcendbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #charselbtn{ min-height:var(--btn-h-sm); margin-top:var(--sp-3); }
'@ @'
#root #pausebox:not(.asking) > div:has(> #resumebtn) > #abandonbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #arcendbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #charselbtn{ min-height:var(--btn-h-sm); margin-top:var(--sp-3); }
/* v28.xx (cw-pause56) critic on Pause box 25 (3, P1): "heights are 56, 56, 48 and 48, the 4 sizes make the column ragged" and "button text about 14px". Now every pause button is one 56px height with the 20px body label; feedback and what is new stay side by side (Q61 keeps them). */
#root #pausebox > div:has(> #resumebtn) > #fbbtn, #root #pausebox > div:has(> #resumebtn) > #wnbtn{ min-height:var(--btn-h); font-size:var(--fs-body); }
#root #pausebox:not(.asking) > div:has(> #resumebtn) > #abandonbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #arcendbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #charselbtn{ min-height:var(--btn-h); font-size:var(--fs-body); }
'@

SubRx @'
var VER='32.25';
'@ @'
var VER='32.26';
'@

$pat = "(?m)^  now:'v32\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.26: Every pause box button is one 56px height. Check 32.26 fails on v32.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
