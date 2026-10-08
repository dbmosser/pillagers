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

# STACK COUNTS SIT IN A PILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .cell .cnt{ position:absolute; right:3px; bottom:1px; font-size:13px; font-weight:700;
    color:var(--bone); text-shadow:0 1px 2px #000; pointer-events:none; }
'@ @'
  .cell .cnt{ position:absolute; right:3px; bottom:1px; font-size:13px; font-weight:700;
    color:var(--bone); text-shadow:0 1px 2px #000; pointer-events:none; }
  /* v20.17, seen on the 4K stash screenshots (2026-10-08): the stack count was a bare digit tucked into the tile's rounded corner,
     where the slot badge was until v19.96. It sits in a small dark pill now, set in from the corner, readable on any picture. */
  .cell .cnt{ right:6px; bottom:5px; padding:0 6px; border-radius:7px; background:rgba(8,12,24,.72); line-height:1.35; text-shadow:none; }
'@

SubRx @'
var VER='20.16';
'@ @'
var VER='20.17';
'@

$pat = "(?m)^  now:'v20\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.17: The stack counts on stash tiles are easier to read. Check 20.17 fails on v20.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
