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

# THE SHOP TABS HOLD STILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .invtab.on{ color:#0d1435; background:var(--amber); border-color:var(--amber); font-weight:700; }
'@ @'
  .invtab.on{ color:#0d1435; background:var(--amber); border-color:var(--amber); font-weight:700; }
  /* v20.91, from the whole-game bug hunt of 2026-10-08 (V-A5): THE TABS IN A WINDOW HOLD STILL. The chosen tab was drawn at 700 and
     the rest at 400, and heavier letters are wider, so every switch between BUY, CRAFT and HIRE (and the Mainframe and Settings tabs)
     slid the tabs sideways by a few pixels. Every tab in a window is 600 now, the weight of the buttons; the chosen one is still the
     gold one. The stash filter row is left as it was. */
  .modal .invtab, .modal .invtab.on{ font-weight:600; }
'@

SubRx @'
var VER='20.90';
'@ @'
var VER='20.91';
'@

$pat = "(?m)^  now:'v20\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.91: The tabs in the shop, the Mainframe and Settings no longer slide sideways when you switch them. Check 20.91 fails on v20.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
