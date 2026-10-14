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

# PILLAGERS, THE PEDDLER AND WIRT DEAL HIGHER RARITY GUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var wk=pick(['tacker','tacker','tacker','smg','smg','rifle','rifle','carbine','shotgun']);
'@ @'
  var _wkL=['tacker','tacker','tacker','smg','smg','rifle','rifle','carbine','shotgun'], _wkR=rr()*_wkL.length, wk=_wkL[Math.floor(_wkR)];
  // v26.30 (rarvar2): the pick above is pick() written out (the same one draw, the same row). Where in its row it fell is as even as the
  // pick itself, and decides the rarity: under RV_PCT of the row he carries the twin one rarity up (his drop is that twin).
  wk=rvGun(wk,_wkR-Math.floor(_wkR));
'@

SubRx @'
    var _t=0,_acc=0,_gk='dmr',_i;
'@ @'
    var _t=0,_acc=0,_gk='dmr',_i,_gf=0.99;
'@

SubRx @'
    for(_i=0;_i<_pool.length;_i++){ _acc+=_pool[_i][1]; if(_want<_acc){ _gk=_pool[_i][0]; break; } }
'@ @'
    for(_i=0;_i<_pool.length;_i++){ _acc+=_pool[_i][1]; if(_want<_acc){ _gk=_pool[_i][0]; _gf=(_want-(_acc-_pool[_i][1]))/_pool[_i][1]; break; } }
    _gk=rvGun(_gk,_gf);   // v26.30 (rarvar2): and where the gun roll fell in its row decides the twin, no new draw
'@

SubRx @'
  var _pg=pick(PED_GUNS);
'@ @'
  var _pg=pick(PED_GUNS);
  _pg=rvKey(_pg,((((Math.floor(x)*73+Math.floor(y)*151)%100)+100)%100)/100);   // v26.30 (rarvar2): one stall in five stocks the twin; the stall place decides, so nothing is drawn
'@

SubRx @'
function rollTable(t){var s=0,i;for(i=0;i<t.length;i++)s+=t[i][1];var r=rr()*s;
  for(i=0;i<t.length;i++){r-=t[i][1];if(r<=0)return t[i][0];}return t[0][0];}
'@ @'
var RT_FRAC=0.99;   // v26.30 (rarvar2): where in its row the last rollTable pick fell, 0 to 1 and as even as the pick itself: a rarity can be decided from it with no draw
function rollTable(t){var s=0,i;for(i=0;i<t.length;i++)s+=t[i][1];var r=rr()*s;
  for(i=0;i<t.length;i++){r-=t[i][1];if(r<=0){RT_FRAC=1+r/t[i][1];return t[i][0];}}RT_FRAC=0.99;return t[0][0];}
'@

SubRx @'
  var key=rollTable(GAMBLE_POOL); if(key==='KEY') key=resolveKey();
'@ @'
  var key=rollTable(GAMBLE_POOL), _gf=RT_FRAC; if(key==='KEY') key=resolveKey();
  key=rvKey(key,_gf);   // v26.30 (rarvar2): a gun out of the gamble is the twin one time in five, decided by where the pick fell
'@

SubRx @'
    ctx.font=fH; ctx.textAlign='left'; ctx.fillStyle=RCOL[gunRarity(cmp.f.id)]||HUDC.text;
    ctx.fillText(String(cmp.f.name).toUpperCase(),x+pad,yy,w-pad*2);
'@ @'
    var _rwd=ITEMRAR[gunRarity(cmp.f.id)]||'', _rww=0;   // v26.30 (rarvar2): the rarity word sits at the right of the name, in its colour
    if(_rwd){ ctx.font=fL; _rww=Math.round(ctx.measureText(_rwd).width+pad); }
    ctx.font=fH; ctx.textAlign='left'; ctx.fillStyle=RCOL[gunRarity(cmp.f.id)]||HUDC.text;
    ctx.fillText(String(cmp.f.name).toUpperCase(),x+pad,yy,w-pad*2-_rww);
    if(_rwd){ ctx.font=fL; ctx.textAlign='right'; ctx.fillText(_rwd,x+w-pad,yy); ctx.textAlign='left'; }
'@

SubRx @'
    if(!cmp.noVs) ctx.fillText('VS '+(cmp.h?String(cmp.h.name).toUpperCase():'BARE HANDS'),x+w-pad,yy,w*0.56);
'@ @'
    if(!cmp.noVs) ctx.fillText('VS '+(cmp.h?String(cmp.h.name).toUpperCase()+((cmp.h.id!==cmp.f.id&&gunBase(cmp.h.id)===gunBase(cmp.f.id))?(' '+(ITEMRAR[gunRarity(cmp.h.id)]||'')):''):'BARE HANDS'),x+w-pad,yy,w*0.56);   // v26.30 (rarvar2): the same model at another rarity says which
'@

SubRx @'
    var dmgTxt=perShot+' a hit';
'@ @'
    var dmgTxt=perShot+' a hit';
    if(RV_BASE[it.gk]) dmgTxt+='   '+(ITEMRAR[gunRarity(it.gk)]||'')+' +'+Math.round((VARIANT_DMG-1)*100)+'%';   // v26.30 (rarvar2): a rarity twin says its rarity and what it adds on the row it adds to (no new row: the hover keeps its eight)
'@

SubRx @'
var VER='26.29';
'@ @'
var VER='26.30';
'@

$pat = "(?m)^  now:'v26\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.30: Pillagers, the Peddler and Wirt now deal the higher rarity guns too, and the stat card names the rarity. Check 26.30 fails on v26.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
