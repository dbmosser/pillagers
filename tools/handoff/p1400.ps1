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

# DEPLOY AND LOADOUT AUDIT OF 2026-09-15, finding 3: A GUN BOUND TO KEY 1 FROM THE BACKPACK COULD NOT BE PICKED
# UP WITH KEY 1. A number key binds any item to any slot, key 1 included. A gun carried in the backpack and
# bound to slot 0 replaces the first gun cell, and the raid starts with slot 0 selected because the gun in
# hand has no cell of its own. setHot returns at once when the pressed slot is already selected, so pressing 1
# did nothing: cell 1 read Compact SMG, highlighted, while the trigger fired the loaner. Pressing the selected
# key now still equips a gun that is sitting in the backpack.
SubRx @'
function setHot(i){
  var sl=hotbarSlots();
  i=clamp(i,0,sl.length-1);
  if(i===G.hot) return;
'@ @'
function setHot(i){
  var sl=hotbarSlots();
  i=clamp(i,0,sl.length-1);
  // v14.00, loadout audit: the selected key still equips a gun that is in the backpack rather than the hands.
  if(i===G.hot&&!(sl[i]&&sl[i].kind==='gun'&&sl[i].itemKey&&!sl[i].equipped)) return;
'@
SubRx @'
var VER='13.99';
'@ @'
var VER='14.00';
'@

$pat = "(?m)^  now:'v13\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.00: KEY 1 PICKS UP THE GUN BOUND TO IT. Deploy and loadout audit of 2026-09-15, finding 3: a gun carried in the backpack and bound to key 1 replaces the first gun cell, the raid starts with that slot selected because the gun in hand has no cell, and setHot returned at once for an already selected slot, so pressing 1 did nothing while the cell read the bound gun and the trigger fired the loaner. Pressing the selected key now still equips a gun waiting in the backpack. Check 14.00 goes up with an SMG bound to key 1 and requires pressing 1 to put it in a hand, with the SMG bound to key 2 and 2 pressed as the control; it fails on v13.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
