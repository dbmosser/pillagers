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

# SET THE GUN KEYS AND THE WHEEL IN THE STASH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .loslab b{ color:var(--bone); font-weight:600; }
'@ @'
  .loslab b{ color:var(--bone); font-weight:600; }
  /* v26.xx (gunkeys2), his #50 (menus must look AAA): THE STASH SETUP PLATES, under the tactical belt. GUN KEYS (keys 1 to 9) and the item WHEEL (the eight ring places on a
     3 by 3 compass plate) are rows of chamfered tiles in the graphite and amber of the other windows: the key number or the place in amber, the picture, the name in condensed caps. */
  #kitsetup .ksrow{ display:flex; gap:22px; padding:2px 12px 4px; }
  #kitsetup .ksp{ flex:1 1 0; min-width:0; }
  #kitsetup .loslab{ padding:6px 0 6px; align-items:center; }
  #kitsetup .ksreset{ min-height:0; padding:3px 11px; font-family:var(--f-cond); font-weight:700; font-size:12px; letter-spacing:.18em; color:var(--tx-2); background:rgba(0,0,0,.35);
    border:1px solid var(--ui-line-hi); border-radius:0; cursor:pointer; clip-path:polygon(7px 0,100% 0,100% 100%,0 100%,0 7px); }
  #kitsetup .ksreset:hover{ color:var(--acc); border-color:var(--acc); background:var(--ui-hover); }
  #kitsetup .ksgrid{ display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:5px; }
  #kitsetup .kst, #kitsetup .kstc{ display:flex; align-items:center; gap:7px; height:44px; padding:0 8px; box-sizing:border-box; min-width:0; font-family:var(--f-cond);
    background:rgba(0,0,0,.32); border:1px solid var(--ui-line-hi); border-left:2px solid var(--acc); clip-path:polygon(9px 0,100% 0,100% 100%,0 100%,0 9px); }
  #kitsetup .kst:hover{ border-color:var(--acc); background:var(--ui-hover); }
  #kitsetup .kst.padfocus{ clip-path:none; }
  #kitsetup .kst b{ flex:none; width:14px; font-weight:700; font-size:18px; line-height:1; color:var(--acc); }
  #kitsetup .kst .ic{ flex:none; }
  #kitsetup .kst span{ min-width:0; overflow:hidden; white-space:nowrap; font-weight:700; font-size:13px; letter-spacing:.1em; color:var(--tx-1); text-transform:uppercase; }
  #kitsetup .kstc{ justify-content:center; background:transparent; border:1px dashed var(--ui-line); clip-path:none; }
  #kitsetup .kstc span{ font-weight:700; font-size:12px; letter-spacing:.22em; color:var(--tx-2); }
  #kitsetup .ksnote{ padding:0 12px 8px; font-family:var(--f-cond); font-weight:600; font-size:12px; letter-spacing:.14em; color:var(--tx-2); text-transform:uppercase; }
'@

SubRx @'
            <div id="hotplanwrap"></div>
          </div>
          <div class="losec">

          </div>
'@ @'
            <div id="hotplanwrap"></div>
          </div>
          <div class="losec" id="kitsetup">
            <div class="ksrow">
              <div class="ksp"><div class="loslab">Gun keys<b><button class="ksreset" id="gkreset" title="HIS KEY TABLE BACK">RESET</button></b></div><div class="ksgrid" id="gkgrid"></div></div>
              <div class="ksp"><div class="loslab">Item wheel<b><button class="ksreset" id="whreset" title="HIS WHEEL ORDER BACK">RESET</button></b></div><div class="ksgrid" id="whgrid"></div></div>
            </div>
            <div class="ksnote">Drag a tile onto another to swap. A raid reads both.</div>
          </div>
'@

SubRx @'
function hotPlanHTML(where){
'@ @'
// v26.xx (gunkeys2), HIS ORDER 2026-10-14: "players should still be able to drag guns around on the bar, this is just the default of what key they tie to. Also this should be configurable
// in settings. or maybe in stash? also maybe player should be able to rearrange wheel in stash?" THE STASH SETUP. Two plates under the tactical belt: GUN KEYS (which class sits on which key,
// 1 to 9: drag a tile onto another key and the two classes trade) and WHEEL (which item sits at each of the eight ring places: drag a tile onto another place and the two trade). RESET puts
// his table and his order back. They live on the profile (P.gunKeys, P.wheelOrder) and a CAREER raid reads them (gunKeyList for the class keys, wheelList for the ring); DEMO always uses
// his table and his order. A table or an order that is not whole (a class or an item twice, or one missing) is not read: his own holds. Mouse first; the tiles are pad controls (padFocusables).
var GUN_CLASS_NAME={pistol:'PISTOL',smg:'SMG',rifle:'RIFLE',carbine:'CARBINE',lmg:'LMG',shotgun:'SHOTGUN',marksman:'MARKSMAN',sniper:'SNIPER',energy:'ENERGY'};
var GUN_CLASS_ICON={pistol:'gun_pistol',smg:'gun_smg',rifle:'gun_rifle',carbine:'gun_carbine',lmg:'gun_lmg',shotgun:'gun_shotgun',marksman:'gun_dmr',sniper:'gun_sniper',energy:'gun_lance'};
var WHEEL_NAME={medkit:'MEDKIT',smoke:'SMOKE',frag:'FRAG',trip:'TRIPWIRE',plate:'ARMOUR',decoy:'DECOY',bandage:'BANDAGE',stim:'STIM'};
var WHEEL_AT=[[0,1],[0,2],[1,2],[2,2],[2,1],[2,0],[1,0],[0,0]];   // row and column of each ring place on the 3 by 3 plate, clockwise from the top
function wheelOrderTable(){
  var src=(typeof P==='object'&&P&&Array.isArray(P.wheelOrder))?P.wheelOrder:null, ok=!!src&&src.length===WHEEL_ORDER.length, seen={}, i;
  for(i=0;ok&&i<src.length;i++){ if(WHEEL_ORDER.indexOf(src[i])<0||seen[src[i]]) ok=false; else seen[src[i]]=1; }
  return ok?src:WHEEL_ORDER;
}
function wheelOrderOf(){ return (typeof G==='object'&&G&&G.arcade&&!G.career)?WHEEL_ORDER:wheelOrderTable(); }
function kitSetupRender(){
  var gg=document.getElementById('gkgrid'), wg=document.getElementById('whgrid'), gb=document.getElementById('gkreset'), wb=document.getElementById('whreset'), gl, wl, i, h, cell=[];
  if(!gg||!wg) return;
  gl=gunKeyTable().slice(); wl=wheelOrderTable().slice();
  h='';
  for(i=0;i<gl.length;i++) h+='<div class="kst" data-gk="'+i+'" title="KEY '+(i+1)+' \u00b7 '+GUN_CLASS_NAME[gl[i]]+' \u00b7 DRAG ONTO ANOTHER KEY TO SWAP"><b>'+(i+1)+'</b>'+iconImgHTML(GUN_CLASS_ICON[gl[i]],30)+'<span>'+GUN_CLASS_NAME[gl[i]]+'</span></div>';
  gg.innerHTML=h;
  for(i=0;i<wl.length;i++) cell[WHEEL_AT[i][0]*3+WHEEL_AT[i][1]]=i;
  h='';
  for(i=0;i<9;i++){
    if(i===4){ h+='<div class="kstc"><span>WHEEL</span></div>'; continue; }
    h+='<div class="kst" data-wh="'+cell[i]+'" title="'+WHEEL_NAME[wl[cell[i]]]+' \u00b7 DRAG ONTO ANOTHER PLACE TO SWAP">'+iconImgHTML(wl[cell[i]],30)+'<span>'+WHEEL_NAME[wl[cell[i]]]+'</span></div>';
  }
  wg.innerHTML=h;
  Array.prototype.forEach.call(gg.querySelectorAll('[data-gk]'),function(el){
    var ix=+el.getAttribute('data-gk');
    grabbable(el,'gkc:'+gl[ix],'gk:'+ix,GUN_CLASS_NAME[gl[ix]]);
    dropzone(el,function(key,from){
      var s, t, c;
      if(typeof from!=='string'||from.indexOf('gk:')!==0) return;
      s=+from.slice(3); if(!(s>=0&&s<9)||s===ix) return;
      t=gunKeyTable().slice(); c=t[s]; t[s]=t[ix]; t[ix]=c;
      P.gunKeys=t; saveProfile(); try{ sfx('pick'); }catch(_e){}
      kitSetupRender();
    });
  });
  Array.prototype.forEach.call(wg.querySelectorAll('[data-wh]'),function(el){
    var ix=+el.getAttribute('data-wh');
    grabbable(el,'whl:'+wl[ix],'wh:'+ix,WHEEL_NAME[wl[ix]]);
    dropzone(el,function(key,from){
      var s, t, c;
      if(typeof from!=='string'||from.indexOf('wh:')!==0) return;
      s=+from.slice(3); if(!(s>=0&&s<8)||s===ix) return;
      t=wheelOrderTable().slice(); c=t[s]; t[s]=t[ix]; t[ix]=c;
      P.wheelOrder=t; saveProfile(); try{ sfx('pick'); }catch(_e){}
      kitSetupRender();
    });
  });
  if(gb) gb.onclick=function(){ delete P.gunKeys; saveProfile(); try{ sfx('pick'); }catch(_e){} kitSetupRender(); };
  if(wb) wb.onclick=function(){ delete P.wheelOrder; saveProfile(); try{ sfx('pick'); }catch(_e){} kitSetupRender(); };
}
function hotPlanHTML(where){
'@

SubRx @'
  dropzone(document.getElementById('floordrop'),function(key,from){ if(from==='rack')
'@ @'
  try{ kitSetupRender(); }catch(_kse){}   // v26.xx (gunkeys2): the gun keys and the wheel plates
  dropzone(document.getElementById('floordrop'),function(key,from){ if(from==='rack')
'@

SubRx @'
function wheelList(){
  var out=[], i;
  for(i=0;i<WHEEL_ORDER.length;i++) out.push({k:WHEEL_ORDER[i],n:wheelHave(WHEEL_ORDER[i])});
'@ @'
function wheelList(){
  var out=[], i, ord=wheelOrderOf();   // v26.xx (gunkeys2): the order the stash set, else his order
  for(i=0;i<ord.length;i++) out.push({k:ord[i],n:wheelHave(ord[i])});
'@

SubRx @'
[data-plan],.imenurow:not(.dim),[data-slot],.costile,.avslot,.tag'
'@ @'
[data-plan],.imenurow:not(.dim),[data-slot],.costile,.avslot,.tag,.kst'
'@

SubRx @'
var VER='26.36';
'@ @'
var VER='26.37';
'@

$pat = "(?m)^  now:'v26\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.37: The Stash screen now has GUN KEYS and WHEEL plates: drag tiles to swap which kind of gun sits on which key and where each item sits on the wheel, with RESET for his table and his order. Check 26.37 fails on v26.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
