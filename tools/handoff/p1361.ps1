$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# UNDERCROFT AUDIT OF 2026-09-14, finding 4 (low impact): A RESTORE CODE KEPT THE OLD SAVE'S
# PACKING, BELT KEYS AND ARMED DATA CORE. restoreApply replaces the stash, credits and guns,
# and the panel promises it replaces the save he is playing, but it never wrote the loadout,
# the belt, the saved packings or the armed core. The restored character came back with the
# old belt keys on any matching items, the old packing re-selected and intel armed from a
# core this save never spent. It now clears all five with the rest of the save.
SubRx @'
  P.stash=st;
'@ @'
  P.stash=st;
  // v13.61, Undercroft audit: the rest of what belonged to the save being replaced. The
  // loadout, the belt, the saved packings and an armed core all went with the old stash.
  P.kit=[]; P.hotAssign={}; P.kitSaved=null; P.kitBeforeFree=null; P.intel=0;
'@
SubRx @'
var VER='13.60';
'@ @'
var VER='13.61';
'@

$pat = "(?m)^  now:'v13\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.61: A RESTORE CODE REPLACES THE WHOLE SAVE. Undercroft audit of 2026-09-14, finding 4: restoreApply replaced the stash, credits and guns but never the loadout, the belt, the saved packings or an armed Data Core, so the restored character kept the old belt keys, the old packing and intel armed from a core this save never spent. It now clears all five with the rest of the save. Check 13.61 arms a core, packs and binds an item, restores a code, and requires all five cleared, with the stash replaced as the control; it fails on v13.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
