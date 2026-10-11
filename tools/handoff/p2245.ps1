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

# THE UNDERCROFT BELT EDITS ALL FOUR GUN KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(_fk=0;_fk<GUNKEYS&&_fk<out.length;_fk++){
    if(!(out[_fk]&&out[_fk].gunFill)) continue;
    _fp=-1; _fpk=null;
    if(G.hubFloor&&_fk<2){   // v21.93: keys 1 and 2; keys 3 and 4 fill as in a raid, with the packed guns after the guns in his hands
      // v21.90, from the review of 21.83: THE UNDERCROFT BELT KEEPS ITS OLD ORDER until the floor edits the gun keys itself: gun 1
      // only on key 1 and gun 2 only on key 2, and a gun whose key holds an item of his goes on to v17.17 below. Filling a covered
      // key 1 put gun 1 on key 2 and sent gun 2 to key 9, where the floor release (v18.91, which goes by gun 1 and gun 2) could
      // bring neither gun back onto key 1; and with no gun 1 it showed gun 2 on key 1 and Bare Hands on key 2.
      if(_fk<2&&!_hcUsed[_fk]&&_hc[_fk]) _fp=_fk;
    } else {
      for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hcReal(_hc[_fh])&&!_hcOnKey(_hc[_fh])) _fp=_fh;
      if(_fp<0&&G.hubFloor) _fpk=_hcPacked();   // v21.93: a packed gun before Bare Hands on keys 3 and 4 of the floor
      if(!_fpk) for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hc[_fh]&&!_hc[_fh].vacant&&!_hcReal(_hc[_fh])) _fp=_fh;
      if(_fp<0&&!_fpk&&_hc[1]&&_hc[1].vacant&&!_hcUsed[1]) _fp=1;
    }
'@ @'
  // v21.90, from the review of 21.83: THE UNDERCROFT BELT KEEPS ITS OLD ORDER: gun 1 on key 1 and gun 2 on key 2, and a gun whose key
  // holds an item of his goes on to a later key. Filling a covered key 1 put gun 1 on key 2 and sent gun 2 to key 9.
  // v22.45, the four-gun belt, build 4: THE FLOOR EDITS ALL FOUR GUN KEYS, so this old order now has one exception, the one the raid
  // start (gunKeysSettle with deploy) already makes: a gun he put on another gun key (3 or 4) is shown there and not on its old key
  // too. Keys 1 and 2 take their own gun first, before any other key is filled, as the raid start pins them; a key whose gun went
  // elsewhere fills as in a raid (no packed gun on keys 1 and 2, which the raid start never gives one), so the floor belt still
  // shows exactly the keys the raid starts on.
  if(G.hubFloor) for(_fk=0;_fk<2&&_fk<GUNKEYS&&_fk<out.length;_fk++)
    if(out[_fk]&&out[_fk].gunFill&&_hc[_fk]&&!_hcUsed[_fk]&&!(_hcReal(_hc[_fk])&&_hcOnKey(_hc[_fk]))){ out[_fk]=_hc[_fk]; _hcUsed[_fk]=true; }
  for(_fk=0;_fk<GUNKEYS&&_fk<out.length;_fk++){
    if(!(out[_fk]&&out[_fk].gunFill)) continue;
    _fp=-1; _fpk=null;
    for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hcReal(_hc[_fh])&&!_hcOnKey(_hc[_fh])) _fp=_fh;
    if(_fp<0&&G.hubFloor&&_fk>=2) _fpk=_hcPacked();   // v21.93: a packed gun before Bare Hands on keys 3 and 4 of the floor
    if(!_fpk) for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hc[_fh]&&!_hc[_fh].vacant&&!_hcReal(_hc[_fh])) _fp=_fh;
    if(_fp<0&&!_fpk&&_hc[1]&&_hc[1].vacant&&!_hcUsed[1]) _fp=1;
'@

SubRx @'
            hubToast('Keys 1 and 2 are your two guns. Drop it on the other gun to trade them.');
            return;
'@ @'
            // v22.45, the four-gun belt, build 4: THE UNDERCROFT BELT EDITS ALL FOUR GUN KEYS. A gun in his hands dropped on any key but
            // the other gun (which trades, above) was refused in words: keys 1 and 2 were his two guns. Every key now takes it: the gun
            // is bound there in his plan, the way a drag of it on the Stash screen belt binds it (rackPut, one key per gun, and
            // dropDeadKeys keeps a key on a gun in his hands), and what he had on that key goes to the key the gun came from. On key 3
            // or 4 it is that gun key, and the key it left fills as at the raid start.
            G.hotAssign=G.hotAssign||{};
            var _hb4p=G.hotAssign[_H.i], _hb4k, _hb4m=false;
            for(_hb4k in G.hotAssign) if(G.hotAssign[_hb4k]===d.key) delete G.hotAssign[_hb4k];
            G.hotAssign[_H.i]=d.key;
            if(_hb4p&&_hb4p!==d.key&&d.fromHot!==undefined&&G.hotAssign[d.fromHot]===undefined){ G.hotAssign[d.fromHot]=_hb4p; _hb4m=true; }
            blip('pick');
            hubToast((_hb8n+' on key '+(_H.i+1)+(_hb4m?(' \u00b7 '+((ITEMS[_hb4p]&&ITEMS[_hb4p].name)||'Item')+' on key '+(d.fromHot+1)):'')).toUpperCase());
            return;
'@

SubRx @'
  for(var i=0;i<HOTBAR_N;i++){
    // THE TWO GUN KEYS. Shown so the numbers on this row are the numbers he will
    // actually press, and locked so he cannot build a plan the raid will discard.
    // v6.60: no gun cells. Every slot on the belt is the same slot.
    var k=(P.hotAssign||{})[i], it=k?ITEMS[k]:null;
    h+='<div data-plan="'+i+'" title="'+(it?('Key '+(i+1)+': '+it.name+', click to clear'):('Key '+(i+1)+', free'))+'"'+
'@ @'
  // v22.45, the four-gun belt, build 4: THE STASH SCREEN BELT SHOWS THE GUN KEYS. Keys 1 to 4 he has not bound showed a bare number,
  // while the floor belt and the raid put his guns there: gun 1 and gun 2 on keys 1 and 2 and the packed guns on keys 3 and 4. An
  // unbound gun key now shows the gun the floor belt shows on it, dimmed, so the plan reads as the keys he will press.
  var _fl=[];
  try{ var _flo=G; try{ G=hubBagState(); _fl=hotbarSlots()||[]; } finally{ G=_flo; } }catch(_fle){ _fl=[]; }
  for(var i=0;i<HOTBAR_N;i++){
    // THE TWO GUN KEYS. Shown so the numbers on this row are the numbers he will
    // actually press, and locked so he cannot build a plan the raid will discard.
    // v6.60: no gun cells. Every slot on the belt is the same slot.
    var k=(P.hotAssign||{})[i], it=k?ITEMS[k]:null, _fg=null;
    if(!it&&i<GUNKEYS&&_fl[i]&&_fl[i].kind==='gun'&&!_fl[i].vacant&&_fl[i].icon&&_fl[i].icon!=='fists'){
      var _fgk=(String(_fl[i].icon).indexOf('gun_')===0)?String(_fl[i].icon):('gun_'+_fl[i].icon);
      if(ITEMS[_fgk]) _fg={k:_fgk,name:escHtml(String(_fl[i].name||ITEMS[_fgk].name))};
    }
    h+='<div data-plan="'+i+'" title="'+(it?('Key '+(i+1)+': '+it.name+', click to clear'):(_fg?('Key '+(i+1)+': '+_fg.name):('Key '+(i+1)+', free')))+'"'+
'@

SubRx @'
      (it?iconImgHTML(k,22):'<span style="color:var(--ash);font-size:14px">'+(i+1)+'</span>')+
      (it?'<span style="position:absolute;right:2px;bottom:0;font-size:12px;color:var(--ash)">'+(i+1)+'</span>':'')+
'@ @'
      (it?iconImgHTML(k,22):(_fg?('<span style="display:flex;opacity:.7">'+iconImgHTML(_fg.k,22)+'</span>'):'<span style="color:var(--ash);font-size:14px">'+(i+1)+'</span>'))+
      ((it||_fg)?'<span style="position:absolute;right:2px;bottom:0;font-size:12px;color:var(--ash)">'+(i+1)+'</span>':'')+
'@

SubRx @'
    var kept=carriedGuns(G.player);
'@ @'
    // v22.45, the four-gun belt, build 4, decision D3: THE GUNS ON KEYS 1 AND 2 GO HOME AS GUN 1 AND GUN 2. Read off the belt before
    // anything is banked: the gun each key shows, in his hands or in the backpack, never an issued loaner or the freebie kit pistol.
    var _d3=[null,null];
    if(!G.sim){ try{
      var _d3s=hotbarSlots(), _d3p=G.player, _d3i, _d3c, _d3g, _d3w, _d3h;
      for(_d3i=0;_d3i<2&&_d3i<GUNKEYS;_d3i++){
        _d3c=_d3s[_d3i];
        if(!_d3c||_d3c.kind!=='gun'||_d3c.vacant||!_d3c.icon) continue;
        _d3g=String(_d3c.icon).replace(/^gun_/,'');
        if(_d3g==='fists'||!WEAPONS[_d3g]||!ITEMS['gun_'+_d3g]) continue;
        _d3w=(_d3p.wep&&_d3p.wep.id===_d3g)?0:((_d3p.sec&&_d3p.sec.id===_d3g)?1:-1);
        if(_d3w>=0){
          _d3h=_d3w?[_d3p.secIssued,_d3p.secFromArmory]:[_d3p.wepIssued,_d3p.wepFromArmory];
          if(_d3h[0]||(G.freeKit&&_d3g===FREEKIT_GUN&&!_d3h[1])) continue;
        } else if(G.bag.indexOf('gun_'+_d3g)<0) continue;
        _d3[_d3i]=_d3g;
      }
    }catch(_d3e){ _d3=[null,null]; } }
    var kept=carriedGuns(G.player);
'@

SubRx @'
    // loaner, and a gun bought next did not go into his hand. The death branch's two ownership repairs, applied here too.
    if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
    if((P.equippedSec||'none')===P.equipped) P.equippedSec='none';
'@ @'
    // loaner, and a gun bought next did not go into his hand. The death branch's two ownership repairs, applied here too.
    if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
    if((P.equippedSec||'none')===P.equipped) P.equippedSec='none';
    // v22.45, decision D3: the gun on key 1 is gun 1 and the gun on key 2 is gun 2, over the tier sort above; every other gun he carried
    // went home above as it always did (the armoury or the stash). Only a gun the armoury now holds takes a slot.
    if(_d3[0]&&P.weapons.indexOf(_d3[0])>=0){ if(P.equippedSec===_d3[0]) P.equippedSec='none'; P.equipped=_d3[0]; }
    if(_d3[1]&&_d3[1]!==P.equipped&&P.weapons.indexOf(_d3[1])>=0) P.equippedSec=_d3[1];
'@

SubRx @'
var VER='22.44';
'@ @'
var VER='22.45';
'@

$pat = "(?m)^  now:'v22\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.45: The Undercroft belt puts a gun on any key, the Stash screen belt shows the gun keys, and the guns on keys 1 and 2 come home as gun 1 and gun 2. Check 22.45 fails on v22.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
