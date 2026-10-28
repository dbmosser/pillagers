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

# THE STASH HOVER KEEPS EVERY BOX THE SAME SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #hub #stashdetail:empty,#root #hub #nextunlock:empty{display:none!important;}
'@ @'
#root #hub #nextunlock:empty{display:none!important;}
/* v35.xx (cw-stashhover), HIS ORDER (2026-10-27): "mousing over different items in the stash is a complete clusterfuck because it changes the size of one of the sub menus". The item line under the grids (#stashdetail) was empty and hidden until a hover, then as tall as the item had rows (a gun six, a medkit one), so every mouse move across the stash re-flowed the grids above it: the backpack grid, the hotbar and the gun keys jumped. It is one box of one size now, hover or no hover: 160px, always shown, the stat rows in three columns so the longest real gun (upgrade, element, damage, rate, magazine, range, accuracy, noise, kills) fits, anything longer scrolls inside the box. */
#root #hub #stashdetail{display:block!important;box-sizing:border-box;height:160px!important;min-height:160px!important;max-height:160px!important;overflow-x:hidden;overflow-y:auto;}
#root #hub #stashdetail>div{display:grid;grid-template-rows:repeat(3,auto);grid-auto-flow:column;grid-auto-columns:minmax(0,1fr);column-gap:24px;}
#root #hub #stashdetail>div>div{line-height:1.3!important;}
'@

SubRx @'
var VER='35.41';
'@ @'
var VER='35.42';
'@

$pat = "(?m)^  now:'v35\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.42: the item line under the stash grids is one fixed size box, hover or not: the backpack, hotbar, gun keys and stash grid no longer move when the mouse crosses items Check 35.42 fails on v35.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
