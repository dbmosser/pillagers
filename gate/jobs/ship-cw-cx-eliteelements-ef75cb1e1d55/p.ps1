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

# RARE ELEMENT GUNS ON ELITE PILLAGERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    e.wep=WEAPONS[_gk]; e.dmg=WEAPONS[_gk].dmg;
'@ @'
    // v28.xx (cw-cx-eliteelements): his g-36, "Yes, a rare element gun". Reuse the elite roll; forgeApply draws nothing.
    var _ef=roll/rate;
    e.wep=(_ef<0.25)?forgeApply(WEAPONS[_gk],2,ELEM_ORDER[Math.floor(_ef/0.25*4)]):WEAPONS[_gk]; e.dmg=e.wep.dmg;
'@

SubRx @'
        var c=setLoot(mkContainer(e.x,e.y,'body'),_drop); G.containers.push(c);
'@ @'
        var c=setLoot(mkContainer(e.x,e.y,'body'),_drop); G.containers.push(c);
        // v28.xx (cw-cx-eliteelements): only the held, unpaid gun carries its forge onto the body.
        if(heldGunDrops(e)&&!e.paidRevive&&e.wep.fk===2&&ELEM[e.wep.el]) c.fw={gk:'gun_'+e.wep.id,fk:2,el:e.wep.el};
'@

SubRx @'
    if(itm&&itm.use==='gun'&&itm.gk&&!ct.dropped){ _rvF=rollFieldGun(itm.gk); if(_rvF.id!==itm.gk&&ITEMS['gun_'+_rvF.id]){ key='gun_'+_rvF.id; keys[l]=key; itm=ITEMS[key]; } }
'@ @'
    // v28.xx (cw-cx-eliteelements): keep the exact held model on a forged body gun, consuming the usual field roll.
    var _bodyForge=!!(!ct.dropped&&ct.fw&&!ct.fw.used&&ct.fw.gk===key&&ct.fw.fk===2&&ELEM[ct.fw.el]);
    if(itm&&itm.use==='gun'&&itm.gk&&!ct.dropped){ _rvF=rollFieldGun(itm.gk); if(_bodyForge){ _rvF=Object.assign({},WEAPONS[itm.gk],{q:'field',qRank:1}); } else if(_rvF.id!==itm.gk&&ITEMS['gun_'+_rvF.id]){ key='gun_'+_rvF.id; keys[l]=key; itm=ITEMS[key]; } }
'@

SubRx @'
      if(ct.dropped&&ct.fw&&(ct.fw.fk===1||ct.fw.fk===2)) found=forgeApply(found,ct.fw.fk,ct.fw.el);   // v23.xx (forge11): a forged gun comes out of the pile forged
'@ @'
      // v28.xx (cw-cx-eliteelements): a body upgrades its matching gun once; existing dropped piles keep their forge.
      if(ct.fw&&!ct.fw.used&&(ct.dropped||ct.fw.gk===key)&&(ct.fw.fk===1||ct.fw.fk===2)){ found=forgeApply(found,ct.fw.fk,ct.fw.el); ct.fw.used=1; }
'@

SubRx @'
function netContNewWord(ct){
'@ @'
// v28.xx (cw-cx-eliteelements): validate forge metadata for containers and a staged loot grant. No draws.
function netContForge(ct){
  var f=ct&&ct.fw, k;
  if(!f||(f.fk!==1&&f.fk!==2)) return null;
  k=(typeof f.gk==='string'&&/^gun_/.test(f.gk)&&Object.prototype.hasOwnProperty.call(ITEMS,f.gk)&&ITEMS[f.gk].use==='gun')?f.gk:'';
  if(f.gk&&!k) return null;
  if(f.fk===2&&!ELEM[f.el]) return null;
  return {gk:k,fk:f.fk,el:f.fk===2?f.el:'',used:f.used?1:0};
}
// v28.xx (cw-cx-eliteelements): reserve the one forged copy on the host before another seat can search it.
function netForgeLoot(ct,items){
  var f=netContForge(ct);
  if(f&&!f.used&&f.gk&&items.indexOf(f.gk)>=0) ct.fw.used=1;
  return f;
}
function netContNewWord(ct){
'@

SubRx @'
ib:ct.issuedB?1:0,lk:netLootList(ct.loot),pl:ct.pulled|0};
'@ @'
ib:ct.issuedB?1:0,lk:netLootList(ct.loot),pl:ct.pulled|0,fw:netContForge(ct)};
'@

SubRx @'
  if(m.ib) ct.issuedB=1;
'@ @'
  // v28.xx (cw-cx-eliteelements): the body and dropped pile retain their forge on the other window.
  var _cforge=netContForge({fw:m.fw}); if(_cforge) ct.fw=_cforge;
  if(m.ib) ct.issuedB=1;
'@

SubRx @'
netSend(q,{t:'loot',cid:r.cid,items:items,done:1,hot:hot.length?1:0});
'@ @'
netSend(q,{t:'loot',cid:r.cid,items:items,done:1,hot:hot.length?1:0,fw:netForgeLoot(ct,items)});
'@

SubRx @'
netSend(q,{t:'loot',cid:r.cid,items:items});
'@ @'
netSend(q,{t:'loot',cid:r.cid,items:items,fw:netForgeLoot(ct,items)});
'@

SubRx @'
  at=ct||{x:G.player.x,y:G.player.y};
'@ @'
  at=ct||{x:G.player.x,y:G.player.y};
  // v28.xx (cw-cx-eliteelements): the host says whether this pull owns the forged copy, including an already used body gun.
  if(Object.prototype.hasOwnProperty.call(m,'fw')){ var _lforge=netContForge({fw:m.fw}); if(_lforge) at.fw=_lforge; else delete at.fw; }
'@

SubRx @'
function netContLeftWord(ct){ return {t:'cont',cid:ct.cid,st:'left',lk:netLootList(ct.loot),pl:ct.pulled|0}; }
'@ @'
function netContLeftWord(ct){ return {t:'cont',cid:ct.cid,st:'left',lk:netLootList(ct.loot),pl:ct.pulled|0,fw:netContForge(ct)}; }
'@

SubRx @'
  if(st==='left'){ ct.netLk=netLootKeys(m.lk);
'@ @'
  if(st==='left'){ if(Object.prototype.hasOwnProperty.call(m,'fw')){ var _leftForge=netContForge({fw:m.fw}); if(_leftForge) ct.fw=_leftForge; else delete ct.fw; } ct.netLk=netLootKeys(m.lk);
'@

SubRx @'
  if(e.kind==='raider'){ m.c=netClean(e.coat,12);
'@ @'
  if(e.kind==='raider'){ m.fk=(e.wep&&e.wep.fk===2)?2:0; m.fe=(m.fk&&ELEM[e.wep.el])?e.wep.el:''; m.c=netClean(e.coat,12);
'@

SubRx @'
    if(typeof m.w==='string'&&Object.prototype.hasOwnProperty.call(WEAPONS,m.w)&&WEAPONS[m.w]&&WEAPONS[m.w].id) e.wep=WEAPONS[m.w];
'@ @'
    // v28.xx (cw-cx-eliteelements): the held gun tint agrees in both windows; enemy rounds still use warning red and no element.
    if(typeof m.w==='string'&&Object.prototype.hasOwnProperty.call(WEAPONS,m.w)&&WEAPONS[m.w]&&WEAPONS[m.w].id){ e.wep=(m.fk===2&&ELEM[m.fe])?forgeApply(WEAPONS[m.w],2,m.fe):WEAPONS[m.w]; e.dmg=e.wep.dmg; }
'@

SubRx @'
var VER='37.55';
'@ @'
var VER='37.56';
'@

$pat = "(?m)^  now:'v37\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.56: The held gun, body loot and party container words preserve the element. Enemy rounds stay plain and warning red. Check 37.56 fails on v37.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
