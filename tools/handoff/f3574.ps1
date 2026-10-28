$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'35.74',what:")) { throw "check 35.74 is in the fixture already" }

SubRx @'
  {v:'35.73',what:
'@ @'
  {v:'35.74',what:'cw-meleez, his order 10-28 (can we move melee to z as default? and middle mouse should ping?): melee (the crowbar) is on Z by default and drop an item for a teammate on V, a swap with nothing lost; a save that moved either key keeps it and an untouched save takes the new keys; the Keys window, the pause box, the F1 lists and the finish prompt name Z melee and V drop; middle mouse pings in a live raid, on the defaults and with an old saved map',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof keysOf!=='function'||typeof keyRemap!=='function'||typeof keysBind!=='function'||typeof keysListBody!=='function'||typeof keysLegendHtml!=='function'||typeof netPingMake!=='function'||typeof LEGEND==='undefined') return 'SKIP: no key map here';
     var bad=[], km0=JSON.stringify(P.keymap||{}), kv0=P.keymapV, g=null, p=null, oDrop=bagDropSel, nDrop=0, oPad=PAD.on, h, q, i, row, f, t;
     function kd(c){ window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,bubbles:true,cancelable:true})); }
     function ku(c){ window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true,cancelable:true})); }
     function clr(){ for(var z in keys) keys[z]=false; }
     function setMap(m){ P.keymap=m; P.keymapV=3; KEYS.inv=null; keysInv(); }
     function mmb(){ NET.pingAt=0; NET.pingLast=null; window.dispatchEvent(new MouseEvent('mousedown',{button:1,bubbles:true,cancelable:true})); window.dispatchEvent(new MouseEvent('mouseup',{button:1,bubbles:true,cancelable:true})); return NET.pingLast; }
     function stand(){ p.downed=false; p.dying=false; p.roll=0; p.iv=99; p.cooking=0; p.meleeAt=undefined; p.lastShot=undefined; g.barT=0; g.paused=false; g.trade=null; g.bagOpen=false; g.mapOpen=false; g.forgeUI=null; g.searching=null; if(g.mapFirst) g.mapFirst=null; clr(); }
     function keyRow(code){ var m=new RegExp('class="keybtn[^"]*" data-k="'+code+'" style="([^"]*)">([^<]*)<').exec(h); return m?{st:m[1],k:m[2]}:null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       PAD.on=false;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: staging: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       NET.on=false;
       // ONE: middle mouse pings in a live raid, on the default keys and with an old saved map
       setMap({}); stand();
       if(!mmb()) bad.push('ONE: middle mouse made no ping in a live raid on the default keys');
       setMap({KeyV:'KeyV',KeyZ:'KeyZ',KeyR:'KeyK'}); stand();
       if(!mmb()) bad.push('ONE: middle mouse made no ping with an old saved map');
       // TWO: the defaults are Z melee and V drop
       setMap({});
       if(keysOf('KeyV')!=='KeyZ') bad.push('TWO: melee is on '+keyName(keysOf('KeyV'))+' by default, not Z');
       if(keysOf('KeyZ')!=='KeyV') bad.push('TWO: drop for a teammate is on '+keyName(keysOf('KeyZ'))+' by default, not V');
       if(keyRemap('KeyZ')!=='KeyV'||keyRemap('KeyV')!=='KeyZ') bad.push('TWO: on the defaults Z reads as '+keyRemap('KeyZ')+' and V as '+keyRemap('KeyV'));
       // THREE: in the raid Z swings and V does not; with the backpack open V drops and Z does not
       stand(); kd('KeyZ'); ku('KeyZ'); if(!(g.barT>0)) bad.push('THREE: Z did not swing the crowbar');
       stand(); kd('KeyV'); ku('KeyV'); if(g.barT>0) bad.push('THREE: V swung the crowbar');
       bagDropSel=function(){ nDrop++; return false; };
       stand(); g.bag.push('bandage'); g.bagOpen=true; g.bagSel=0; kd('KeyV'); ku('KeyV'); if(nDrop!==1) bad.push('THREE: V with the backpack open dropped '+nDrop+' times, not once');
       nDrop=0; stand(); g.bagOpen=true; g.bagSel=0; kd('KeyZ'); ku('KeyZ'); if(nDrop) bad.push('THREE: Z with the backpack open dropped');
       bagDropSel=oDrop; stand();
       // FOUR: every list names Z melee and V drop, and neither reads as changed on the defaults
       h=keysListBody();
       row=keyRow('KeyV'); if(!row||row.k!=='Z') bad.push('FOUR: the Keys window melee row shows '+(row&&row.k)); else if(/amber/.test(row.st)) bad.push('FOUR: the melee key is marked as changed on the defaults');
       row=keyRow('KeyZ'); if(!row||row.k!=='V') bad.push('FOUR: the Keys window drop row shows '+(row&&row.k)); else if(/amber/.test(row.st)) bad.push('FOUR: the drop key is marked as changed on the defaults');
       q=String(keysLegendHtml());
       if(q.indexOf('>Z</b> melee')<0) bad.push('FOUR: the pause box does not say Z melee');
       if(q.indexOf('>V</b> drop an item for a teammate')<0) bad.push('FOUR: the pause box does not say V drop an item for a teammate');
       if(keyLabel('KeyV','V')!=='Z') bad.push('FOUR: the finish prompt names '+keyLabel('KeyV','V'));
       f={}; for(i=0;i<LEGEND.length;i++) f[LEGEND[i][0]]=LEGEND[i][1];
       if(!(f.FIGHT||[]).some(function(r){ return r[0]==='Z'&&/melee/.test(r[1]); })) bad.push('FOUR: the full controls list has no Z melee row');
       if(!(f.TEAM||[]).some(function(r){ return r[0]==='V'&&/drop/.test(r[1]); })) bad.push('FOUR: the full controls list has no V drop row');
       if(!LEGEND_MINI.some(function(r){ return r[0]==='Z'&&r[1]==='melee'; })) bad.push('FOUR: the compact controls list has no Z melee row');
       if(legendKeys('Z')!=='Z'||legendKeys('V')!=='V') bad.push('FOUR: the compact list reads '+legendKeys('Z')+' for Z and '+legendKeys('V')+' for V');
       // FIVE: a moved key keeps its place; a bind back is clean; a swap is a swap; reset gives the new defaults
       setMap({});
       if(!keysBind('KeyV','KeyK')) bad.push('FIVE: melee would not bind to K');
       if(keyRemap('KeyK')!=='KeyV') bad.push('FIVE: K does not swing after the bind');
       t=keyRemap('KeyZ'); if(t==='KeyV'||t==='KeyZ') bad.push('FIVE: Z still reads as '+t+' after melee moved to K');
       if(keyRemap('KeyV')!=='KeyZ') bad.push('FIVE: drop left V when melee moved to K');
       if(!keysBind('KeyV','KeyZ')) bad.push('FIVE: melee would not bind back to Z');
       if(Object.keys(P.keymap||{}).length) bad.push('FIVE: melee back on Z leaves a map entry '+JSON.stringify(P.keymap));
       keysBind('KeyV','KeyV');
       if(keysOf('KeyV')!=='KeyV'||keysOf('KeyZ')!=='KeyZ'||keyRemap('KeyV')!=='KeyV'||keyRemap('KeyZ')!=='KeyZ') bad.push('FIVE: melee onto V did not swap drop onto Z ('+JSON.stringify(P.keymap)+')');
       keysReset();
       if(keysOf('KeyV')!=='KeyZ'||keysOf('KeyZ')!=='KeyV') bad.push('FIVE: reset to defaults puts melee on '+keysOf('KeyV')+' and drop on '+keysOf('KeyZ'));
       // SIX: an old save; untouched takes the new keys, a moved pair keeps its keys
       if(typeof keysMig!=='function') bad.push('SIX: the loader has no key map migration');
       else {
         q=keysMig({keymap:{KeyR:'KeyK'},keymapV:2}); if(q.keymapV!==3||q.keymap.KeyR!=='KeyK'||q.keymap.KeyV!==undefined||q.keymap.KeyZ!==undefined) bad.push('SIX: an untouched pair did not take the new keys '+JSON.stringify(q));
         q=keysMig({keymap:{KeyV:'KeyK'},keymapV:2}); if(q.keymapV!==3||q.keymap.KeyV!=='KeyK'||q.keymap.KeyZ!=='KeyZ') bad.push('SIX: melee moved to K did not keep its pair '+JSON.stringify(q));
         q=keysMig({keymap:{KeyR:'KeyZ',KeyZ:'KeyR'},keymapV:2}); if(q.keymap.KeyV!=='KeyV'||q.keymap.KeyZ!=='KeyR'||q.keymap.KeyR!=='KeyZ') bad.push('SIX: reload on Z did not keep melee on V '+JSON.stringify(q));
         q=keysMig({keymap:{KeyV:'KeyJ'},keymapV:3}); if(q.keymap.KeyV!=='KeyJ'||q.keymap.KeyZ!==undefined) bad.push('SIX: a current save was changed '+JSON.stringify(q));
         q=keysMig({keymap:{KeyV:'KeyJ'}}); if(q.keymapV!==3||Object.keys(q.keymap).length) bad.push('SIX: a save from before the swap was not cleared '+JSON.stringify(q));
         if(String(applyLoadedProfile).indexOf('keysMig(P)')<0) bad.push('SIX: the loader does not run the migration');
       }
       if(typeof ARCADE_SBX==='object'&&ARCADE_SBX&&ARCADE_SBX.keymapV!==3) bad.push('SIX: the demo save is on key map version '+ARCADE_SBX.keymapV);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ bagDropSel=oDrop; }catch(_b){}
       try{ PAD.on=oPad; }catch(_p){}
       try{ keys={}; P.keymap=JSON.parse(km0); P.keymapV=kv0; KEYS.inv=null; keysInv(); keysLegendApply(); try{ saveProfile(); }catch(_s){} }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.bag.length=0; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'35.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
