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

# THE STASH HELP LINES ARE READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
           min-height:52px;font-size:11px;color:var(--ash)"></div>
'@ @'
           min-height:52px;font-size:13px;color:var(--ash)"></div>
'@

SubRx @'
<div id="sellhint" class="hint" style="margin-top:6px;font-size:11px;line-height:1.35"></div>
'@ @'
<div id="sellhint" class="hint" style="margin-top:6px;font-size:13px;line-height:1.35"></div>
'@

SubRx @'
<div id="nextunlock" class="hint" style="margin-top:4px;font-size:11px;line-height:1.35"></div>
'@ @'
<div id="nextunlock" class="hint" style="margin-top:4px;font-size:13px;line-height:1.35"></div>
'@

SubRx @'
  .fkbox b{ color:var(--amber); letter-spacing:.1em; font-size:11px; }
  .fkbox span{ flex:1; color:var(--ash); font-size:11px; }
'@ @'
  /* v19.78, seen on a 4K menu text scan (2026-10-08): the stash help line, the sell notes and this bar were 11px, the smallest
     print left in any menu once the filter tabs and key row grew (v19.76, v19.77). 13px, with room on every line. */
  .fkbox b{ color:var(--amber); letter-spacing:.1em; font-size:13px; }
  .fkbox span{ flex:1; color:var(--ash); font-size:13px; }
'@

SubRx @'
var VER='19.77';
'@ @'
var VER='19.78';
'@

$pat = "(?m)^  now:'v19\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.78: The help lines and the FREEBIE KIT bar on the stash are easier to read. Check 19.78 fails on v19.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
