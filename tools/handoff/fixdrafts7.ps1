$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Repairs to drafts 1197, 1198, 1219 and 1220 from the read-only review
# wf_2d91f454-ec6 (four agents, 25 findings; the high and the mediums folded
# in). The guard skips a replacement whenever the new text is already there.
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

# ---- 1197 (HIGH): the ghost already exists (drawDragGhost, v9.32); the
# redundant one goes, and the floor copy of the belt press takes the same
# predicate. The hand-cell drag needs real movement before it stows, and a
# release on another belt cell is refused in words.
RepRx 'p1197.ps1' (L @(
  "# the backpack"". Three faults. A drag drew nothing but a highlight on the",
  "# cell under the cursor, so with the backpack closed it looked like nothing",
  "# happened. The gun in a hand cell could be picked up only with the backpack",
  "# open and dropped only on its panel. And a belt key holding a gun (kind gun,",
  "# not a hand cell) could not be picked up at all.")) (L @(
  "# the backpack"". Two faults. The gun in a hand cell could be picked up only",
  "# with the backpack open and dropped only on its panel, so with it closed the",
  "# drag never started and the gesture looked dead (the cursor ghost of v9.32",
  "# had nothing to draw). And a belt key holding a gun (kind gun, not a hand",
  "# cell) could not be picked up at all, in the raid or on the floor.")) 1
RepRx 'p1197.ps1' (L @(
  "SubRx @'",
  "    ctx.fillText(sl[sel].name+'   [FIRE] use    [V] signal',W/2,hy-LH(6));",
  "    ctx.textAlign='left';",
  "  }",
  "'@ @'",
  "    ctx.fillText(sl[sel].name+'   [FIRE] use    [V] signal',W/2,hy-LH(6));",
  "    ctx.textAlign='left';",
  "    // v11.97, HIS NOTE: THE GHOST. A drag drew nothing but a highlight on the cell",
  "    // under the cursor, so with the backpack closed it looked like nothing had",
  "    // happened. The item rides the cursor now, open or closed.",
  "    if(G&&G.drag&&G.drag.key&&ITEMS[G.drag.key]){ ctx.globalAlpha=.85; drawItemIcon(ctx,G.drag.key,mouse.x+LH(10),mouse.y+LH(10),LH(26)); ctx.globalAlpha=1; }",
  "  }",
  "'@")) (L @(
  "SubRx @'",
  "          if(_sl&&_sl.kind!=='gun'&&_sdk){ G.drag={key:_sdk,fromHot:_H.i}; blip('pick'); }",
  "'@ @'",
  "          if(_sl&&_sdk&&!(_sl.k==='gunA'||_sl.k==='gunB')){ G.drag={key:_sdk,fromHot:_H.i}; blip('pick'); }   // v11.97: a key holding a gun drags on the floor too",
  "'@",
  "SubRx @'",
  "          G.drag={key:'gun_'+_hs2.icon,gunSlot:_hs2.k,fromHot:_HC2.i};",
  "'@ @'",
  "          G.drag={key:'gun_'+_hs2.icon,gunSlot:_hs2.k,fromHot:_HC2.i,px:mouse.x,py:mouse.y};   // v11.97: the press point, so a click is not a stow",
  "'@")) 1
RepRx 'p1197.ps1' (L @(
  "    if(d.gunSlot){",
  "      // v11.97, HIS NOTE: released anywhere that is not a belt cell, it goes into",
  "      // the backpack, open or closed. A release on its own cell is a click.",
  "      var _onCell=false;",
  "      if(G.hotCells) for(var _gc=0;_gc<G.hotCells.length;_gc++){ var _GC=G.hotCells[_gc]; if(mouse.x>=_GC.x&&mouse.x<=_GC.x+_GC.w&&mouse.y>=_GC.y&&mouse.y<=_GC.y+_GC.h){ _onCell=true; break; } }",
  "      if(!_onCell) bagHeldGun(d.gunSlot);",
  "      d={key:null}; dropped=true;",
  "    }")) (L @(
  "    if(d.gunSlot){",
  "      // v11.97, HIS NOTE: released off the belt after a real drag, it goes into",
  "      // the backpack, open or closed. A release within a few pixels of the",
  "      // press is the click it always was; a release on another belt cell is",
  "      // refused in words, because a silent drop reads as a missing feature.",
  "      var _onCell=-1;",
  "      if(G.hotCells) for(var _gc=0;_gc<G.hotCells.length;_gc++){ var _GC=G.hotCells[_gc]; if(mouse.x>=_GC.x&&mouse.x<=_GC.x+_GC.w&&mouse.y>=_GC.y&&mouse.y<=_GC.y+_GC.h){ _onCell=_GC.i; break; } }",
  "      var _moved=(d.px===undefined)||(Math.hypot(mouse.x-d.px,mouse.y-d.py)>24);",
  "      if(_onCell<0&&_moved) bagHeldGun(d.gunSlot);",
  "      else if(_onCell>=0&&_onCell!==d.fromHot) say('Drop it off the belt to stow it in the backpack; its own key brings it up.');",
  "      d={key:null}; dropped=true;",
  "    }")) 1
RepRx 'p1197.ps1' "  'THE TACTICAL BELT DRAGS WITH THE BACKPACK CLOSED: the item rides the cursor, a gun in your hands dragged off the belt goes into the backpack, and a key holding a gun moves to another key like anything else.'," "  'THE TACTICAL BELT DRAGS WITH THE BACKPACK CLOSED: a gun in your hands dragged off the belt goes into the backpack, and a key holding a gun moves to another key like anything else, in a raid and on the floor.'," 1
RepRx 'p1197.ps1' "now:'v11.97: HIS NOTES of 2026-09-06, belt drags in a raid looked dead: no ghost was drawn, the gun in a hand cell dragged only with the backpack open and dropped only on its panel, and a key holding a gun could not be picked up. The dragged item rides the cursor, a hand gun released anywhere off the belt goes into the backpack open or closed, and a gun key drags like any key. Check 11.97 presses the hand cell with the backpack closed and releases off the belt, then drags an assigned gun key to another key, through the real canvas press and release; fails on v11.96.'" "now:'v11.97: HIS NOTES of 2026-09-06, belt drags looked dead: the gun in a hand cell dragged only with the backpack open and dropped only on its panel, so closed the drag never started, and a key holding a gun could not be picked up at all. A hand gun dragged and released off the belt goes into the backpack open or closed, a click on it still only selects, and a gun key drags like any key in the raid and on the floor. Check 11.97 clicks the hand cell (no stow), drags it off the belt (stowed), and drags a gun key to another key, through the real canvas press and release; fails on v11.96.'" 1
RepRx 'f1197.ps1' "     var bad=[], g=null, i;" "     var bad=[], g=null, i, P2=__P(), keepStash=(P2.stash||[]).slice(), keepW=(P2.weapons||[]).slice(), keepEq=P2.equipped;" 1
RepRx 'f1197.ps1' (L @(
  "         // ONE: the hand cell, backpack closed, released well off the belt.",
  "         mouse.x=cell.x+cell.w/2; mouse.y=cell.y+cell.h/2;")) (L @(
  "         // ZERO: a click on the hand cell, press and release on the spot, is still a click.",
  "         mouse.x=cell.x+cell.w/2; mouse.y=cell.y+cell.h/2;",
  "         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));",
  "         window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));",
  "         if(!p.wep||p.wep.id!==gunId) bad.push('a click on the hand cell stowed the gun (in hand: '+(p.wep&&p.wep.id)+')');",
  "         g.drag=null;",
  "         // ONE: the hand cell, backpack closed, released well off the belt.",
  "         mouse.x=cell.x+cell.w/2; mouse.y=cell.y+cell.h/2;")) 1
RepRx 'f1197.ps1' "     finally{ try{ if(g){ g.bagOpen=false; g.drag=null; } mouse.down=false; }catch(_c){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }" "     finally{ try{ if(g){ g.bagOpen=false; g.drag=null; } mouse.down=false; }catch(_c){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} P2.stash=keepStash; P2.weapons=keepW; P2.equipped=keepEq; try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }" 1
RepRx 'f1197.ps1' "what:'with the backpack closed, the gun in your hands drags off its belt cell into the backpack when released off the belt, and a key holding a gun drags to another key like any item (his notes of 2026-09-06)'" "what:'with the backpack closed, a click on the hand cell still only selects, a real drag off the belt puts the gun in the backpack, and a key holding a gun drags to another key like any item (his notes of 2026-09-06)'" 1
RepRx 'f1198.ps1' "what:'with the backpack closed, the gun in your hands drags off its belt cell into the backpack when released off the belt, and a key holding a gun drags to another key like any item (his notes of 2026-09-06)'" "what:'with the backpack closed, a click on the hand cell still only selects, a real drag off the belt puts the gun in the backpack, and a key holding a gun drags to another key like any item (his notes of 2026-09-06)'" 2

# ---- 1198: the edge call is a control, and the records say so.
RepRx 'd1198.txt' "middle"" when the tap happened at the edge. The check below proves a call" "middle"" when the tap happened at the edge. The check below shows a call accepted" 1
RepRx 'd1198.txt' "from 70 units out. The wording of the prompt is not changed here." "from 70 units out through the extraction tick itself; that arm is a control (it passes on every build) and the key path is not driven. The wording of the prompt is not changed here." 1
RepRx 'a1198.txt' "Check 11.98 calls the ship from 70 units out and extracts on a pull that began with half a second left; fails on the v11.97 fixture." "Check 11.98 extracts on a pull that began with half a second left (fails on the v11.97 fixture) and, as a control, calls the ship from 70 units out." 1

# ---- 1219: the menu matches the zoom of the surface it opens over (the
# station panel runs at 0.92 of the window factor), the check reads that
# number off the panel, keeps the kit, and bounds the menu by the real viewport.
RepRx 'p1219.ps1' (L @(
  "  var _mz=Math.max(1,(P&&P.menuZoom)||1)*titleRes();",
  "  m.style.zoom=_mz; x=x/_mz; y=y/_mz;")) (L @(
  "  var _mz=Math.max(1,(P&&P.menuZoom)||1)*titleRes();",
  "  var _hubEl=document.getElementById('hub');   // the stash runs at 0.92 of the window factor (v9.67); the menu matches the surface it opens over",
  "  if(_hubEl&&_hubEl.classList.contains('on')&&parseFloat(_hubEl.style.zoom)>0) _mz=parseFloat(_hubEl.style.zoom);",
  "  m.style.zoom=_mz; x=x/_mz; y=y/_mz;")) 1
RepRx 'f1219.ps1' "     var bad=[], P2=__P(), keepStash=(P2.stash||[]).slice();" "     var bad=[], P2=__P(), keepStash=(P2.stash||[]).slice(), keepKit=(P2.kit||[]).slice();" 1
RepRx 'f1219.ps1' (L @(
  "         var want=Math.max(1,(P2.menuZoom||1))*titleRes();",
  "         var z=parseFloat(m.style.zoom||'1')||1;")) (L @(
  "         var hubEl=document.getElementById('hub');",
  "         var want=(hubEl&&hubEl.classList.contains('on')&&parseFloat(hubEl.style.zoom)>0)?parseFloat(hubEl.style.zoom):Math.max(1,(P2.menuZoom||1))*titleRes();",
  "         var z=parseFloat(m.style.zoom||'1')||1;")) 1
RepRx 'f1219.ps1' "         if(r.left<0||r.top<0||r.right>W+1||r.bottom>H+1) bad.push('the menu is off the screen at '+Math.round(r.left)+','+Math.round(r.top)+' to '+Math.round(r.right)+','+Math.round(r.bottom));" "         if(window.innerWidth>=1200&&(r.left<0||r.top<0||r.right>window.innerWidth+1||r.bottom>window.innerHeight+1)) bad.push('the menu is off the viewport at '+Math.round(r.left)+','+Math.round(r.top)+' to '+Math.round(r.right)+','+Math.round(r.bottom));" 1
RepRx 'f1219.ps1' "     finally{ try{ closeItemMenu(); }catch(_c){} P2.stash=keepStash; try{ saveProfile(); }catch(_s){}" "     finally{ try{ closeItemMenu(); }catch(_c){} P2.stash=keepStash; P2.kit=keepKit; try{ saveProfile(); }catch(_s){}" 1
RepRx 'p1219.ps1' "  'THE RIGHT-CLICK MENU IN THE STASH IS THE SIZE OF THE STASH, at 4K and at every text size.'," "  'THE RIGHT-CLICK MENU IN THE STASH IS DRAWN AT THE SIZE OF THE SCREEN IT OPENS OVER, at 4K and at every text size.'," 1

# ---- 1220: the records name v10.63 (the damage half already shipped) and
# the check drives the heard-report site too.
RepRx 'd1220.txt' (L @(
  "THE FINDING. The Howler has two ways to fire: at the last place it saw or",
  "was told about you (the aimed shot) and at a report it heard (the wider",
  "scatter). Both aim at a point on the ground and neither asked whether a",
  "roof was over that point, so a Howler in the street dropped shells into",
  "the room you had run into, which is the one thing running inside is meant",
  "to buy.")) (L @(
  "THE FINDING. v10.63 already stops a shell hurting anyone under a roof it",
  "bursts on, and listed the aiming half as unverified. That half is this: the",
  "Howler has two ways to fire, at the last place it saw or was told about",
  "you (the aimed shot) and at a report it heard (the wider scatter), and",
  "neither asked whether a roof was over the target point. So a Howler in the",
  "street kept shelling the room you had run into, wasting its shots, and a",
  "shell whose scatter (up to 120 units) landed just outside the wall reached",
  "you through the doorway with its full blast, which is the leak he felt.")) 1
RepRx 'a1220.txt' "Both mortar sites aimed at a ground point and never asked whether a roof was over it." "v10.63 already stops a shell hurting anyone under the roof it bursts on; both mortar sites still aimed at a roofed point, wasting shots and leaking blast through the scatter." 1
RepRx 'f1220.ps1' (L @(
  "       // CONTROL: the same Howler shells the same player in the open.")) (L @(
  "       // ONE B: the heard-report site refuses the same roofed point too.",
  "       e.state='patrol'; e.cd=0; e.alert=0; e.hearT=8; e.heardX=p.x; e.heardY=p.y;",
  "       __ents(0.1);",
  "       var n1b=g.shells.filter(function(s){ return s.mortar; }).length;",
  "       if(n1b>n1) bad.push('the Howler shelled a report from under a roof ('+(n1b-n1)+' shell'+((n1b-n1)===1?'':'s')+')');",
  "       n1=n1b;",
  "       // CONTROL: the same Howler shells the same player in the open.")) 1
RepRx 'd1220.txt' "Not verified: a shell already in the air when he steps inside, which" (L @(
  "Not verified: a Howler inside the same building as you, which the rule",
  "still allows and the check does not stage; a shell already in the air when he steps inside, which")) 1
