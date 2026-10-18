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

# Party backdrop: the 16px blur is back (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract{ -webkit-backdrop-filter:blur(var(--sp-1)); backdrop-filter:blur(var(--sp-1)); background:radial-gradient(ellipse at 50% 42%, color-mix(in srgb, var(--ui-raised) 18%, transparent) 0%, color-mix(in srgb, var(--ui-bg) 62%, transparent) 50%, color-mix(in srgb, var(--ui-void) 84%, transparent) 100%); }
'@ @'
body #attract{ -webkit-backdrop-filter:blur(var(--sp-2)); backdrop-filter:blur(var(--sp-2)); background:radial-gradient(ellipse at 50% 42%, color-mix(in srgb, var(--ui-raised) 30%, transparent) 0%, color-mix(in srgb, var(--ui-bg) 76%, transparent) 50%, color-mix(in srgb, var(--ui-void) 90%, transparent) 100%); }   /* v30.xx (cw-partyglow2): 16px again, the 8px blur showed the hub labels (critic 56 = 2) */
'@

SubRx @'
var VER='30.19';
'@ @'
var VER='30.20';
'@

$pat = "(?m)^  now:'v30\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.20: The party pages have a soft backdrop with no ghost words. Check 30.20 fails on v30.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
