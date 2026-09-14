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

# HIS RULING OF 2026-09-13: OUT OF A CONSUMABLE, HE SWITCHES BACK TO THE GUN HIMSELF.
# His words: if i switch to bandages or other throwables/consumables, it should not
# autofire the gun when I am out of those consumables, i should have to switch back
# to the gun.
#
# Five places selected the gun for him: the press on a blank cell (v12.31), the press
# on an empty throwable (v12.08), spending the last of a stack by click (v2.92/v12.31),
# letting go of the last cooked grenade (v12.31), and the use key on an empty
# throwable (v12.41). Each one put the gun under the next click. All five now leave
# the highlight where he put it; every empty press says what is missing and names the
# key of the cell that holds his gun.
# The blank-cell fall-back existed because a raid with the held gun bound to a higher
# key started on a blank cell 1. The raid now starts with the gun cell selected.
SubRx @'
function emptyThrowCell(tk){
  setHot(gunCell());
  if(!G.sim) say('No '+((ITEMS[tk]&&ITEMS[tk].name)||'throwable')+' left. '+((G.player.wep&&G.player.wep.name)||'Your gun')+' up.');
}
'@ @'
function emptyThrowCell(tk){
  // v13.42, HIS RULING OF 2026-09-13: names what is missing and the key for the gun,
  // and never selects the gun for him.
  if(!G.sim) say('No '+((ITEMS[tk]&&ITEMS[tk].name)||'throwable')+' left. '+gunKeyLine());
}
// v13.42: the sentence every empty cell ends with. The key is the belt cell that
// holds the gun in his hands, so a gun bound to key 5 says 5.
function gunKeyLine(){
  var gc=gunCell();
  return 'Press '+keyLabel('Digit'+(gc+1),String(gc+1))+' for your gun.';
}
'@

SubRx @'
  // Tools and assigned valuables are not held things, so they still yield.
'@ @'
  // Tools and assigned valuables are not held things, so they still yield.
  // v13.42, HIS RULING OF 2026-09-13: the valve is gone too. Nothing selects the
  // gun for him; an empty cell says what is missing and which key brings it up.
'@

SubRx @'
    // v12.31, audit P1: AN EMPTY CELL DOES NOT OWN THE TRIGGER EITHER. The raid
    // starts with the highlight on cell 1, and with the held gun bound to a
    // higher key that cell is blank, so the first click of the raid fired
    // nothing. The same rule as the empty throwable cell below: the press
    // selects the gun and yields; the next click fires it.
    if(HSC&&HSC.kind==='empty'){
      if(!p.fired){
        p.fired=true; setHot(gunCell()); p.trigYield=1;
        if(!G.sim) say('Nothing in that cell. '+((p.wep&&p.wep.name)||'Your gun')+' up.');
      }
    }
'@ @'
    // v12.31, audit P1: a blank cell 1 at the raid start killed the first click.
    // v13.42, HIS RULING: the raid now starts on the gun cell (startRaid), and a
    // press on a blank cell never selects the gun; it says which key does.
    if(HSC&&HSC.kind==='empty'){
      if(!p.fired){
        p.fired=true;
        if(!G.sim) say('Nothing in that cell. '+gunKeyLine());
      }
    }
'@

SubRx @'
        p.fired=true; setHot(gunCell()); p.trigYield=1;   // the gun fires on the NEXT click, never on the hold that yielded; v12.31: the cell that holds it, not cell 1 by number
        if(!G.sim) say('Nothing in that cell. '+((p.wep&&p.wep.name)||'Your gun')+' up.');
'@ @'
        p.fired=true;   // v13.42, HIS RULING: the Frag cell keeps the highlight and the gun is never raised for him
        if(!G.sim) say('No '+(HSC.name||'throwable')+' left. '+gunKeyLine());
'@

SubRx @'
      var _hadCount=HSC.count;
      useHot();
      // Emptied by that use? Fall back to the gun for the NEXT click.
      if(_hadCount!==null&&_hadCount!==undefined){
        var _now=hotbarSlots()[hotSel()];
        if(_now&&_now.count===0) setHot(gunCell());   // v12.31: the cell that holds the gun, not cell 1 by number
      }
'@ @'
      // v13.42, HIS RULING OF 2026-09-13: spending the last of a stack no longer
      // selects the gun. The highlight stays where he put it, and a press on the
      // spent cell says what is missing and which key brings the gun up.
      if(HSC.count===0){ if(!G.sim) say('No '+(HSC.name||'item')+' left. '+gunKeyLine()); }
      else useHot();
'@

SubRx @'
      releaseCook();
      var _ns=hotbarSlots()[hotSel()];
      if(_ns&&_ns.count===0) setHot(gunCell());   // v12.31: the cell that holds the gun, not cell 1 by number
'@ @'
      releaseCook();   // v13.42, HIS RULING: the last one thrown leaves its cell selected; he brings the gun up himself
'@

SubRx @'
  G=buildRaid(false);
  G.carriedIn=bagValue();
'@ @'
  G=buildRaid(false);
  try{ G.hot=gunCell(); }catch(_gh){}   // v13.42: a raid starts with the gun in hand selected, wherever his belt put it
  G.carriedIn=bagValue();
'@

SubRx @'
  'THE TRIGGER NO LONGER DIES WHEN THE GUN IN YOUR HANDS IS BOUND TO ANOTHER KEY. Cell 1 goes blank then, and every fall-back to it landed on nothing; the fall-back finds the cell that holds your gun now, and a click on a blank cell raises the gun the way a click on an empty grenade cell does.',
'@ @'
'@

SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'OUT OF BANDAGES OR GRENADES, YOU SWITCH BACK TO YOUR GUN YOURSELF. Using the last of something, or clicking a cell with nothing in it, no longer puts your gun up for you, so clicking on can never fire it. The game says which key brings your gun up, and every raid starts with your gun selected.',
'@

SubRx @'
var WHATSNEW_VER='13.41';
'@ @'
var WHATSNEW_VER='13.42';
'@

SubRx @'
var VER='13.41';
'@ @'
var VER='13.42';
'@

$pat = "(?m)^  now:'v13\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.42: OUT OF A CONSUMABLE, HE SWITCHES BACK TO THE GUN HIMSELF. His ruling of 2026-09-13: switching to bandages or throwables and running out must never autofire the gun. Five places selected the gun for him, the press on a blank cell, the press on an empty throwable, spending the last of a stack, letting go of the last cooked grenade and the use key on an empty throwable; all five now leave the highlight where he put it, and every empty press says what is missing and names the key of the cell that holds his gun. A raid now starts with the gun cell selected, which is what the blank-cell fall-back existed for. Check 13.42 spends the last Bandage and clicks on, throws the last cooked Frag and clicks on, presses the use key on the empty Frag cell, then selects the gun and fires it, and binds the gun to key 5 and requires the raid to start there; it fails on v13.41. Checks 12.08 and 12.31 are repaired to the ruling',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
