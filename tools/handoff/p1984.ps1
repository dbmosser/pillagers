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

# MENU PARAGRAPHS NEVER END ON ONE WORD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  html,body { margin:0; padding:0; overflow:hidden; }
'@ @'
  html,body { margin:0; padding:0; overflow:hidden; }
  /* v19.84, from the 4K menu screenshots (2026-10-08): menu paragraphs could end on one lonely word (equal to the / price.).
     The browser now evens out the last lines of every menu paragraph so none ends on a single word. Only line breaks move. */
  body{ text-wrap:pretty; }
'@

SubRx @'
var VER='19.83';
'@ @'
var VER='19.84';
'@

$pat = "(?m)^  now:'v19\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.84: Menu text no longer leaves a single word alone on its last line. Check 19.84 fails on v19.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
