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

# PAUSE BOX END RUN GAP, FOCUS BAR, DIVIDER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox #pausefb{ height:var(--btn-h); padding-top:calc((var(--btn-h) - 28px) / 2); }
'@ @'
#root #pausebox #pausefb{ height:var(--btn-h); padding-top:calc((var(--btn-h) - 28px) / 2); }
/* v28.xx (cw-pausegap) critic on Pause box 49 (3, P1/P2): "end run floats about 70px below the stack", "focus on any other row is not shown", "the header divider is very faint". Now end run sits one 16px gap under the stack (no extra margin), idle buttons show a 3px lime bar and raised fill on focus (pad and keys), and the divider takes the brighter line colour. */
#root #pausebox:not(.asking) > div:has(> #resumebtn) > #abandonbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #arcendbtn, #root #pausebox:not(.asking) > div:has(> #resumebtn) > #charselbtn{ margin-top:0; }
#root #pausebox > div:has(> #resumebtn) > button:not(#resumebtn):focus-visible{ box-shadow:inset 3px 0 0 var(--acc); background:var(--ui-raised); }
#root #pausebox > h3{ border-bottom-color:var(--ui-line-hi); }
'@

SubRx @'
var VER='32.65';
'@ @'
var VER='32.66';
'@

$pat = "(?m)^  now:'v32\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.66: End run sits one gap under the stack, buttons show a lime focus bar, divider is brighter. Check 32.66 fails on v32.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
