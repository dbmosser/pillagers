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

if ($s.Contains("  {v:'26.53',what:")) { throw "check 26.53 is in the fixture already" }

SubRx @'
  {v:'26.52',what:
'@ @'
  {v:'26.53',what:'padbind, his order 2026-10-14: CONTROLLER REBINDING. CONTROLLER has CHANGE PAD BUTTONS, which opens the Keys window in pad mode: sixteen actions each with the button it is on (his 2026-09-27 layout by default), REBIND reads PRESS A BUTTON and the next press binds (a button still held from the click is waited out), a clash swaps the two actions, RESET TO DEFAULTS restores the layout; in a raid the new button fires the action and the old one no longer does, the tap and the hold paths both follow, the prompts and both legends name the new button, it is saved in the profile, and the menus and the Undercroft keep the standard buttons',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__opts)) return 'SKIP: this fixture cannot deploy';
     if(typeof renderSettings!=='function'||typeof pollPad!=='function'||typeof PAD==='undefined'||typeof keysOpen!=='function'||typeof LEGEND_PAD==='undefined') return 'SKIP: no pad code here';
     if(typeof padBind!=='function'||typeof padLogical!=='function'||typeof padMapArr!=='function'||typeof padReset!=='function') return 'there is no way to rebind the controller: no CHANGE PAD BUTTONS';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), km=document.getElementById('keysmodal'), kmWas=km&&km.classList.contains('on'),
         kPM=JSON.stringify(P.padmap||{}), kPV=P.padmapV, hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kNG=navigator.getGamepads, kRK=raidKey, rec=[], gp, i, el, h, LEG0,
         kPAD={on:PAD.on,aimA:PAD.aimA,reach:PAD.reach,aiming:PAD.aiming,curOwn:PAD.curOwn,brand:PAD.brand}, kPB={waiting:PADB.waiting,armed:PADB.armed,note:PADB.note}, kKP=KEYS.pad;
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function mkpad(down){ var bt=[], q, d; for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bt.push({pressed:d,value:d?1:0}); } return {connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:bt,mapping:'standard'}; }
     function poll(down){ gp=mkpad(down); navigator.getGamepads=function(){ return [gp]; }; pollPad(); }
     function legRow(sec,txt){ var a, b; for(a=0;a<LEGEND_PAD.length;a++) if(LEGEND_PAD[a][0]===sec) for(b=0;b<LEGEND_PAD[a][1].length;b++) if(LEGEND_PAD[a][1][b][1]===txt) return LEGEND_PAD[a][1][b][0]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null; g.forgeUI=null; keys={}; mouse.down=false;
       raidKey=function(c){ rec.push(c); };
       P.padmap={}; PADB.waiting=null; padLabelsApply(); LEG0=JSON.stringify([LEGEND_PAD,LEGEND_MINI_PAD]);
       // ONE: the window, opened from the CONTROLLER section, in pad mode
       P.gameOpts={}; __opts.apply(); md.classList.add('on'); renderSettings();
       el=document.getElementById('set_pad'); if(!el) bad.push('ONE: Settings has no CHANGE PAD BUTTONS button');
       else {
         if(secOf('set_pad')!=='CONTROLLER') bad.push('ONE: the pad button sits under '+secOf('set_pad')+', not CONTROLLER');
         if(el.textContent!=='CHANGE PAD BUTTONS') bad.push('ONE: the button reads '+el.textContent);
         el.click(); km=document.getElementById('keysmodal');
         if(!km||!km.classList.contains('on')||!KEYS.pad) bad.push('ONE: the button did not open the window in pad mode');
         else {
           h=km.querySelector('h3'); if(!h||!/pad/i.test(h.textContent)) bad.push('ONE: the window is called '+(h?h.textContent:'nothing'));
           if(document.querySelectorAll('#keyslist .rebind').length!==16||document.querySelectorAll('#keyslist .keybtn').length!==16) bad.push('ONE: the pad window has '+document.querySelectorAll('#keyslist .rebind').length+' rebind controls, not 16');
           for(i=0;i<16;i++) if(!document.querySelector('#keyslist .rebind[data-k="'+i+'"]')) bad.push('ONE: no row for action '+i);
           if(!document.getElementById('keysreset')) bad.push('ONE: no RESET TO DEFAULTS');
           h=(document.getElementById('keyslist').textContent||'');
           if(h.indexOf('MOVE')<0||h.indexOf('FIGHT')<0||h.indexOf('GEAR')<0||h.indexOf('L STICK')<0) bad.push('ONE: the pad window lacks its sections and locked sticks');
           el=document.querySelector('#keyslist .keybtn[data-k="7"]'); if(!el||el.textContent!=='RT') bad.push('ONE: fire reads '+(el?el.textContent:'nothing')+' by default, not RT');
           el=document.querySelector('#keyslist .keybtn[data-k="0"]'); if(!el||el.textContent!=='A') bad.push('ONE: dodge roll reads '+(el?el.textContent:'nothing')+' by default, not A');
         }
         km=document.getElementById('keysmodal'); if(km) km.classList.remove('on'); PADB.waiting=null;
       }
       md.classList.remove('on');
       // TWO: the default layout fires on RT and the prompts say so
       poll([]); poll([7]); if(!mouse.down) bad.push('TWO: control: RT did not fire'); poll([]); if(mouse.down) bad.push('TWO: control: RT let go still fires');
       if(keyLabel('KeyG','?')!=='RT'||keyLabel('Space','?')!=='A'||keyLabel('ControlLeft','?')!=='B') bad.push('TWO: control: the default prompts read '+keyLabel('KeyG','?')+' '+keyLabel('Space','?')+' '+keyLabel('ControlLeft','?'));
       // THREE: bind fire onto Y: Y fires, RT does not, Y and RT swap, the prompts and legends follow
       if(!padBind(7,3)) bad.push('THREE: fire would not bind to Y');
       if(padMapArr()[7]!==3||padMapArr()[3]!==7) bad.push('THREE: the clash did not swap fire and the Y action ('+padMapArr()[7]+','+padMapArr()[3]+')');
       poll([]); poll([3]); if(!mouse.down) bad.push('THREE: Y did not fire after the bind'); poll([]); if(mouse.down) bad.push('THREE: Y let go still fires');
       poll([7]); if(mouse.down) bad.push('THREE: RT still fires after fire moved to Y'); poll([]);
       if(keyLabel('KeyG','?')!=='Y') bad.push('THREE: the fire prompt reads '+keyLabel('KeyG','?')+', not Y');
       if(legRow('FIGHT','fire / use selected')!=='Y') bad.push('THREE: the full pad legend names '+legRow('FIGHT','fire / use selected')+' for fire');
       if(JSON.stringify(LEGEND_MINI_PAD).indexOf('["Y","fire / use"]')<0) bad.push('THREE: the small pad legend does not name Y for fire');
       if(PADLABEL_DEF.KeyG!=='RT') bad.push('THREE: the standard names changed');
       // FOUR: the tap path follows: roll onto B, crouch gets A
       padReset(); padBind(0,1); rec.length=0; poll([]); poll([1]); if(rec.indexOf('Space')<0) bad.push('FOUR: B did not roll after the bind ('+rec.join(',')+')');
       poll([]); rec.length=0; poll([0]); if(rec.indexOf('ControlLeft')<0||rec.indexOf('Space')>=0) bad.push('FOUR: A after the swap did '+rec.join(',')+', not crouch'); poll([]);
       if(keyLabel('Space','?')!=='B'||keyLabel('ControlLeft','?')!=='A') bad.push('FOUR: the roll and crouch prompts read '+keyLabel('Space','?')+' and '+keyLabel('ControlLeft','?'));
       // FIVE: the window: REBIND, a held button waited out, the next press binds, the held press does nothing else
       padReset(); keysOpen(true); km=document.getElementById('keysmodal'); el=document.querySelector('#keyslist .rebind[data-k="5"]');
       if(!el) bad.push('FIVE: no REBIND for the next gun action');
       else {
         el.click(); if(PADB.waiting!==5) bad.push('FIVE: REBIND did not wait');
         if(!/PRESS A BUTTON/.test((document.querySelector('#keyslist .keybtn[data-k="5"]')||{}).textContent||'')) bad.push('FIVE: the row does not read PRESS A BUTTON');
         rec.length=0; poll([3]); if(PADB.waiting!==5||padMapArr()[5]!==5) bad.push('FIVE: a button held from the click bound before it was let go');
         poll([]); poll([2]);
         if(padMapArr()[5]!==2||padMapArr()[2]!==5) bad.push('FIVE: the press did not bind and swap ('+padMapArr()[5]+','+padMapArr()[2]+')');
         if(PADB.waiting!==null) bad.push('FIVE: still waiting after the press');
         if(rec.length) bad.push('FIVE: the press that bound also acted ('+rec.join(',')+')');
         if(!PADB.note||PADB.note.t!=='clash') bad.push('FIVE: the clash was not reported');
         el=document.querySelector('#keyslist .keybtn[data-k="5"]'); if(!el||el.textContent!=='X') bad.push('FIVE: the row reads '+(el?el.textContent:'nothing')+' after the bind');
         poll([]);
       }
       if(km) km.classList.remove('on'); PADB.waiting=null;
       // SIX: saved, reset
       if(!P.padmap||P.padmap[5]!==2) bad.push('SIX: the bind is not in the profile ('+JSON.stringify(P.padmap)+')');
       if(JSON.parse(JSON.stringify(P)).padmap[5]!==2) bad.push('SIX: the profile does not carry it');
       padReset(); if(Object.keys(P.padmap).length) bad.push('SIX: RESET left '+JSON.stringify(P.padmap));
       if(keyLabel('KeyG','?')!=='RT'||JSON.stringify([LEGEND_PAD,LEGEND_MINI_PAD])!==LEG0) bad.push('SIX: RESET did not give back the standard prompts and legends');
       poll([]); poll([7]); if(!mouse.down) bad.push('SIX: RT does not fire after the reset'); poll([]);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ raidKey=kRK; if(hadOwn) navigator.getGamepads=kNG; else delete navigator.getGamepads; }catch(_n){}
       try{ P.padmap=JSON.parse(kPM); if(kPV===undefined) delete P.padmapV; else P.padmapV=kPV; padLabelsApply(); }catch(_p){}
       try{ var km2=document.getElementById('keysmodal'); if(km2&&!kmWas) km2.classList.remove('on'); KEYS.pad=kKP; PADB.waiting=kPB.waiting; PADB.armed=kPB.armed; PADB.note=kPB.note; }catch(_k){}
       try{ pollPad(); PAD.on=kPAD.on; PAD.aimA=kPAD.aimA; PAD.reach=kPAD.reach; PAD.aiming=kPAD.aiming; PAD.curOwn=kPAD.curOwn; PAD.brand=kPAD.brand; PAD.prev=[]; PAD.announced=false; mouse.down=false; keys={}; }catch(_q){}
       try{ P.gameOpts=P.gameOpts||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
