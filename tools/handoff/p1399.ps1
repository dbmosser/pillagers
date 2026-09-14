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

# DEPLOY AND LOADOUT AUDIT OF 2026-09-15, finding 1: AFTER AN EXTRACTION A BELT KEY STILL POINTED AT AN ITEM
# THAT DID NOT COME UP, AND IT HID THE MEDICAL CELL. Committing a loadout empties the kit but keeps the
# belt plan, and a key whose item sits in the stash is kept, so a Medkit bound to key 8 on one raid stayed
# bound when the next went up with only Bandages. The raid copies the whole plan, a bound item with none
# carried still counts as bound, and the dedupe then blanks the derived Medical cell: key 8 said No Medkit
# left and the Bandages had no belt key at all. The raid's copy of the plan now lets go of any item that did
# not come up in the backpack or the pouch. Guns are left alone (they are in the hands, not the bag), and
# the Undercroft plan he set is not touched.
SubRx @'
    while(carried<ISSUED_HEALS){ g.bag.push('bandage'); carried++; g.issuedBandages++; }
  }
'@ @'
    while(carried<ISSUED_HEALS){ g.bag.push('bandage'); carried++; g.issuedBandages++; }
    // v13.99, loadout audit: a key does not point at something that did not come up. The raid's copy of the
    // belt plan lets go of items carried neither in the backpack nor the pouch, so the derived cells they
    // would have blanked stay. His Undercroft plan is left as he set it.
    if(g.hotAssign) for(var _ha in g.hotAssign){
      var _hk=g.hotAssign[_ha], _hi=ITEMS[_hk];
      if(!_hi||_hi.use==='gun') continue;
      if(g.bag.indexOf(_hk)<0&&!((g.pouch||{})[_hk]>0)) delete g.hotAssign[_ha];
    }
  }
'@
SubRx @'
var VER='13.98';
'@ @'
var VER='13.99';
'@

$pat = "(?m)^  now:'v13\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.99: A BELT KEY DOES NOT POINT AT SOMETHING THAT STAYED BEHIND. Deploy and loadout audit of 2026-09-15, finding 1: committing a loadout keeps the belt plan, so a Medkit bound to a key on one raid stayed bound when the next went up without one, and in the raid the bound key said No Medkit left while the dedupe blanked the derived Medical cell, leaving the Bandages with no key. The raid copy of the plan now drops items carried neither in the backpack nor the pouch; guns and his Undercroft plan are untouched. Check 13.99 goes up with two Bandages and a Medkit still bound, requiring the binding dropped and a Medical cell holding the Bandages, with a bound Bandage kept as the control; it fails on v13.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
