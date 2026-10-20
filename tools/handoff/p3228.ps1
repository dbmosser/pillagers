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

# PAUSE REPORT BOX 56PX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox #pausefb{ height:var(--btn-h-sm); padding-top:calc((var(--btn-h-sm) - 28px) / 2); padding-bottom:0; background:transparent; border-color:var(--ui-line); }
'@ @'
#root #pausebox #pausefb{ height:var(--btn-h-sm); padding-top:calc((var(--btn-h-sm) - 28px) / 2); padding-bottom:0; background:transparent; border-color:var(--ui-line); }
/* v28.xx (cw-pausefb56) critic on Pause box 25 (3, P1): "report a problem is about 48px while the rest are 56px, the stack rhythm is broken". Now the report box is 56px like every other pause button. */
#root #pausebox #pausefb{ height:var(--btn-h); padding-top:calc((var(--btn-h) - 28px) / 2); }
'@

SubRx @'
var VER='32.27';
'@ @'
var VER='32.28';
'@

$pat = "(?m)^  now:'v32\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.28: The pause report box is 56px high. Check 32.28 fails on v32.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
