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

# PAD X RELOAD THEN SEARCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padXMode(mateDown){
  var p=G&&G.player;
  if(!G||!p) return 'KeyR';
  if(p.downed||mateDown||G.nearDown) return 'KeyE';
  if(inCombatNow()&&!p.hand&&p.wep&&p.ammo<p.wep.mag&&(rlHave(p)||p.reloading>0)) return 'KeyR';
  return (G.nearContainer||G.nearPad||G.nearDoor||G.nearPed||G.nearForge||(G.nearSeal&&!G.nearSeal.done)||(G.nearStray&&G.nearStray.found&&!G.nearStray.hostile))?'KeyE':'KeyR';
}
'@ @'
function padXMode(mateDown){
  var p=G&&G.player;
  if(!G||!p) return 'KeyR';
  if(p.downed||mateDown||G.nearDown) return 'KeyE';
  if(inCombatNow()&&!p.hand&&p.wep&&p.ammo<p.wep.mag&&(rlHave(p)||p.reloading>0)) return 'KeyR';
  return (G.nearContainer||G.nearPad||G.nearDoor||G.nearPed||G.nearForge||(G.nearSeal&&!G.nearSeal.done)||(G.nearStray&&G.nearStray.found&&!G.nearStray.hostile))?'KeyE':'KeyR';
}
// v28.xx (cw-cx-xreloadsearch): the prompt and a fresh X press share the active-reload override; revives still win.
function padXAction(mateDown){
  if(mateDown===undefined){ mateDown=false; try{ mateDown=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xm){} }
  var mode=padXMode(mateDown), p=G&&G.player;
  if(mode==='KeyE'&&p&&!p.downed&&p.reloading>0&&p.rlTot>0&&!G.nearDown&&!mateDown){
    var f=1-p.reloading/p.rlTot;
    if(f>=arLo(p)&&f<=arHi(p)) mode='KeyR';
  }
  return mode;
}
'@

SubRx @'
      if(_xDown&&!PAD.xWas){ PAD.xMode=null; PAD.xNearN=(G.player&&G.player.roll>0&&!G.player.downed)?(G.nearN||0):null; }
'@ @'
      if(_xDown&&!PAD.xWas){ PAD.xMode=null; PAD.xReloadGun=null; PAD.xNearN=(G.player&&G.player.roll>0&&!G.player.downed)?(G.nearN||0):null; }
'@

SubRx @'
      if(_xDown&&PAD.xMode==null&&(PAD.xNearN==null||PAD.xNearN!==(G.nearN||0)||(G.player&&G.player.downed))){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=padXMode(_xm); /* v28.xx (cw-cx-xfight): his 3.10 b: reload wins during a fight. */ var _rp=G.player; if(PAD.xMode==='KeyE'&&_rp&&!_rp.downed&&_rp.reloading>0&&_rp.rlTot>0&&!G.nearDown&&!_xm){ var _arf=1-_rp.reloading/_rp.rlTot; if(_arf>=arLo(_rp)&&_arf<=arHi(_rp)) PAD.xMode='KeyR'; /* v35.xx (cw-reloadstack): the spot of this chain */ } if(PAD.xNearN!=null){ PAD.xDownAt=G.t; PAD.xNearN=null; _xSearch=!!(G.nearPad&&G.nearContainer); } }   // v28.37 (cloud-coop-pad-active-reload), CLOUD HUNT 2026-10-15: X is the only reload button on a controller, so in the sweet spot of a reload it lands the active reload even with a box, body, door or forge in reach (it searched instead, so player 2 could never get the bonus there); a downed teammate still takes the revive
'@ @'
      if(_xDown&&PAD.xMode==null&&(PAD.xNearN==null||PAD.xNearN!==(G.nearN||0)||(G.player&&G.player.downed))){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=padXAction(_xm); if(PAD.xNearN!=null){ PAD.xDownAt=G.t; PAD.xNearN=null; _xSearch=!!(G.nearPad&&G.nearContainer); } }   // v28.xx (cw-cx-xreloadsearch): share the exact press decision with the box prompt, including the narrowed active-reload spot.
'@

SubRx @'
      if(_xDown&&G.player&&G.player.downed) PAD.xMode='KeyE';   // v17.04, co-op hunt 2026-09-28: downed, X holds E, also a hold carried onto the floor (above)
'@ @'
      // v28.xx (cw-cx-xreloadsearch): keep reload first (his 3.10 b), then search after the same gun completes its reload; cancellation never spends the hold.
      if(_xDown&&PAD.xMode==='KeyR'&&G.player){
        var _xr=G.player;
        if(_xr.reloading>0){ PAD.xReloadGun=_xr.wep; PAD.xReloadN=_xr.padReloadN||0; }
        else if(PAD.xReloadGun){
          if(PAD.xReloadGun===_xr.wep&&(_xr.padReloadN||0)>PAD.xReloadN&&!_xr.hand&&!_xr.downed&&!(_xr.roll>0)&&G.nearContainer){
            PAD.xMode='KeyE'; PAD.xDownAt=G.t; _xSearch=!!G.nearPad;
          }
          PAD.xReloadGun=null;
        }
      }
      if(_xDown&&G.player&&G.player.downed) PAD.xMode='KeyE';   // v17.04, co-op hunt 2026-09-28: downed, X holds E, also a hold carried onto the floor (above)
'@

SubRx @'
      var _skey='['+((G.nearPad&&padOn())?padB(pbn(3)):keyLabel('KeyE','E'))+'] SEARCH ', _ft, _fcr=null, _fsub='', _fsc=null;  // v27.70 (cloud-menus-pad-prompts-follow-binds), CLOUD HUNT 2026-10-15: the ring prompt said [Y] SEARCH after the ring search moved off Y; it names the button as set
      if(nc2.fallen&&(nc2.fellAt===undefined||G.t-nc2.fellAt>2.3)){
        _ft=_skey+nc2.fallen.toUpperCase();
        if(nc2.fallenCrew!==undefined&&CFG.raiderFeud!==0) _fcr=['#c8452f','#4a90c2','#c2a54a','#7a4ac2'][nc2.fallenCrew%4];
      }
      else if(nc2.tag) _ft=_skey+String(nc2.tag).toUpperCase();
      else _ft=_skey+(nc2.mercSrc?(String(nc2.mercSrc.name).toUpperCase()+"'S BACKPACK"):((nc2.type==='safe'&&nc2.camp)?'STRONGBOX':(nc2.type==='botwreck')?'WRECK':nc2.type.toUpperCase()));   // v22.xx (R49): SEARCH WRECK, the internal kind stays in the code
      // His #23: item names in the world when you are near them. A single-item
      // crate that YOU dropped or a body someone emptied loot into is not a
      // mystery box, so it says what it holds; multi-item finds stay unsearched
      // secrets, because he explicitly wants searching to mean something.
      if(nc2.loot.length===1&&nc2.dropped){
        var dit=ITEMS[nc2.loot[0]];
        if(dit){ _fsub=dit.name; _fsc=RCOL[dispR(nc2.loot[0])||dit.r]||'#cdd6dd'; }
      }
      hudPrompt(_ft,s.x,s.y,{accent:_fcr,sub:_fsub,subCol:_fsc});
'@ @'
      // v28.xx (cw-cx-xreloadsearch): the box names the action X will take; a held search keeps its chosen action. The ring retains its separate Y search.
      var _xReload=padOn()&&!G.nearPad&&((PAD.xWas&&PAD.xMode)?PAD.xMode:padXAction())==='KeyR';
      var _skey='['+((G.nearPad&&padOn())?padB(pbn(3)):keyLabel('KeyE','E'))+'] SEARCH ', _ft, _fcr=null, _fsub='', _fsc=null;  // v27.70 (cloud-menus-pad-prompts-follow-binds), CLOUD HUNT 2026-10-15: the ring prompt said [Y] SEARCH after the ring search moved off Y; it names the button as set
      if(nc2.fallen&&(nc2.fellAt===undefined||G.t-nc2.fellAt>2.3)){
        _ft=_skey+nc2.fallen.toUpperCase();
        if(nc2.fallenCrew!==undefined&&CFG.raiderFeud!==0) _fcr=['#c8452f','#4a90c2','#c2a54a','#7a4ac2'][nc2.fallenCrew%4];
      }
      else if(nc2.tag) _ft=_skey+String(nc2.tag).toUpperCase();
      else _ft=_skey+(nc2.mercSrc?(String(nc2.mercSrc.name).toUpperCase()+"'S BACKPACK"):((nc2.type==='safe'&&nc2.camp)?'STRONGBOX':(nc2.type==='botwreck')?'WRECK':nc2.type.toUpperCase()));   // v22.xx (R49): SEARCH WRECK, the internal kind stays in the code
      if(_xReload){ _ft='['+padB(pbn(2))+'] reload'; _fcr=null; }
      // His #23: item names in the world when you are near them. A single-item
      // crate that YOU dropped or a body someone emptied loot into is not a
      // mystery box, so it says what it holds; multi-item finds stay unsearched
      // secrets, because he explicitly wants searching to mean something.
      if(!_xReload&&nc2.loot.length===1&&nc2.dropped){
        var dit=ITEMS[nc2.loot[0]];
        if(dit){ _fsub=dit.name; _fsc=RCOL[dispR(nc2.loot[0])||dit.r]||'#cdd6dd'; }
      }
      hudPrompt(_ft,s.x,s.y,{accent:_fcr,sub:_fsub,subCol:_fsc});
'@

SubRx @'
      p.ammo+=take; p.reserve-=take*rktCost(p.wep);   // v28.xx (cw-rocket): a rocket costs 30
'@ @'
      p.ammo+=take; p.reserve-=take*rktCost(p.wep);   // v28.xx (cw-rocket): a rocket costs 30
      if(take>0) p.padReloadN=(p.padReloadN||0)+1; // v28.xx (cw-cx-xreloadsearch): completion survives a shot on this frame; cancelled reloads never stamp it.
'@

SubRx @'
var VER='35.55';
'@ @'
var VER='35.56';
'@

$pat = "(?m)^  now:'v35\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.56: At a box, pad X names reload when it reloads; keep holding to search after it finishes. Check 35.56 fails on v35.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
