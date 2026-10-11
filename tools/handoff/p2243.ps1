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

# THE BELT LINES READ LIKE A SHOOTER HUD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!G.sim) say(i<2?'No second weapon. Drag one here to carry it.':('Gun slot '+(i+1)+' empty').toUpperCase());
'@ @'
    // v22.43, his order of 2026-10-09 (the shooter voice), from the review of the four-gun belt (build 3): every gun key reads the same.
    if(!G.sim) say(('Gun slot '+(i+1)+' empty').toUpperCase());
'@

SubRx @'
  if(s2.vacant){ if(!G.sim) say('No second weapon. Drag one here to carry it.'); _hinted=true; }
'@ @'
  if(s2.vacant){ if(!G.sim) say(('Gun slot '+(i+1)+' empty').toUpperCase()); _hinted=true; }
'@

SubRx @'
    else if(!drawGun(_bix)){ say('Cannot equip '+s2.name+' right now.'); G.hot=_hot0; }
'@ @'
    else if(!drawGun(_bix)){ say('CANNOT EQUIP','info',{sub:String(s2.name).toUpperCase()}); G.hot=_hot0; }
'@

SubRx @'
        var _gbTxt=it.name+' to belt slot '+(gi+1)+'.';
'@ @'
        var _gbTxt=(it.name+' on key '+(gi+1)).toUpperCase();   // v22.43: the shooter voice
'@

SubRx @'
    var _gfTxt=('Gun slots full. '+it.name+' in backpack').toUpperCase();
    say(_gfTxt);
'@ @'
    var _gfTxt='GUN SLOTS FULL';   // v22.43: a headline and its detail, not one long line
    say(_gfTxt,'info',{sub:(it.name+' in backpack').toUpperCase()});
'@

SubRx @'
      var _beltTxt=it.name+' to belt slot '+(bi+1)+'.';
'@ @'
      var _beltTxt=(it.name+' on key '+(bi+1)).toUpperCase();   // v22.43: the shooter voice
'@

SubRx @'
        var _svTxt=it.name+' to belt slot '+(_svi+1)+'.';
'@ @'
        var _svTxt=(it.name+' on key '+(_svi+1)).toUpperCase();
'@

SubRx @'
        if(!G.sim) say('Nothing in that cell. '+gunKeyLine());
'@ @'
        if(!G.sim) say('EMPTY SLOT','info',{sub:gunKeyLine().replace(/\.$/,'').toUpperCase()});   // v22.43: the shooter voice
'@

SubRx @'
          say('Slot '+(HC.i+1)+' is a weapon slot. Guns only.');
'@ @'
          say('GUNS ONLY','info',{sub:'KEY '+(HC.i+1)});   // v22.43: the shooter voice
'@

SubRx @'
        else say('Drop it off the belt to stow it in the backpack; its own key brings it up.');
'@ @'
        else say('GUN KEYS ONLY','info',{sub:'DRAG OFF BELT TO STOW'});   // v22.43: the shooter voice
'@

SubRx @'
          say((_gwTi&&_gwTi.use!=='gun')?(_gw8n+' to slot '+(_onCell+1)+'. '+_gwTi.name+' to slot '+(d.fromHot+1)+'.'):(_gw8n+' to slot '+(_onCell+1)+'.'));
'@ @'
          say((_gw8n+' on key '+(_onCell+1)).toUpperCase(),'info',(_gwTi&&_gwTi.use!=='gun')?{sub:(_gwTi.name+' on key '+(d.fromHot+1)).toUpperCase()}:null);   // v22.43: the shooter voice
'@

SubRx @'
_gunKeyHint=(oldW.name+' to backpack, key '+(+_pk+1)).toUpperCase();
'@ @'
_gunKeyHint=(oldW.name+' in backpack \u00b7 key '+(+_pk+1)).toUpperCase();
'@

SubRx @'
  say(_gunKeyHint?(_eqLine.replace(/\.$/,'')+'. '+_gunKeyHint):_eqLine);
'@ @'
  // v22.43, his order of 2026-10-09 (the shooter voice), from the review of the four-gun belt (build 3): a gun routed to the free slot
  // reads SHOTGUN STOWED, and the key of the gun pushed out is the detail under the line, not a capital tail on a sentence.
  if(_kept&&!_oldLine) say(_newLine,'info',_gunKeyHint?{sub:_gunKeyHint}:null);
  else if(_gunKeyHint) say(_eqLine.replace(/\.$/,''),'info',{sub:_gunKeyHint});
  else say(_eqLine);
'@

SubRx @'
swapGuns(); if(_gunKeyHint) say(p.wep.name+' up. '+_gunKeyHint); }
'@ @'
swapGuns(); if(_gunKeyHint) say((p.wep.name+' up').toUpperCase(),'info',{sub:_gunKeyHint}); }
'@

SubRx @'
  var _newLine=_kept?(g.name+' to your empty slot. '+_kept.name+' stays in hand.')
'@ @'
  var _newLine=_kept?(g.name+' stowed').toUpperCase()   // v22.43: the shooter voice (the gun in hand is not named: it did not move)
'@

SubRx @'
function grantLoot(ct,keys,delay0){
'@ @'
var _lootSub='';   // v22.43: the detail of the gun line grantLoot hands back; the staged pull says it under that line
function grantLoot(ct,keys,delay0){
'@

SubRx @'
  var _gunLine='', _beltKeep=[], _beltGot;
'@ @'
  var _gunLine='', _beltKeep=[], _beltGot; _lootSub='';
'@

SubRx @'
          _gunLine=found.name+' to your empty slot. '+p.wep.name+' stays in hand. Select '+found.name+' on your tactical belt to swap.';
'@ @'
          // v22.43, his order of 2026-10-09 (the shooter voice): SHOTGUN STOWED, and under it the key that swaps to it (the bumpers on a
          // controller), read off the belt after the settle, so it names the key the gun really took.
          _gunLine=(found.name+' stowed').toUpperCase();
          var _swk=-1, _sws=hotbarSlots(), _swj;
          for(_swj=0;_swj<_sws.length&&_swk<0;_swj++) if(_sws[_swj]&&_sws[_swj].kind==='gun'&&!_sws[_swj].vacant&&!_sws[_swj].inHand&&_sws[_swj].icon===found.id) _swk=_swj;
          if(_swk<0) _swk=1;
          _lootSub=(padOn()?padB('LB or RB to swap'):('Press '+keyLabel('Digit'+(_swk+1),String(_swk+1))+' to swap')).toUpperCase();
'@

SubRx @'
      say(_gunLine?((keys.length>1)?(_gunLine+' '+_sum):_gunLine):_sum);
'@ @'
      if(_gunLine&&_lootSub){ say(_gunLine,'info',{sub:_lootSub}); if(keys.length>1) say(_sum); }   // v22.43: the stowed gun and its swap key
      else say(_gunLine?((keys.length>1)?(_gunLine+' '+_sum):_gunLine):_sum);
'@

SubRx @'
            if(_where) sayWhenFree(_where);
'@ @'
            if(_where) sayWhenFree(_where,'info',_lootSub?{sub:_lootSub}:null);   // v22.43: with the swap key under a stowed gun
'@

SubRx @'
  if(issued){ say(g.name+' is issued kit; it stays in your hands.'); return false; }
'@ @'
  if(issued){ say('ISSUED KIT','info',{sub:'CANNOT STOW'}); return false; }   // v22.43: the shooter voice
'@

SubRx @'
            say('He puts his '+ITEMS[_rpk].name.toLowerCase()+' in your hands.');
'@ @'
            // v22.43, his order of 2026-10-09 (the shooter voice), from the review of the four-gun belt (build 3): the line said he put it
            // in your hands, and since v21.93 the item goes into the backpack (a gun onto a free gun key). It names where it went.
            var _rpKy=-1; for(var _rpa in (G.hotAssign||{})) if(G.hotAssign[_rpa]===_rpk){ _rpKy=+_rpa; break; }
            say((ITEMS[_rpk].name+' received').toUpperCase(),'info',{sub:_rpKy>=0?('KEY '+(_rpKy+1)):(ITEMS[_rpk].use==='throw'?'ON BELT':'IN BACKPACK')});
'@

SubRx @'
var VER='22.42';
'@ @'
var VER='22.43';
'@

$pat = "(?m)^  now:'v22\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.43: The tactical belt lines now read like a shooter HUD: GUN SLOT 2 EMPTY, SHOTGUN ON KEY 3, GUN SLOTS FULL, EMPTY SLOT, SHOTGUN STOWED. Check 22.43 fails on v22.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
