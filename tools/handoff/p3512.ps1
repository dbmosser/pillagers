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

# UNDERCROFT FIXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hubScale(){
  return Math.max(1, Math.min(W/HUBW, H/HUBH));
}
'@ @'
var HZT=1, HZC=1, _hzLast=0;   // cw-hubfix, his ask 10-27: the wheel zooms the Undercroft floor (HZT the target, HZC the eased zoom)
function hubZoomEase(){
  var n=performance.now(), d=_hzLast?Math.min(0.1,(n-_hzLast)/1000):0.016; _hzLast=n;
  HZC+=(HZT-HZC)*Math.min(1,d*14); if(Math.abs(HZT-HZC)<0.001) HZC=HZT;
}
function hubScale(){
  return Math.max(1, Math.min(W/HUBW, H/HUBH))*(HZC||1);
}
// cw-hubfix: only on the bare floor; a station window, the stash, the backpack, the pause card or the title keep the wheel
function hubFloorWheel(e){
  if(e.ctrlKey||typeof state==='undefined'||state!=='hub'||!HB) return false;
  if(document.querySelector('.imenu')||document.querySelector('.modal.on')) return false;
  if((typeof pauseOpen!=='undefined'&&pauseOpen)||(typeof hubBagOpen!=='undefined'&&hubBagOpen)) return false;
  var _hb=document.getElementById('hub'), _tt=document.getElementById('title');
  if((_hb&&_hb.classList.contains('on'))||(_tt&&_tt.classList.contains('on'))) return false;
  var dy=e.deltaY*(e.deltaMode===1?40:(e.deltaMode===2?400:1));
  if(!dy) return true;
  HZT=clamp(HZT*Math.exp(-clamp(dy,-140,140)*0.0015),1,2.2);
  return true;
}
'@

SubRx @'
  var S=hubScale(), vw=W/S, vh=H/S;
'@ @'
  hubZoomEase(); var S=hubScale(), vw=W/S, vh=H/S;   // cw-hubfix
'@

SubRx @'
  e.preventDefault();
  var z=((P&&P.menuZoom)||1)+(e.deltaY<0?0.08:-0.08);
'@ @'
  if(!anyModal&&hubFloorWheel(e)){ e.preventDefault(); return; }   // cw-hubfix, his ask 10-27: on the bare floor the wheel zooms the floor
  e.preventDefault();
  var z=((P&&P.menuZoom)||1)+(e.deltaY<0?0.08:-0.08);
'@

SubRx @'
    hubBagOpen=false; hubBagG=null;   // v8.95: never arrive on the floor with it up
'@ @'
    hubBagOpen=false; hubBagG=null;   // v8.95: never arrive on the floor with it up
    HZT=1; HZC=1; _hzLast=0;   // cw-hubfix: every arrival on the floor starts at the fitted view
'@

SubRx @'
    if(e.code==='KeyQ'&&!e.repeat&&!_hubBusy&&HB){ hubWheelOpen(); e.preventDefault(); return; }   // v28.xx (cw-wheelhub): HOLD Q on the floor opens the item wheel, as in a raid
'@ @'
    if(e.code==='KeyQ'&&!e.repeat&&!_hubBusy&&HB){ hubWheelOpen(); e.preventDefault(); return; }   // v28.xx (cw-wheelhub): HOLD Q on the floor opens the item wheel, as in a raid
    if(e.code==='KeyM'&&!e.repeat&&!_hubBusy&&HB){ var _lf=hubStationById('lift'); if(_lf&&_lf.acts&&_lf.acts.KeyE) _lf.acts.KeyE[1](); e.preventDefault(); return; }   // cw-hubfix, his ask 10-27: M opens the lift map from anywhere on the floor
'@

SubRx @'
<div class="loslab">Tactical belt<b><span id="quickn">0</span> on keys</b></div>
'@ @'
<div class="loslab">Hotbar<b><span id="quickn">0</span> on keys</b></div>
'@

SubRx @'
      (it?iconImgHTML(k,22):(_fg?('<span style="display:flex;opacity:.7">'+iconImgHTML(_fg.k,22)+'</span>'):
'@ @'
      (it?iconImgHTML(k,(where?22:40)):(_fg?('<span style="display:flex;opacity:.7">'+iconImgHTML(_fg.k,(where?22:40))+'</span>'):
'@

SubRx @'
function itemIconURL(key,S){
  var ck=key+'|'+S, hit=_iconURL[ck];
'@ @'
function itemIconURL(key,S,np){
  var ck=key+'|'+S+(np?'|np':''), hit=_iconURL[ck];   // cw-hubfix: np paints the icon without the rarity pips (his note 10-27)
'@

SubRx @'
  drawItemIcon(c2,key,S*R/2,S*R/2,S*R*0.82);
'@ @'
  (np?drawItemIconArt:drawItemIcon)(c2,key,S*R/2,S*R/2,S*R*0.82);
'@

SubRx @'
function iconImg(key,S){
  var im=document.createElement('img');
  im.className='ic'; im.src=itemIconURL(key,S||26);
'@ @'
function iconImg(key,S,np){
  var im=document.createElement('img');
  im.className='ic'; im.src=itemIconURL(key,S||26,np);
'@

SubRx @'
function iconImgHTML(key,S){
  S=S||22;
  return '<img class="ic" src="'+itemIconURL(key,S)+'"
'@ @'
function iconImgHTML(key,S,np){
  S=S||22;
  return '<img class="ic" src="'+itemIconURL(key,S,np)+'"
'@

SubRx @'
iconImgHTML(log[i],22)
'@ @'
iconImgHTML(log[i],22,1)
'@

SubRx @'
iconImgHTML(k,72)
'@ @'
iconImgHTML(k,72,1)
'@

SubRx @'
row.appendChild(iconImg(sic,26));
'@ @'
row.appendChild(iconImg(sic,26,1));
'@

SubRx @'
iconImgHTML(gkey,26)
'@ @'
iconImgHTML(gkey,26,1)
'@

SubRx @'
iconImgHTML(shopEntryIcon(o),64)
'@ @'
iconImgHTML(shopEntryIcon(o),64,1)
'@

SubRx @'
row.appendChild(iconImg(id,26));
'@ @'
row.appendChild(iconImg(id,26,1));
'@

SubRx @'
row.appendChild(iconImg(outKey,26));
'@ @'
row.appendChild(iconImg(outKey,26,1));
'@

SubRx @'
iconImgHTML(icon,64)
'@ @'
iconImgHTML(icon,64,1)
'@

SubRx @'
'<div class="cres">'+iconImgHTML(k,30)
'@ @'
'<div class="cres">'+iconImgHTML(k,30,1)
'@

SubRx @'
var GAMBLE_POOL=[
  ['scrap',10],['wire',10],['cell',9],['bandage',9],['ammobox',10],['board',8],
  ['optic',7],['plate',6],['servo',6],['comp',6],['medkit',5],['smoke',4],['decoy',3],['frag',3],
  ['core',4],['coil',3],['ledger',3],['titan',3],
  ['gun_smg',3],['gun_carbine',2],['gun_shotgun',2],['gun_rifle',2],['gun_lmg',1],['gun_magnum',1],
  ['blackbox',1],['relay',1],['codex',1],['reactor',1],['bloom',1],['KEY',3]
];
'@ @'
var GAMBLE_POOL=[   // cw-hubfix, his note 10-27 ("I gambled like 20 times and never got anything good"): about half of all pulls are a gun or a valuable
  ['scrap',1],['wire',1],['cell',1],['bandage',2],['ammobox',2],['smoke',1],['decoy',1],['board',2],['comp',1],
  ['optic',3],['plate',8],['servo',3],['medkit',7],['frag',6],
  ['core',3],['coil',4],['ledger',4],['titan',4],['KEY',2],
  ['gun_smg',4],['gun_carbine',4],['gun_shotgun',4],['gun_rifle',4],['gun_lmg',5],['gun_magnum',3],
  ['blackbox',4],['relay',4],['codex',4],['reactor',4],['bloom',4]
];
'@

SubRx @'
    if(!it&&i<GUNKEYS&&_fl[i]&&_fl[i].kind==='gun'&&!_fl[i].vacant&&_fl[i].icon&&_fl[i].icon!=='fists'){
'@ @'
    if(where!=='sector'&&where!=='stage'&&!it&&i<GUNKEYS&&_fl[i]&&_fl[i].kind==='gun'&&!_fl[i].vacant&&_fl[i].icon&&_fl[i].icon!=='fists'){   // cw-hubfix, his note 10-27: no gun 1 / gun 2 ghosts on the pre-raid belt
'@

SubRx @'
  var _gn=['GUNS','THROW','MEDICAL','ARMOUR'], _gi;
'@ @'
  var _gn=['','THROW','MEDICAL','ARMOUR'], _gi;   // cw-hubfix, his note 10-27: no GUNS label, any key holds a gun or an item
'@

SubRx @'
data-core="1" data-pan="p"
'@ @'
data-core="1" title="burns 1 data core on ascent: elites and keys show live on your map" data-pan="p"
'@

SubRx @'
BURNS ON ASCENT</span><i class="cb"></i></button></div>';
  host.innerHTML=h;
'@ @'
BURNS ON ASCENT</span><i class="cb"></i></button></div>';
  // cw-hubfix, his note 10-27: packing an item rebuilt the list and threw it back to the top; the scroll is kept across the rebuild
  var _sk=[], _so=host.querySelector('.srplist'), _sl=_so?_so.scrollTop:0, _sa=host;
  while(_sa&&_sa!==document.body&&_sa.id!=='sectormodal'){ _sk.push([_sa,_sa.scrollTop]); _sa=_sa.parentElement; }
  host.innerHTML=h;
  try{ var _sn=host.querySelector('.srplist'); if(_sn&&_sl) _sn.scrollTop=_sl; for(var _si=0;_si<_sk.length;_si++) if(_sk[_si][0].scrollTop!==_sk[_si][1]) _sk[_si][0].scrollTop=_sk[_si][1]; }catch(_sx){}
'@

SubRx @'
var VER='35.11';
'@ @'
var VER='35.12';
'@

$pat = "(?m)^  now:'v35\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.12: the wheel zooms the undercroft floor and m opens the lift map; the stash row is called hotbar with bigger icons; no white rarity bars in the shop, craft and wirt windows; wirt pulls a gun or a valuable about half the time; no gun label or dimmed guns on the pre-raid belt; the data core row says what it does on hover; packing an item keeps the list where it was Check 35.12 fails on v35.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
