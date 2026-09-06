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

# FROM THE 2026-09-06 READ-ONLY REVIEW OF v11.79 (guns on the bench). The
# Burst Carbine is BLUE everywhere the player looks (gunRarity by tier; the
# price row's r is the one field v7.99 said is not a gun's rarity), so the
# bench holds one green gun and three blue, and the card said two of each.
# The bench's cream detail panel described a crafted gun as salvage to sell
# and read its rarity from the price row. The stash's KEEP FOR reason for a
# servo and an optic dropped from "contracts" to plain "crafting" because
# craftUse had no case for either, and craftPart still said the servo is in
# no recipe when four eat it. The shop panel still said the Carbine and the
# Scattergun can only come from Wirt or a container.
SubRx @'
  if(it.use==='stim') return 'Ten seconds of unlimited stamina and a fifth more speed.';   // v11.83
'@ @'
  if(it.use==='stim') return 'Ten seconds of unlimited stamina and a fifth more speed.';   // v11.83
  if(it.use==='gun') return 'A gun. Equip it from the stash, or sell it at the terminal.';   // v12.10: the bench makes these now
'@
SubRx @'
function craftPart(k){
  // v9.43: the servo is out. It appears in no recipe and in no rack, and the one
  // thing it was for was repairing guns that have not worn since v9.01. Being a
  // craft part is what made SELL ALL refuse it and made the stash tell him to KEEP
  // it, so the item whose entire purpose had been deleted was also the item the
  // game insisted he hoard. It is salvage now, and salvage sells for 310.
  return k==='scrap'||k==='wire'||k==='cell'||k==='board'||k==='comp';
}
'@ @'
function craftPart(k){
  // v9.43 took the servo out: it was in no recipe and its one use, repairs, had
  // gone with wear at v9.01, so keeping it was hoarding for nothing.
  // v12.10: it is back, and the optic with it, because the four gun recipes of
  // v11.79 eat the servo and one of them the optic; SELL ALL keeps them and
  // the stash says what for.
  return k==='scrap'||k==='wire'||k==='cell'||k==='board'||k==='comp'||k==='servo'||k==='optic';
}
'@
SubRx @'
  if(k==='comp')  return 'plates, medkits, smoke, decoys and frags';
  return 'crafting';
'@ @'
  if(k==='comp')  return 'plates, medkits, smoke, decoys and frags';
  if(k==='servo') return 'guns on the bench, and contracts';   // v12.10
  if(k==='optic') return 'the Auto Rifle, and contracts';      // v12.10
  return 'crafting';
'@
SubRx @'
       'anyone down here. Wirt puts one on his counter now and again, and otherwise '+
       'they are found up top or not at all.</b></div>';
  } else {
'@ @'
       'anyone down here. Wirt puts one on his counter now and again, and otherwise '+
       'they are found up top or not at all.</b></div>';
    // v12.10: two of those, plus the SMG and the Auto Rifle, can be built now
    // (v11.79); a separate line, because the sentence above is a key for his
    // own rewording of it.
    h+='<div class="vdesc">The Compact SMG, the Burst Carbine, the Riot Scattergun and the Auto Rifle can all be built at the crafting bench.</div>';
  } else {
'@
SubRx @'
  'FOUR GUNS ON THE CRAFTING BENCH: the Compact SMG and Burst Carbine in green, the Auto Rifle and Riot Scattergun in blue. Moderately expensive in parts. Purple and gold guns are still the Peddler and the surface.',
'@ @'
  'FOUR GUNS ON THE CRAFTING BENCH: the Compact SMG in green, the Burst Carbine, Auto Rifle and Riot Scattergun in blue. Moderately expensive in parts. Purple and gold guns are still the Peddler and the surface.',
'@

# The recipe branch of the detail panel read the price row's rarity; every
# other panel asks dispR, so it does too.
SubRx @'
       '<span class="vpill r">'+escHtml(String((oit&&oit.r)||'common').toUpperCase())+'</span></div>'+
'@ @'
       '<span class="vpill r">'+escHtml(String(((typeof dispR==='function')&&dispR(outKey))||(oit&&oit.r)||'common').toUpperCase())+'</span></div>'+   // v12.10: the shown rarity
'@

# STAMPS.
SubRx @'
var VER='12.09';
'@ @'
var VER='12.10';
'@
SubRx @'
var WHATSNEW_VER='12.09';
'@ @'
var WHATSNEW_VER='12.10';
'@
$cnt=([regex]::Matches($s,"now:'v12\.09:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.09 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.09:[^']*'",{ param($m) "now:'v12.10: from the read-only review of the shipped v11.79, the bench guns told truthfully: the Burst Carbine is blue by the rarity every screen shows, so the bench holds one green and three blue and the card says so; the detail panel describes a crafted gun as a gun with its shown rarity; craftPart and craftUse know the servo and the optic again, so the stash keeps them and says for what; the shop panel adds that three of its unstocked guns can be built. The same build repairs check 11.79 (rarity through dispR, purchase price through replaceCost) and the v9.43 check that asserted a servo is in no recipe. Check 12.10 reads the bench through dispR, the blurb, the detail pill and the stash reasons; fails on v12.09.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
