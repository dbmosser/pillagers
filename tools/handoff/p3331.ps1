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

# NO CARD WHEN YOU LOOT A GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(!G.sim&&!(G.arcade&&(/^SCRAPPED/).test(String(_ptags[l]||'')))) G.gunCard={gk:itm.gk,w:found,vs:_gcVs,route:String(_ptags[l]||'BACKPACK'),t0:G.t||0};
'@ @'
// v33.xx (cw-nolootguncard), HIS ORDER (2026-10-20): "get rid of weapon card popups when weapons are looted -- they are invasive and not helpful". Looting a gun raises no card now; the pickup row still says where it went. The card stays in the backpack, on the belt hover and in the forge.
'@

SubRx @'
var VER='33.30';
'@ @'
var VER='33.31';
'@

$pat = "(?m)^  now:'v33\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.31: Picking up a gun shows no stat card. Check a gun by opening the backpack or hovering its slot. Check 33.31 fails on v33.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
