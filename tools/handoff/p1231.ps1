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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P1, confirmed): binding the gun in your
# hands to a belt key (drag a bagged rifle onto key 5 and press it, or a figure
# gun bound at the rack in the Undercroft) makes the v6.70 dedupe blank the
# derived gun cell 1 to {kind:'empty'}. Three places then fell back to
# setHot(0) by number: the v12.08 empty-throwable yield ("Nothing in that cell.
# Rifle up." while cell 1 is empty), and the two last-consumable fall-backs.
# The highlight landed on the empty cell, useHot did nothing there, the next
# fall-back setHot(0) returned early because G.hot was already 0, and the
# trigger was dead until a different digit was pressed. A raid also STARTS
# with G.hot at 0, so with the held gun bound to key 3 or higher the first
# click of the raid fired nothing. One helper finds the cell that holds the
# gun in hand (the loop swapGuns already uses); the three fall-backs use it;
# and an empty cell yields to that cell the way an empty throwable cell does.
SubRx @'
function hotSel(){ return clamp(G.hot||0,0,hotbarSlots().length-1); }
'@ @'
function hotSel(){ return clamp(G.hot||0,0,hotbarSlots().length-1); }
// v12.31, audit P1: THE CELL THAT HOLDS THE GUN IN YOUR HANDS. Cell 1 is only
// that cell while nothing is assigned over it; bind the held gun to key 5 and
// the dedupe blanks cell 1, so a fall-back to 0 by number landed on an empty
// cell and the trigger died there. The same loop swapGuns uses; 0 when no
// cell holds the gun at all (items assigned over both), which is the old answer.
function gunCell(){
  var sl=hotbarSlots();
  for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='gun'&&sl[i].inHand) return i;
  return 0;
}
'@
SubRx @'
        p.fired=true; setHot(0); p.trigYield=1;   // the gun fires on the NEXT click, never on the hold that yielded
'@ @'
        p.fired=true; setHot(gunCell()); p.trigYield=1;   // the gun fires on the NEXT click, never on the hold that yielded; v12.31: the cell that holds it, not cell 1 by number
'@
SubRx @'
        if(_now&&_now.count===0) setHot(0);
'@ @'
        if(_now&&_now.count===0) setHot(gunCell());   // v12.31: the cell that holds the gun, not cell 1 by number
'@
SubRx @'
      if(_ns&&_ns.count===0) setHot(0);
'@ @'
      if(_ns&&_ns.count===0) setHot(gunCell());   // v12.31: the cell that holds the gun, not cell 1 by number
'@
SubRx @'
    if(HSC&&HSC.kind==='throw'){
'@ @'
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
    else if(HSC&&HSC.kind==='throw'){
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE TRIGGER NO LONGER DIES WHEN THE GUN IN YOUR HANDS IS BOUND TO ANOTHER KEY. Cell 1 goes blank then, and every fall-back to it landed on nothing; the fall-back finds the cell that holds your gun now, and a click on a blank cell raises the gun the way a click on an empty grenade cell does.',
'@

# STAMPS.
SubRx @'
var VER='12.30';
'@ @'
var VER='12.31';
'@
SubRx @'
var WHATSNEW_VER='12.30';
'@ @'
var WHATSNEW_VER='12.31';
'@
$cnt=([regex]::Matches($s,"now:'v12\.30:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.30 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.30:[^']*'",{ param($m) "now:'v12.31: 2026-09-07 audit P1: binding the gun in hand to another belt key blanks the derived cell 1 (the v6.70 dedupe), and the three fall-backs to setHot(0) by number (the v12.08 empty-throwable yield and the two last-consumable fall-backs) landed on that blank cell, where useHot did nothing and the next setHot(0) returned early, so the trigger was dead until another digit; a raid also starts with the highlight on cell 1, so the first click fired nothing. gunCell() finds the cell that holds the gun in hand (the loop swapGuns uses), the three fall-backs use it, and a click on an empty cell selects the gun and yields like the empty-throwable rule. Check 12.31 binds the held gun to key 5, confirms cell 1 is blank, clicks on it and requires the gun cell selected with no shot on that hold and a shot on the next click, then selects an empty throwable cell and requires the same; fails on v12.30.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
