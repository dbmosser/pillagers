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

# THE STASH SLOT BADGE IS A CLEAR PILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
(inSlot?('<span class="cnt" style="background:var(--amber);color:#0d1435">'+inSlot+'</span>'):'');
'@ @'
(inSlot?('<span class="cnt" style="background:var(--amber);color:#0d1435;padding:1px 7px;border-radius:7px;right:7px;bottom:6px;text-shadow:none">'+inSlot+'</span>'):'');   // v19.96, seen on the 4K stash screenshot (2026-10-08): the slot number was a bare amber sliver jammed into the rounded corner
'@

SubRx @'
var VER='19.95';
'@ @'
var VER='19.96';
'@

$pat = "(?m)^  now:'v19\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.96: The 1 and 2 on equipped guns in the stash are easy to read. Check 19.96 fails on v19.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
