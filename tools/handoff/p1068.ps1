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

# ============ HIS NOTE, 2026-09-03 about 21:25, the OTHER HALF of it:
# ============ "when i find a gun it should go to the next open slot, not kick
# ============ my scav pistol out of slot 1"
# ============
# ============ v10.62 shipped this for the gun you EQUIP out of your backpack.
# ============ It never touched the path he actually described, which is finding
# ============ one, because a better gun never reaches the backpack: the pickup
# ============ equips it on the spot.
# ============
# ============ REPRODUCED on v10.67 on the real play path, holding E through the
# ============ game's own frame loop at seed 4242 on COLD STORAGE. Scav Pistol in
# ============ hand, Bare Hands in the second slot, the nearest container holding
# ============ a Compact SMG. After the search: Compact SMG in his hand, BARE
# ============ HANDS STILL IN THE SECOND SLOT, and gun_pistol thrown in the bag.
# ============ His exact complaint, and the slot that should have taken it was
# ============ standing empty the whole time.
# ============
# ============ The found gun takes the empty slot and his hands are left alone.
# ============ Bare Hands is what an empty slot holds, which is the same test
# ============ v10.62 uses. WITH BOTH SLOTS FULL NOTHING CHANGES: the gun in hand
# ============ is still the one replaced, exactly as today. His 2026-08-24 note
# ============ says a found gun should not equip itself at all, which would be a
# ============ third behaviour, and that is a design call and his to make.
SubRx @'
      if(autoEquipOn()&&(tierUp||condUp)){
'@ @'
      // v10.68, HIS NOTE of 2026-09-03: "when i find a gun it should go to the
      // next open slot, not kick my scav pistol out of slot 1". v10.62 did this
      // for a gun equipped out of the backpack and could not reach this path,
      // because a better gun never gets as far as the backpack. Bare Hands is
      // what an empty gun slot holds, the same test v10.62 uses. Both slots full
      // is unchanged: the gun in hand is the one replaced, and whether a found
      // gun should equip itself at all is his call, not mine.
      var _secFree=(!p.sec||p.sec.id==='fists'||p.sec.mag===0);
      if(autoEquipOn()&&(tierUp||condUp)&&_secFree){
        p.sec=found; p.secAmmo=Math.ceil(found.mag/2); p.secIssued=false; p.secFromArmory=false;
        T.gunsEquipped=(T.gunsEquipped||0)+1;
        var _qs=(found.qRank===undefined?1:found.qRank);
        if(_qs>(T.bestQ===undefined?-1:T.bestQ)) T.bestQ=_qs;
        // The gun in his hands has not moved and neither has the armoury, so
        // there is nothing to bag and nothing to splice. G.tel.weapon names what
        // he is HOLDING and that is unchanged, so it is left alone too.
        if(!G.sim){
          say(found.name+' to your empty slot. '+p.wep.name+' stays in hand, X swaps.');
          if(found.qRank>=2) blip('pickGun');
        }
      }
      else if(autoEquipOn()&&(tierUp||condUp)){
'@

SubRx @'
var VER='10.67';
'@ @'
var VER='10.68';
'@
SubRx @'
  now:'v10.67: the two guns in the welcome pack go into your hands, not just into your armoury. A new character used to be given a green gun and a blue one and then handed something else entirely on his first raid.',
'@ @'
  now:'v10.68: a gun you find in a raid goes into your empty second slot instead of shoving the gun out of your hands. With both slots full nothing changes: the gun you are holding is still the one it replaces.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
