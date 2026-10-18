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

# THE TITLE KEY LINE NAMES F1 FOR THE CONTROLS LIST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      <b style="color:var(--bone)">H</b> controls

'@ @'
      <!-- v28.xx (cw-menu-f1hint), UI step 30 (menu map): the title key line said H opens the controls. Since keyswap (v25.xx) H heals and F1 is the controls list, so a guest who read the title pressed H and healed. It names F1. -->
      <b style="color:var(--bone)">F1</b> controls

'@

SubRx @'
var VER='29.29';
'@ @'
var VER='29.30';
'@

$pat = "(?m)^  now:'v29\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.30: The title key line now says F1 controls, the key that really opens the list (H heals). Check 29.30 fails on v29.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
