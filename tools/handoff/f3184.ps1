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

if ($s.Contains("  {v:'31.84',what:")) { throw "check 31.84 is in the fixture already" }

SubRx @'
  {v:'31.83',what:
'@ @'
  {v:'31.84',what:'six party pad presets, raid-only lefty sticks, live labelled controller and pad-only layout picker',
   run:function(){
     if(typeof PAD_PRESETS==='undefined'||typeof padPresetApply!=='function') return 'six pad presets are missing';
     var bad=[], saved=P, ng=navigator.getGamepads, own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), same=NET.same, fake, g, i,j, m, name, km, f, oldSave=saveProfile, saves=0, stage='prepare', oldKeysPad=KEYS.pad;
     var oldKm=document.getElementById('keysmodal'), oldKmOn=!!(oldKm&&oldKm.classList.contains('on'));
     function at(s){ stage=s; window.__padPresetCheckStage=s; }
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function poll(down,ax){ var bt=[],i; for(i=0;i<17;i++) bt.push({pressed:down.indexOf(i)>=0,value:down.indexOf(i)>=0?1:0}); fake={connected:true,index:0,id:'Xbox controller',mapping:'standard',axes:ax||[0,0,0,0],buttons:bt}; navigator.getGamepads=function(){return [fake];}; pollPad(); }
     function press(n){ poll([]); poll([n]); poll([]); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P=JSON.parse(JSON.stringify(P)); NET.same=''; saveProfile=function(){saves++;};
       at('preset tables');
       need(PAD_PRESETS.length===6,'preset count');
       var names=['pillagers','call of duty','fortnite','arc raiders','top-down','lefty'];
       for(i=0;i<6;i++){
         need(PAD_PRESETS[i].name===names[i],'preset order '+i);
         m=PAD_PRESETS[i].map.slice().sort(function(a,b){return a-b;});
         need(m.length===16&&m.every(function(v,k){return v===k;}),'permutation '+i);
       }
       padPresetApply(1); m=padMapArr(); need(m[5]===3&&m[13]===5&&m[3]===13,'call of duty table');
       need(saves>0&&P.padPreset==='call of duty','preset not saved');
       at('deploy'); __deploy({kit:['bandage','frag','gun_shotgun'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'staging: no live raid';
       __topClear(); state='raid'; g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.trade=null; g.forgeUI=null; g.wheel=null; g.ents.length=0; g.player.roll=0; g.player.cooking=null; keys={}; mouse.down=false; PAD.prev=[]; PAD.prevMap=null; PAD.mSpent=null; PADB.waiting=null;
       g.bag=g.bag||[]; if(g.bag.indexOf('bandage')<0) g.bag.push('bandage');
       at('belt and item wheel'); padPresetApply(1); poll([]); var before=hotSel(), slots=hotbarSlots(), expected=before;
       for(i=0;i<slots.length;i++){ expected=(expected+1)%slots.length; if(!(slots[expected]&&(slots[expected].vacant||slots[expected].kind==='empty'))) break; }
       need(expected!==before,'staging: at least two occupied belt slots'); press(3); need(hotSel()===expected,'physical Y did not advance belt');
       poll([5]); need(!!g.wheel&&g.wheel.pad===1,'physical RB did not open wheel'); poll([]); g.wheel=null;
       padPresetApply(0); poll([]); before=hotSel(); press(5); need(hotSel()!==before,'default RB did not advance belt');
       at('stick movement'); var px=g.player.x, py=g.player.y, spot=null;
       for(i=-4;i<=4&&!spot;i++) for(j=-4;j<=4;j++) if(walkClearR(px+i*64,py+j*64,px+i*64,py+j*64-48,16)){spot={x:px+i*64,y:py+j*64};break;}
       need(!!spot,'staging: no clear movement lane');
       padPresetApply(5); poll([],[0,0,0,-1]); need(PAD.my<-.9&&Math.abs(PAD.mx)<.01&&!PAD.aiming,'lefty right stick does not move up');
       if(spot){ g.player.x=spot.x; g.player.y=spot.y; g.player.vx=0; g.player.vy=0; updatePlayer(.05); need(g.player.y<spot.y,'lefty right stick did not move the pillager up'); }
       poll([],[1,0,0,0]); need(PAD.aiming&&Math.abs(PAD.aimA)<.01&&PAD.mx===0,'lefty left stick does not aim');
       padPresetApply(0); poll([],[0,-1,0,0]); need(PAD.my<-.9&&!PAD.aiming,'default left stick does not move up');
       if(spot){ g.player.x=spot.x; g.player.y=spot.y; g.player.vx=0; g.player.vy=0; updatePlayer(.05); need(g.player.y<spot.y,'default left stick did not move the pillager up'); } poll([]);
       at('open layout picker'); keysOpen(true); km=document.getElementById('keysmodal'); padSetFocus(document.getElementById('padlayout'));
       at('cycle layout picker');
       for(i=1;i<=6;i++){ press(15); need(padPresetName()===names[i%6],'D-right cycle '+i); need(document.getElementById('padlayout').textContent===names[i%6],'layout row '+i); }
       press(5); need(padPresetName()==='call of duty','RB picker'); press(4); need(padPresetName()==='pillagers','LB picker');
       at('rebind navigation'); var acts=km.querySelectorAll('.keybtn'); need(acts.length===16,'rebind keycap list changed');
       for(i=0;i<acts.length;i++) need(padFocusables(km).indexOf(acts[i])>=0,'unreachable rebind '+i);
       padSetFocus(document.getElementById('padlayout'));
       for(i=0;i<acts.length;i++){ press(13); need(PAD.focus===acts[i],'D-down cannot reach rebind '+i); }
       press(13); need(PAD.focus===document.getElementById('keysreset'),'D-down cannot reach reset');
       press(13); need(PAD.focus===document.getElementById('closekeys'),'D-down cannot reach close');
       at('manual rebind'); f=km.querySelector('.keybtn[data-k="0"]'); padSetFocus(f); press(0); need(PADB.waiting===0,'pad A did not start rebind'); press(1);
       need(padPresetName()==='custom'&&document.getElementById('padlayout').textContent==='custom','rebind not custom');
       at('diagram labels'); padPresetApply(2); need(km.querySelector('[data-pad-button="11"]').textContent.indexOf('crouch')>=0,'fortnite RS label');
       for(i=0;i<16;i++) need(km.querySelector('[data-pad-button="'+i+'"]').textContent.indexOf(padPictureLabel(i))>=0,'diagram label '+i);
       padPresetApply(5); need(km.querySelector('[data-pad-stick="left"]').textContent==='aim'&&km.querySelector('[data-pad-stick="right"]').textContent==='move','lefty diagram');
       poll([],[0,-1,0,0]); need(PAD.ax[1]===-1&&PAD.ax[3]===0,'lefty menu axes changed'); poll([]);
       at('reset and back'); padSetFocus(document.getElementById('keysreset')); press(0); need(padPresetName()==='pillagers'&&P.padSticks==='','reset did not clear lefty');
       press(1); need(!km.classList.contains('on'),'B did not back out');
       at('profile isolation'); var p1=P; padPresetApply(1); var p1map=JSON.stringify(P.padmap); P=JSON.parse(JSON.stringify(P)); padPresetApply(5); var p2=P; P=p1;
       need(P.padPreset==='call of duty'&&JSON.stringify(P.padmap)===p1map&&P.padSticks!=='swap','second profile changed first'); P=p2; need(P.padSticks==='swap','second profile lost lefty');
       var legacy=JSON.parse(JSON.stringify(P)); delete legacy.padPreset; delete legacy.padSticks; legacy.padmap={};
       at('legacy profile load'); applyLoadedProfile({value:JSON.stringify(legacy)}); need(P.padPreset==='pillagers'&&P.padSticks==='','legacy profile load defaults');
       at('assertions complete');
       return bad.length?bad.join('; '):null;
     }catch(err){
       return 'pad presets at '+stage+': '+String(err&&err.stack||err).slice(0,220);
     }finally{
       try{ navigator.getGamepads=function(){return [];}; pollPad(); }catch(_p){}
       try{ if(own) navigator.getGamepads=ng; else delete navigator.getGamepads; }catch(_n){}
       PADB.waiting=null; PADB.armed=0; PADB.note=null; PAD.prev=[]; PAD.prevMap=null; PAD.mSpent=null; keys={}; mouse.down=false;
       try{ var cleanupKm=document.getElementById('keysmodal'); if(cleanupKm&&!oldKmOn) cleanupKm.classList.remove('on'); }catch(_k){}
       KEYS.pad=oldKeysPad; PAD.focus=null; PAD.focusMd=null; PAD.focusIx=0;
       try{ __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); }catch(_t){}
       NET.same=same; P=saved; saveProfile=oldSave; PADB.sig='';
       try{ padLabelsApply(); }catch(_l){}
     }
   }},
  {v:'31.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
