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

# HOTBAR SWAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
for(_fh=0;_fh<2;_fh++) if(_hcReal(_hc[_fh])&&!_hcUsed[_fh]){ _ckA=gunClassKey(gunClassOf(_hc[_fh].icon));
'@ @'
for(_fh=0;_fh<2;_fh++) if(_hcReal(_hc[_fh])&&!_hcUsed[_fh]&&!_hcOnKey(_hc[_fh])/* cw-beltswap: already on a key he chose */){ _ckA=gunClassKey(gunClassOf(_hc[_fh].icon));
'@

SubRx @'
var HUBBELT={cells:[]};
'@ @'
var HUBBELT={cells:[]};
// cw-beltswap, his ask 10-27 ("grab guns and other items from the hot bar and move them around/swap them on the hotbar in the undercroft"):
// a drag that starts on the floor belt with the backpack shut. HUBFD.st is a hub backpack state holding the belt cells as drawn, so the
// press and the release run the backpack's own belt rules (move, swap, a gun on any gun key).
var HUBFD=null;
function hubFloorBeltPress(){
  if(typeof state==='undefined'||state!=='hub'||hubBagOpen||!HB||!(HUBBELT.cells||[]).length) return false;
  if((typeof hubWinOn==='function'&&hubWinOn())||document.querySelector('.modal.on')||(typeof pauseOpen!=='undefined'&&pauseOpen)) return false;
  var c=HUBBELT.cells, i, hit=false;
  for(i=0;i<c.length;i++) if(mouse.x>=c[i].x&&mouse.x<=c[i].x+c[i].w&&mouse.y>=c[i].y&&mouse.y<=c[i].y+c[i].h){ hit=true; break; }
  if(!hit) return false;
  var st=hubBagState(); st.hotCells=c.slice(); HUBFD={st:st};
  return true;
}
function withHubBelt(fn){
  if(hubBagOpen&&hubBagG) return withHubBag(fn);
  if(!HUBFD||!HUBFD.st) return false;
  var old=G, ran=false;
  try{ G=HUBFD.st; fn(); ran=true; }
  catch(_wf){}
  finally{ G=old; }
  return ran;
}
'@

SubRx @'
  if(state==='hub'&&hubBagOpen&&hubBagG){
    var _hbDone=false;
    withHubBag(function(){
      var GB=G.bagCells||[];
'@ @'
  if(state==='hub'&&((hubBagOpen&&hubBagG)||hubFloorBeltPress())){   // cw-beltswap: the floor belt takes a press with the backpack shut too
    var _hbDone=false;
    withHubBelt(function(){
      var GB=G.bagCells||[];
'@

SubRx @'
  if(state==='hub'&&hubBagOpen&&hubBagG&&hubBagG.drag){
    withHubBag(function(){
      var d=G.drag; G.drag=null;
'@ @'
  if(HUBFD&&!(HUBFD.st&&HUBFD.st.drag)) HUBFD=null;   // cw-beltswap: a press on the floor belt that picked nothing up
  if(state==='hub'&&((hubBagOpen&&hubBagG&&hubBagG.drag)||(!hubBagOpen&&HUBFD&&HUBFD.st.drag))){
    var _hbS=(hubBagOpen&&hubBagG)?hubBagG:HUBFD.st;   // cw-beltswap: the open backpack, or the floor belt with it shut
    withHubBelt(function(){
      var d=G.drag; G.drag=null;
'@

SubRx @'
    P.kit=(hubBagG.bag||[]).slice();
    P.hotAssign=hubBagG.hotAssign||{};
    try{ saveProfile(); }catch(_hs2){}
  }
'@ @'
    P.kit=(_hbS.bag||[]).slice();
    P.hotAssign=_hbS.hotAssign||{};
    try{ saveProfile(); }catch(_hs2){}
    HUBFD=null;
  }
'@

SubRx @'
  catch(_hbl){ HUBBELT.cells=[]; }
  finally{ G=old; }
}
'@ @'
  catch(_hbl){ HUBBELT.cells=[]; }
  finally{ G=old; }
  if(HUBFD&&HUBFD.st&&HUBFD.st.drag){ var _o3=G; try{ G=HUBFD.st; drawDragGhost(); }catch(_dg){} finally{ G=_o3; } }   // cw-beltswap: the item in his hand while it moves along the floor belt
}
'@

SubRx @'
    _gh[beltGroupOf(i)]+='<div data-plan="'+i+'" title="'
'@ @'
    _gh[beltGroupOf(i)]+='<div data-plan="'+i+'"'+((!it&&_fg&&String(_fg.k).indexOf('gun_')===0)?(' data-ghost="'+_fg.k+'"'):'')+' title="'
'@

SubRx @'
        if(_pk&&ITEMS[_pk]) grabbable(el,_pk,'plan:'+ix,ITEMS[_pk].name);
      })();
'@ @'
        if(_pk&&ITEMS[_pk]) grabbable(el,_pk,'plan:'+ix,ITEMS[_pk].name);
        else { var _gk=el.getAttribute('data-ghost'); if(_gk&&ITEMS[_gk]) grabbable(el,_gk,'plan:'+ix,ITEMS[_gk].name); }   // cw-beltswap, his ask 10-27: a gun the belt shows by itself moves too
      })();
'@

SubRx @'
#root #hub #hotplanwrap [data-plan] span{font:600 18px/1.2 var(--f-cond)!important;letter-spacing:.04em;color:var(--tx-2)!important;}
'@ @'
#root #hub #hotplanwrap [data-plan] span{font:600 18px/1.2 var(--f-cond)!important;letter-spacing:.04em;color:var(--tx-2)!important;}
#root #hub #hotplanwrap [data-plan] .ic{width:48px!important;height:48px!important;}   /* cw-beltswap: the hotbar icons read on every stash layout (his ask 10-27); some layouts held them at 30 px */
'@

SubRx @'
  ctx.save(); ctx.font=uiFont('label',R); ctx.textAlign='left';
'@ @'
  if(!padOn()) rows.push([keyLabel('KeyM','M'),'MAP']);   // cw-beltswap: M opens the lift map on the floor (35.12)
  ctx.save(); ctx.font=uiFont('label',R); ctx.textAlign='left';
'@

SubRx @'
'M','the map, on the surface'
'@ @'
'M','the map'
'@

SubRx @'
var VER='35.12';
'@ @'
var VER='35.13';
'@

$pat = "(?m)^  now:'v35\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.13: in the undercroft the floor hotbar picks up guns and items and moves or swaps them with the backpack shut; a gun moved to another key no longer also shows on its old key; dimmed guns on the stash hotbar pick up; bigger stash hotbar icons; m map on the floor key row Check 35.13 fails on v35.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
