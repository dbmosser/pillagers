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

# PAUSE BOX REPORT FIELD IS A SMALL ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#charselbtn{ min-height:var(--btn-h-sm); margin-top:var(--sp-3); }
'@ @'
#charselbtn{ min-height:var(--btn-h-sm); margin-top:var(--sp-3); }
/* v28.xx (cw-pausefb2) critic on Pause box 25 (3 after cw-pausebtn): "settings, report a problem, feedback and what is new look identical, so the order of importance is flat", "the title is about 28px against 32px", "the divider is a fairly bright line". Now: the report a problem field drops to the 48px small tier on a clear fill with the quiet line border (it is a field, not a main row; Q61 keeps it), the title is 32px and the header divider takes the quiet line colour. */
#root #pausebox #pausefb{ height:var(--btn-h-sm); padding-top:calc((var(--btn-h-sm) - 28px) / 2); padding-bottom:0; background:transparent; border-color:var(--ui-line); }
#root #pausebox > h3{ font-size:var(--fs-title); border-bottom-color:var(--ui-line); }
'@

SubRx @'
var VER='32.09';
'@ @'
var VER='32.10';
'@

$pat = "(?m)^  now:'v32\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.10: The pause box report field is smaller and the title is bigger. Check 32.10 fails on v32.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
