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

# DEMO SIEGE GROWS WITH THE HAUL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function greedOf(){ return clamp(bagValue()/CFG.greedFull,0,1); }
'@ @'
// v25.xx (demosiege), HIS RULE (2026-10-12): "GAMEPLAY ELEMENTS ... SHOULD BE EXACTLY THE SAME IN DEMO AND CAREER". The siege that comes with an
// extraction call is sized by how full the backpack is (5 machines at an empty one, up to 12 at a full one). A DEMO valuable never enters the
// backpack (it scores at once, into ARCADE.pot, at its full credit value), so a DEMO caller always had an empty one and every DEMO siege was
// the smallest. The pot stands for the backpack there: the same figure a CAREER backpack of that loot would give, so the siege is the size a
// CAREER caller with that haul gets.
function greedOf(){ return clamp((bagValue()+((G&&G.arcade&&typeof ARCADE==='object'&&ARCADE)?Math.max(0,ARCADE.pot|0):0))/CFG.greedFull,0,1); }
'@

SubRx @'
var VER='25.87';
'@ @'
var VER='25.88';
'@

$pat = "(?m)^  now:'v25\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.88: A demo extraction siege now grows with the loot you took, as in a career raid. Check 25.88 fails on v25.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
