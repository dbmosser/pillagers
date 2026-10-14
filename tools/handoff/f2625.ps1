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

if ($s.Contains("  {v:'26.25',what:")) { throw "check 26.25 is in the fixture already" }

SubRx @'
  {v:'26.24',what:
'@ @'
  {v:'26.25',what:'his order (2026-10-12, a pack-a-punch with elements) and his question (2026-10-14): at the Forge a MK II gun is offered MK III with FIRE, SHOCK, CRYO or ACID for 6000 score by key, mouse and pad; a MK III gun is at the top; too little score says NEED',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof raidKey!=='function'||typeof render2D!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, f, said=[], blips=[], realSay=say, realBlip=blip, hadCs, ex, hadOwn, realPads, held={}, cl, U, c2, b;
     function setScore(v){ if(g.arcade) ARCADE.mine=v; else { g.cs=g.cs||{s:0,k:0,streak:null,waveT:0,waveN:0}; g.cs.s=v; } }
     function getScore(){ return g.arcade?(ARCADE.mine|0):(g.cs?(g.cs.s|0):0); }
     function press(code){ raidKey(code,false,null); keys[code]=false; }
     function tick(nf){ for(var j=0;j<nf;j++) __sim(0.05); }
     function mk2(id){ return forgeApply(Object.assign({},WEAPONS[id||'rifle']),1); }
     function openAt(gun,score){ g.forgeUI=null; p.wep=gun; p.ammo=10; setScore(score); said.length=0; blips.length=0; keys.KeyE=true; tick(6); keys.KeyE=false; tick(2); }
     function pads(){ var a=[],j; for(j=0;j<17;j++) a.push({pressed:!!held[j],value:held[j]?1:0}); return [{connected:true,id:'Xbox Controller',index:0,buttons:a,axes:[0,0,0,0],mapping:'standard'}]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; f=g.forge; if(!f) return 'the raid has no Forge';
       ex=g.ents; g.ents=[]; hadCs=g.cs;
       say=function(m,k,o){ said.push(String(m)); }; blip=function(t){ blips.push(String(t)); };
       for(var kk in keys) keys[kk]=false;
       p.hp=100000; p.iv=99; p.downed=false; p.x=f.x; p.y=f.y; p.vx=0; p.vy=0; p.reloading=0; p.jam=0;
       // 1. a MK II gun with 7000: E opens four choices, 3 buys CRYO, MK III, 6000 off
       openAt(mk2(),7000);
       if(!g.forgeUI) bad.push('E at the Forge with a MK II gun and 7000 opened no panel');
       else {
         if((g.forgeUI.n|0)!==4) bad.push('the MK II panel offers '+g.forgeUI.n+' choices not 4');
         press('Digit3'); tick(2);
         if(g.forgeUI) bad.push('the panel stayed open after the element was picked');
         if(!p.wep||p.wep.fk!==2||p.wep.el!=='cryo') bad.push('key 3 did not make a MK III CRYO gun ('+(p.wep&&p.wep.fk)+','+(p.wep&&p.wep.el)+')');
         else {
           if(p.wep.tint!==ELEM.cryo.c) bad.push('the MK III tracer is not the element colour');
           if(p.wep.name!=='Auto Rifle MK III') bad.push('the MK III rifle is called '+p.wep.name);
         }
         if(getScore()!==1000) bad.push('the score is '+getScore()+' after a 6000 upgrade of 7000');
         if(said.indexOf('GUN UPGRADED')<0) bad.push('no GUN UPGRADED line');
         if(blips.indexOf('forge')<0||blips.indexOf('elCryo')<0) bad.push('no Forge and element sound ('+blips.join(',')+')');
       }
       // 2. a MK III gun is at the top
       openAt(p.wep,9000);
       if(g.forgeUI||said.indexOf('MAX TIER')<0) bad.push('a MK III gun did not say MAX TIER ('+JSON.stringify(said.slice(0,3))+')');
       // 3. too little for the MK III
       openAt(mk2(),5000);
       if(g.forgeUI||said.indexOf('NEED $6,000')<0) bad.push('5000 for a MK III did not say NEED $6,000 ('+JSON.stringify(said.slice(0,3))+')');
       if(getScore()!==5000||p.wep.fk!==1) bad.push('too little score still changed the gun or the score');
       // 4. FIRE rounds: the fired round carries the element
       openAt(mk2('rifle'),6500); if(g.forgeUI) press('Digit1'); tick(2);
       if(!p.wep||p.wep.el!=='fire') bad.push('key 1 did not make a FIRE gun');
       else { var nb=g.bullets.length; p.ammo=10; fireWeapon(p,p.wep,p.x+100,p.y,true); var lb=g.bullets[g.bullets.length-1]; if(g.bullets.length<=nb||!lb||lb.el!=='fire') bad.push('a MK III FIRE gun fires rounds without fire ('+(lb&&lb.el)+')'); }
       // 5. the mouse: a click on the second card buys SHOCK
       openAt(mk2(),6000);
       if(g.forgeUI){
         render2D(0); U=g.forgeUI; c2=U&&U.cells&&U.cells[1];
         if(!c2||U.cells.length!==4) bad.push('the panel drew '+(U&&U.cells&&U.cells.length)+' mouse targets not 4');
         else { mouse.x=c2.x+c2.w/2; mouse.y=c2.y+c2.h/2; cv.dispatchEvent(new MouseEvent('mousedown',{button:0})); window.dispatchEvent(new MouseEvent('mouseup',{button:0})); tick(1);
           if(!p.wep||p.wep.el!=='shock') bad.push('a click on the second card did not buy SHOCK ('+(p.wep&&p.wep.el)+')'); }
       } else bad.push('the panel did not open for the mouse test');
       // 6. the pad: right, right, A picks the third card (CRYO)
       openAt(mk2(),6000);
       if(g.forgeUI){
         hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'); realPads=navigator.getGamepads;
         navigator.getGamepads=function(){ return pads(); };
         try{
           held[15]=1; pollPad(); held[15]=0; pollPad(); held[15]=1; pollPad(); held[15]=0; pollPad();
           if((g.forgeUI&&g.forgeUI.sel)!==2) bad.push('D-pad right twice did not mark the third card ('+(g.forgeUI&&g.forgeUI.sel)+')');
           held[0]=1; pollPad(); held[0]=0; pollPad();
         } finally { if(hadOwn) navigator.getGamepads=realPads; else delete navigator.getGamepads; held={}; try{ pollPad(); }catch(_p){} }
         tick(2);
         if(!p.wep||p.wep.el!=='cryo') bad.push('A on the pad did not buy the marked CRYO ('+(p.wep&&p.wep.el)+')');
       } else bad.push('the panel did not open for the pad test');
       // 7. ESC closes the element panel with no charge
       openAt(mk2(),8000);
       if(g.forgeUI){ press('Escape'); tick(1); if(g.forgeUI||getScore()!==8000||p.wep.fk!==1) bad.push('ESC did not close the element panel with no charge'); } else bad.push('the panel did not open for the ESC test');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=realSay; blip=realBlip;
       try{ if(typeof PAD==='object'&&PAD){ PAD.on=false; PAD.prev=[]; PAD.held={}; } }catch(_pd){}
       for(var k2 in keys) keys[k2]=false;
       try{ if(g){ if(ex) g.ents=ex; g.forgeUI=null; g.cs=hadCs; } var g2=__state(); if(g2&&!g2.over){ g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
