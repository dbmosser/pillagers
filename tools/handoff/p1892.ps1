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

# STASH SCREEN: A KEY LEFT ON A RACK GUN MOVES LIKE ANY ITEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _inHand=(_fk>=0&&String(key).indexOf('gun_')===0&&(P.equipped===String(key).slice(4)||P.equippedSec===String(key).slice(4)));
'@ @'
var _inHand=(_fk>=0&&String(key).indexOf('gun_')===0&&(P.equipped===String(key).slice(4)||P.equippedSec===String(key).slice(4)));
        // v18.92, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". A key left on an armoury gun that has since left his hands (Put in gun 1 for another gun, Take it out of your hands and Equip as your gun change the hands and never touch the belt) went through planPut, which counts only the stash, so the move was refused with a clank and words saying the gun was not in the stash. A key on any gun the armoury holds, with none of it in the stash, now goes through rackPut, as a drag of the rack cell does (v11.95): a gun in a hand still binds alone, and any other one moves into the stash, is packed and takes the key, or is refused because the backpack is full.
        if(!_inHand&&_fk>=0&&String(key).indexOf('gun_')===0&&(P.weapons||[]).indexOf(String(key).slice(4))>=0&&heldCount(key)===0) _inHand=true;
'@

SubRx @'
var VER='18.91';
'@ @'
var VER='18.92';
'@

$pat = "(?m)^  now:'v18\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.92: On the Stash screen a key on a racked gun moves to another key like any item. Check 18.92 fails on v18.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
