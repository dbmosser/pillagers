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

# THE X KEY ROW SAYS CALL FOR EXTRACTION, THEN EXTRACT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ['KeyX','call for extraction, then board'],['KeyB','backpack'],['KeyI','backpack'],['Enter','equip from the backpack'],['KeyM','map'],['F1','controls list'],
'@ @'
  // v27.65 (cloud-menus-keys-x-no-board), CLOUD HUNT 2026-10-15: the X row said call for extraction, then board; board is a retired word (his words: ascend, extract), so it says call for extraction, then extract
  ['KeyX','call for extraction, then extract'],['KeyB','backpack'],['KeyI','backpack'],['Enter','equip from the backpack'],['KeyM','map'],['F1','controls list'],
'@

SubRx @'
['WORLD',[['E','search, use, open'],['X','call for extraction, then board'],['M','map'],['F1','cycle this list'],['P','pause'],['TAB','pause, or back out of a menu'],['O','order your hire']]],
'@ @'
  // v27.65 (cloud-menus-keys-x-no-board), CLOUD HUNT 2026-10-15: the controls card X row said call for extraction, then board; board is a retired word, so it says call for extraction, then extract
['WORLD',[['E','search, use, open'],['X','call for extraction, then extract'],['M','map'],['F1','cycle this list'],['P','pause'],['TAB','pause, or back out of a menu'],['O','order your hire']]],
'@

SubRx @'
var VER='27.64';
'@ @'
var VER='27.65';
'@

$pat = "(?m)^  now:'v27\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.65: The Keys window and the controls card say X calls for extraction, then extracts, without the old word board. Check 27.65 fails on v27.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
