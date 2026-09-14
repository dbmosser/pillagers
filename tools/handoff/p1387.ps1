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

# SEARCHING AND LOOT AUDIT OF 2026-09-14, finding 5: A FOUND GUN GOING TO SLOT 2 DELETED A SCAV
# PISTOL HELD THERE. v12.78 lets a find displace the Scav Pistol, Bare Hands or an empty slot.
# The hand branch bags the gun it displaces and keeps its load; the slot 2 branch just
# overwrote p.sec. A field Scav Pistol in slot 2 (taken off a body and put there) was gone when
# a better gun was found: not in the hands, not in the backpack, not banked. Slot 2 now bags
# the gun it displaces exactly as the hand branch does, splicing an armoury copy the same way.
SubRx @'
        // v13.81, combat audit: a gun from a crate you dropped comes back with its own load (v12.42), not half a magazine.
        p.sec=found;
'@ @'
        // v13.87, loot audit: the gun this displaces from slot 2 goes into the backpack with its load,
        // exactly as the hand branch below bags its gun. It used to be overwritten and lost.
        if(p.sec&&p.sec.id!=='fists'&&p.sec.mag!==0&&!p.secIssued&&ITEMS['gun_'+p.sec.id]){
          G.bag.push('gun_'+p.sec.id);
          stowRounds(p.sec.id,p.secAmmo);
          if(!G.sim&&p.secFromArmory){
            var _soi=P.weapons.indexOf(p.sec.id);
            if(_soi>=0){ P.weapons.splice(_soi,1); (G.spliced=G.spliced||[]).push(p.sec.id); }
          }
        }
        // v13.81, combat audit: a gun from a crate you dropped comes back with its own load (v12.42), not half a magazine.
        p.sec=found;
'@
SubRx @'
var VER='13.86';
'@ @'
var VER='13.87';
'@

$pat = "(?m)^  now:'v13\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.87: A FOUND GUN IN SLOT 2 BAGS THE GUN IT REPLACES. Searching and loot audit of 2026-09-14, finding 5: a find may displace a Scav Pistol, Bare Hands or an empty slot (v12.78), and the hand branch bags the gun it displaces, but the slot 2 branch overwrote p.sec, so a field Scav Pistol held in slot 2 vanished when a better gun was found. Slot 2 now bags the displaced gun with its load, splicing an armoury copy as the hand branch does. Check 13.87 holds a field pistol in slot 2, finds an SMG, and requires the pistol in the backpack, with an empty slot 2 taking the SMG as the control; it fails on v13.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
