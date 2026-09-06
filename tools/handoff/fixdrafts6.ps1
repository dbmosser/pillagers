$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Repairs to drafts 1212 to 1218 (reviewed as 1207 to 1213 by wf_282ab182-3ea,
# 37 findings; the high and the mediums folded in here). The guard skips a
# replacement whenever the new text is already present, so a re-run after a
# throw cannot apply an insertion twice.
$enc = New-Object Text.UTF8Encoding $false
function L { param([string[]]$lines) return ($lines -join "`n") }
function RepRx([string]$file, [string]$old, [string]$new, [int]$n) {
  $path = 'C:\claudecode\dark raiders\tools\handoff\' + $file
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0) { Write-Output ($file + ': already repaired'); return }
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ($file + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($file + ': repaired')
}

# ---- 1217 (HIGH): the empty-cell yield must not fire the gun on the same hold.
RepRx 'p1217.ps1' "        p.fired=true; setHot(0);" "        p.fired=true; setHot(0); p.trigYield=1;   // the gun fires on the NEXT click, never on the hold that yielded" 1
RepRx 'p1217.ps1' (L @(
  "# STAMPS.",
  "SubRx @'",
  "var VER='12.16';")) (L @(
  "SubRx @'",
  "  else if(mouse.down&&p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){",
  "'@ @'",
  "  else if(mouse.down&&!p.trigYield&&p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){   // v12.17: not on the hold that yielded to the gun",
  "'@",
  "SubRx @'",
  "  if(!mouse.down){",
  "    // Let go of a cooked grenade and it goes. Done before p.fired clears so a",
  "'@ @'",
  "  if(!mouse.down){",
  "    p.trigYield=0;   // v12.17: the latch lives for one hold",
  "    // Let go of a cooked grenade and it goes. Done before p.fired clears so a",
  "'@",
  "",
  "# STAMPS.",
  "SubRx @'",
  "var VER='12.16';")) 1
RepRx 'f1217.ps1' (L @(
  "       updatePlayer(0.016);",
  "       mouse.down=false;",
  "       if(hotSel()!==0) bad.push('the press on the empty Frag cell left cell '+hotSel()+' selected instead of the gun');")) (L @(
  "       updatePlayer(0.016);",
  "       if(hotSel()!==0) bad.push('the press on the empty Frag cell left cell '+hotSel()+' selected instead of the gun');",
  "       // TWO: the same hold, two more frames: the gun it raised must not fire.",
  "       var _sh0=g.tel.shots||0, _am0=p.ammo;",
  "       updatePlayer(0.016); updatePlayer(0.016);",
  "       if((g.tel.shots||0)!==_sh0||p.ammo!==_am0) bad.push('the hold that yielded to the gun fired it on the same hold ('+((g.tel.shots||0)-_sh0)+' shots, ammo '+_am0+' to '+p.ammo+')');",
  "       mouse.down=false; updatePlayer(0.016);")) 1
RepRx 'f1217.ps1' (L @(
  "       if(!/Nothing in that cell/.test(String(window.__lastSay||''))) bad.push('the press did not say the cell is empty (said ""'+String(window.__lastSay||'')+'"")');")) (L @(
  "       if(!/Nothing in that cell/.test(String(window.__lastSay||''))) bad.push('the press did not say the cell is empty (said ""'+String(window.__lastSay||'')+'"")');",
  "       // THREE, CONTROL: a loaded Frag cell still cooks on the press and keeps the selection.",
  "       g.pouch.frag=2; setHot(fi); p.fired=false; p.cooking=0; p.trigYield=0; mouse.down=true; updatePlayer(0.016);",
  "       if(!p.cooking||p.cookKind!=='frag') bad.push('control: a loaded Frag cell did not cook on the press (cooking '+p.cooking+', kind '+p.cookKind+')');",
  "       if(hotSel()!==fi) bad.push('control: a loaded Frag cell lost the selection');",
  "       mouse.down=false; updatePlayer(0.016);")) 1
RepRx 'f1217.ps1' "what:'the trigger on an empty grenade cell selects the gun and says so instead of going dead or cooking a grenade the cell did not name (2026-09-06 first-ten-minutes audit)'" "what:'the trigger on an empty grenade cell selects the gun and says so, fires nothing on that same hold, and a loaded cell still cooks (2026-09-06 first-ten-minutes audit)'" 1
RepRx 'f1218.ps1' "what:'the trigger on an empty grenade cell selects the gun and says so instead of going dead or cooking a grenade the cell did not name (2026-09-06 first-ten-minutes audit)'" "what:'the trigger on an empty grenade cell selects the gun and says so, fires nothing on that same hold, and a loaded cell still cooks (2026-09-06 first-ten-minutes audit)'" 2
RepRx 'd1217.txt' "Not verified: a pad, whose trigger reaches the same branch; his own thumb" (L @(
  "Not verified: the G key and the pad, which reach the throw through useHot",
  "and doThrow and can still cycle to another grenade; a pad, whose trigger",
  "reaches the same branch; his own thumb")) 1

# ---- 1212: the toast names the key the device has, like the overlay does.
RepRx 'p1212.ps1' "', or hold SPACE to give up.'" "', or hold '+keyLabel('Space','SPACE')+' to give up.'" 1
RepRx 'p1212.ps1' "                 :'DOWN. F to get back up. You get one per raid.');" "                 :'DOWN. '+keyLabel('KeyF','F')+' to get back up. You get one per raid.');" 1

# ---- 1213: the lift keeps the plan aside as the stash button does, and the
# check restores the fields the free-kit extraction rewrites.
RepRx 'p1213.ps1' (L @(
  "    P.hotAssign={}; P._gunSlot=null;",
  "    P.freeKit=1; P.kitBeforeFree=null; saveProfile();")) (L @(
  "    P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{})),gun:P._gunSlot||null};   // kept aside for the restore, as the stash button does (v12.06)",
  "    P.hotAssign={}; P._gunSlot=null;",
  "    P.freeKit=1; P.kitBeforeFree=null; saveProfile();")) 1
RepRx 'f1213.ps1' "keepStash=(P2.stash||[]).slice(), keepChosen=P2.kitChosen;" "keepStash=(P2.stash||[]).slice(), keepChosen=P2.kitChosen, keepEq=P2.equipped, keepSec=P2.equippedSec, keepW=(P2.weapons||[]).slice(), keepKS=P2.kitSaved;" 1
RepRx 'f1213.ps1' "P2.stash=keepStash; P2.kitChosen=keepChosen;" "P2.stash=keepStash; P2.kitChosen=keepChosen; P2.equipped=keepEq; P2.equippedSec=keepSec; P2.weapons=keepW; P2.kitSaved=keepKS;" 1
RepRx 'd1213.txt' (L @(
  "Not verified: the plan is not restored after a free run, which is also",
  "true of the stash button today and is the subject of the queued kit",
  "restore build; his own reading of the belt after a free run.")) (L @(
  "Not verified: the plan after a free run, which neither path restores yet",
  "because commitKit clears the kept-aside copy when it takes kitBeforeFree;",
  "his own reading of the belt after a free run.")) 1

# ---- 1216: the check proves the bonus is inside the number, not only that
# the two numbers agree.
RepRx 'f1216.ps1' (L @(
  "         if(banked!==shown) bad.push('the card says +'+shown+' XP and the profile was paid '+banked);")) (L @(
  "         if(banked!==shown) bad.push('the card says +'+shown+' XP and the profile was paid '+banked);",
  "         var rec=(P2.log||[]).slice(-1)[0];",
  "         if(!(rec&&rec.doseMul>1)) bad.push('control: the banked record carries no dose multiplier, so nothing was multiplied');",
  "         else if(shown!==Math.round(rec.xpBase*rec.doseMul)) bad.push('the card printed +'+shown+' against a base of '+rec.xpBase+' times '+rec.doseMul);")) 1

# ---- 1215: the rule fits its column, on two rows like every long rule.
RepRx 'p1215.ps1' "  ['WEAPONS','Belt keys 1 and 2 bring up either gun.']," (L @(
  "  ['WEAPONS','Keys 1 and 2 bring up'],",
  "  ['','either gun.'],")) 1

# ---- 1218: the clear is scoped to a bag that can take the arrow, and an
# arrow already held when the bag opens stops walking too.
RepRx 'p1218.ps1' "  if(G&&G.bagOpen&&code.indexOf('Arrow')===0) keys[code]=false;" "  if(G&&!G.over&&G.bagOpen&&G.bag.length&&bagStacks().length&&code.indexOf('Arrow')===0) keys[code]=false;" 1
RepRx 'p1218.ps1' (L @(
  "# STAMPS.",
  "SubRx @'",
  "var VER='12.17';")) (L @(
  "SubRx @'",
  "  if((code==='Tab'||code==='KeyI')&&G&&!G.over&&!repeat){ G.bagOpen=!G.bagOpen; G.bagSel=0; }",
  "'@ @'",
  "  if((code==='Tab'||code==='KeyI')&&G&&!G.over&&!repeat){",
  "    G.bagOpen=!G.bagOpen; G.bagSel=0;",
  "    // v12.18: an arrow still held when the bag opens stops walking too.",
  "    if(G.bagOpen){ keys['ArrowUp']=false; keys['ArrowDown']=false; keys['ArrowLeft']=false; keys['ArrowRight']=false; }",
  "  }",
  "'@",
  "",
  "# STAMPS.",
  "SubRx @'",
  "var VER='12.17';")) 1

# ---- 1214: the records say what the check does (ESC on the page body), and
# the pad line tells the truth.
RepRx 'f1214.ps1' (L @(
  "# opened, ESC is pressed on the window (the only place a real key lands on",
  "# the floor), and the backpack must be closed with no pause box; a second")) (L @(
  "# opened, ESC is pressed on the page body (so the pause box's window capture",
  "# listener runs first, as a real key does), and the backpack must be closed",
  "# with no pause box; a second")) 1
RepRx 'd1214.txt' (L @(
  "MEASURED. Check 12.14 enters the floor, opens the backpack, presses ESC on",
  "the window and requires the backpack closed and no pause box; then, with")) (L @(
  "MEASURED. Check 12.14 enters the floor, opens the backpack, presses ESC on",
  "the page body and requires the backpack closed and no pause box; then, with")) 1
RepRx 'd1214.txt' "Not verified: a pad, which has its own back button path; his own hand on" "Not verified: a pad, which has no way into or out of the floor backpack at all; his own hand on" 1
RepRx 'cm1214.txt' "is open. Check 12.14 drives both keys on the window; fails on v12.13." "is open. Check 12.14 drives ESC on the page body; fails on v12.13." 1
RepRx 'a1214.txt' "NOT MEASURED: the pad back button" "NOT MEASURED: a pad, which has no floor backpack path at all" 1
