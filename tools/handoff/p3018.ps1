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

# Party backdrop: a lighter blur and scrim (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ min-width:calc(var(--sp-5) * 15 * var(--attz,1)); }
'@ @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ min-width:calc(var(--sp-5) * 15 * var(--attz,1)); }
/* v30.xx (cw-partyglow), the critic on v30.14 (46 52 55 56 64): "the blur is so heavy and dark the world is unreadable mush; bake it at about 55 percent brightness with a lighter 6 to 8px blur". An 8px blur (still smears every label and the HUD text into colour) and a scrim that lets about half of the world through in the middle and a fifth at the edges. */
body #attract{ -webkit-backdrop-filter:blur(var(--sp-1)); backdrop-filter:blur(var(--sp-1)); background:radial-gradient(ellipse at 50% 42%, color-mix(in srgb, var(--ui-raised) 18%, transparent) 0%, color-mix(in srgb, var(--ui-bg) 62%, transparent) 50%, color-mix(in srgb, var(--ui-void) 84%, transparent) 100%); }
'@

SubRx @'
var VER='30.17';
'@ @'
var VER='30.18';
'@

$pat = "(?m)^  now:'v30\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.18: The party pages show a clearer, brighter backdrop. Check 30.18 fails on v30.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
