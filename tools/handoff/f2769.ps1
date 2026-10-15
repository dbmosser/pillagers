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

if ($s.Contains("  {v:'27.69',what:")) { throw "check 27.69 is in the fixture already" }

SubRx @'
  {v:'27.68',what:
'@ @'
  {v:'27.69',what:'cloud-menus-pad-menu-press-spent: with CHANGE PAD BUTTONS moving fire onto A, dodge roll onto B or crouch onto MENU, the held press that shuts the pause box does nothing in the raid and the next press of that button does; with pause on B, B held in the raid opens the box once',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof pollPad!=='function'||typeof padBind!=='function'||typeof togglePauseBox!=='function'||typeof padMapArr!=='function') return 'SKIP: this fixture cannot drive the pause box with a pad';
     var bad=[], g, pk, v, pad0={}, had=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), og=navigator.getGamepads, on0=PAD.on, ru0=(typeof RUMBLE!=='undefined'&&RUMBLE)?RUMBLE.usedAt:undefined, pm0=JSON.stringify(P.padmap||{}), pv0=P.padmapV, rk0=raidKey, pbn0=(typeof PADB!=='undefined'&&PADB)?PADB.note:undefined, rec=[], rb=document.getElementById('resumebtn'), pb=document.getElementById('pausebox'), gp;
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)){ v=PAD[pk]; pad0[pk]=Array.isArray(v)?v.slice():((v&&typeof v==='object'&&Object.getPrototypeOf(v)===Object.prototype)?JSON.parse(JSON.stringify(v)):v); }
     if(!rb||!pb) return 'SKIP: no pause box';
     function mk(down){ var bt=[], q, d; for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bt.push({pressed:d,touched:d,value:d?1:0}); } return {connected:true,id:'Xbox Wireless Controller (STANDARD GAMEPAD)',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bt}; }
     function poll(down){ gp=mk(down); navigator.getGamepads=function(){ return [gp,null,null,null]; }; pollPad(); }
     function acted(code){ return code==='fire'?!!mouse.down:(rec.indexOf(code)>=0); }
     function trial(tag,bind,btn,code,word){
       var i, did=false;
       P.padmap={}; P.padmapV=1; padLabelsApply();
       if(bind){ padBind(bind[0],bind[1]); if(padMapArr()[bind[0]]!==bind[1]){ bad.push(tag+': staging: the bind did not take'); return; } }
       g.paused=false; mouse.down=false; poll([]); poll([]);
       togglePauseBox(true);
       if(!pauseOpen){ bad.push(tag+': staging: the pause box did not open'); return; }
       padSetFocus(rb); PAD.focus=rb; PAD.focusMd=pb; PAD.focusIx=padFocusables(pb).indexOf(rb);
       poll([]); rec.length=0; mouse.down=false;
       poll([btn]);
       if(pauseOpen){ bad.push(tag+': the press did not shut the pause box'); try{ togglePauseBox(false); }catch(_tq){} poll([]); return; }
       for(i=0;i<3;i++){ poll([btn]); if(acted(code)) did=true; }
       if(did) bad.push(tag+': the held press that shut the pause box went on to '+word+' in the raid');
       poll([]); poll([]); rec.length=0; mouse.down=false;
       poll([btn]); if(!acted(code)) bad.push(tag+': a fresh press after letting go did not '+word);
       poll([]); mouse.down=false;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.player.iv=99; g.player.maxhp=100000; g.player.hp=100000; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null; g.forgeUI=null; mouse.down=false;
       raidKey=function(c){ rec.push(c); };
       trial('fire on A, A on RESUME RUN',[7,0],0,'fire','fire');
       trial('dodge roll on B, B in the pause box',[0,1],1,'Space','roll');
       trial('crouch on MENU, MENU in the pause box',[1,9],9,'ControlLeft','crouch');
       trial('the standard buttons, A on RESUME RUN',null,0,'Space','roll');
       P.padmap={}; P.padmapV=1; padLabelsApply(); padBind(9,1);
       if(padMapArr()[9]!==1) bad.push('pause on B: staging: the bind did not take');
       else {
         raidKey=function(c){ rec.push(c); if(c==='KeyP') togglePauseBox(!pauseOpen); };
         g.paused=false; poll([]); poll([]); rec.length=0;
         poll([1]); poll([1]); poll([1]); poll([1]);
         if(!pauseOpen) bad.push('pause on B: B held in the raid did not leave the pause box open ('+rec.join(',')+')');
         poll([]); poll([]);
         if(pauseOpen){ poll([1]); poll([]); if(pauseOpen) bad.push('pause on B: B in the pause box did not shut it'); }
         raidKey=function(c){ rec.push(c); };
       }
       try{ togglePauseBox(false); }catch(_tz){}
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       raidKey=rk0; if(typeof PADB!=='undefined'&&PADB) PADB.note=pbn0;
       try{ togglePauseBox(false); }catch(_tp){}
       try{ navigator.getGamepads=function(){ return [null,null,null,null]; }; pollPad(); }catch(_p0){}
       if(had) navigator.getGamepads=og; else { try{ delete navigator.getGamepads; }catch(_d){} }
       for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(pad0,pk)) delete PAD[pk];
       for(pk in pad0) PAD[pk]=pad0[pk];
       if(typeof RUMBLE!=='undefined'&&RUMBLE) RUMBLE.usedAt=ru0;
       PAD.on=on0; try{ padBodyCls(); }catch(_b){} try{ padSetFocus(null); }catch(_f){} PAD.focus=null;
       P.padmap=JSON.parse(pm0); P.padmapV=pv0; try{ saveProfile(); padLabelsApply(); }catch(_pl){}
       mouse.down=false; keys['Space']=false; keys['ControlLeft']=false;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.paused=false; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
