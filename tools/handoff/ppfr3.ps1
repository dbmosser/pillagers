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

# the dead backpack full message and its refusals are gone (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var cap=PACKCAP[P.pack],wt=(ITEMS[st.k]?ITEMS[st.k].wt:1);

'@ @'
  // v31.08 (cw-nobagfull), HIS RULING: no bag limit, no weight, ever. A stall sale is never refused for a full backpack, so no cap or weight is read here.

'@

SubRx @'
  if(!_pAmmo&&bagWeight()+wt>cap){ say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:bagDropHint()}); return; }   // v22.59 (R19): the same red row as a search

'@ @'

'@

SubRx @'
  if(bagged&&bagWeight()>PACKCAP[P.pack]){ ix=G.bag.lastIndexOf('gun_'+old.id); if(ix>=0){ dropItem(ix); say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:(BELTDISP.name+' dropped').toUpperCase()}); BELTDISP=null; } }

'@ @'

'@

SubRx @'
    if(bagged&&bagWeight()>PACKCAP[P.pack]){   // no room for the gun it pushed out: it drops at his feet, and the red row names it
      ix=G.bag.lastIndexOf('gun_'+ow.id);
      if(ix>=0){ dropItem(ix); say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:(BELTDISP.name+' dropped').toUpperCase()}); BELTDISP=null; }
    }

'@ @'

'@

SubRx @'
// v22.59 (R19): the detail under BACKPACK FULL names the button that drops the selected item on the device in hand: the key Z is
// bound to on the keyboard (keyLabel, so an unmoved keyboard reads [Z]), and Y on a controller, the button pollPad gives
// bagDropSel with the backpack open (padB names it for a PlayStation pad).
// v22.xx (tr4fixc): THE BACKPACK FULL DETAIL NAMES BOTH STEPS, AS A CAPS TAG. The detail read [Z] drops the selected item., a
// sentence on a row whose other tags are short caps, and it was not true where it was read: Z (and Y on a controller) drops only
// with the backpack open, and the pickup stack shows only with it shut. It now reads [B] BACKPACK, a middle dot, [Z] DROP on the
// keyboard (keyLabel, so a moved key reads as moved) and [VIEW] BACKPACK, a middle dot, [Y] DROP on a controller (VIEW opens the
// backpack in pollPad; padB names both for a PlayStation pad). With autoloot on it reads the same: autoloot never sheds rare or
// elite, and those can still be dropped by hand.
function bagDropHint(){ return padOn()?padB('['+pbn(8)+'] BACKPACK  \u00b7  ['+pbn(3)+'] DROP'):('['+keyLabel('KeyB','B')+'] BACKPACK  \u00b7  ['+keyLabel('KeyZ','Z')+'] DROP'); }

'@ @'

'@

SubRx @'
  // v8.37: RESTORED. v8.34 deleted this line as part of removing the carry
  // penalty and left four reads of `cap` in the container block below, which
  // threw on every frame the player held E on a box. The bag CAP and the carry
  // PENALTY were always two different rules; only the penalty was retired.
  // With PACKCAP at [99999,99999,99999] the bag-full branch below is correctly
  // inert, which is his 2026-08-22 order, and this line is what makes it inert
  // rather than fatal. updateBot has kept its own copy throughout.
  var cap=PACKCAP[P.pack];

'@ @'
  // v31.08 (cw-nobagfull), HIS RULING: no bag limit, no weight, ever. Nothing in this function reads the old pack cap any more (the search never refuses for a full
  // backpack); updateBot keeps its own copy for its greed test.

'@

SubRx @'
    // With autoloot on, a full bag sheds its worst rather than refusing you, so
    // you can keep grabbing and the pack manages itself. It never sheds rare or
    // elite, so if that is all you are carrying it still refuses.
    // v23.49 (arcade25): in the arcade a box holding only valuables, ammo and throwables puts nothing in the backpack (arcadeBagFree),
    // so a full backpack neither refuses it nor sheds for it.
    var _abf=!!(G.arcade&&arcadeBagFree(near));
    if(!_abf&&bagWeight()>=cap&&P.autoloot) autoCull(cap);
    if(!_abf&&bagWeight()>=cap){
      // v22.59, the raid text rewrite (R19): BACKPACK FULL IS ONE RED ROW. HIS ORDER (2026-10-09): a raid line is a short caps
      // headline and, only when needed, a short detail. This said Backpack full with the raw capacity number in brackets and Z drops
      // the selected item, in the middle of the screen, naming Z even with a controller in hand. It is now one keyed red row in the
      // pickup stack, BACKPACK FULL, refreshed every frame E is held (v21.91: never a second row), with the button that drops the
      // selected item on the device in hand as its detail, or that nothing is left worth dropping when autoloot is on.
      say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:bagDropHint()});   // v22.xx (tr4fixc): the shooter voice, autoloot too
      G.searching=null; G.searchT=0;
    }
    else {

'@ @'
    // v31.08 (cw-nobagfull), HIS RULING: no bag limit, no weight, ever. A search is never refused for a full backpack and never sheds anything, so the BACKPACK FULL
    // row, the autoloot cull and the arcade full-pack test (arcadeBagFree) have no caller here any more.
    {

'@

SubRx @'
var VER='31.07';
'@ @'
var VER='31.08';
'@

$pat = "(?m)^  now:'v31\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.08: A full backpack can no longer refuse a stall sale or a search, and the dead backpack full message is gone from the game. Check 31.08 fails on v31.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
