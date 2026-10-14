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

if ($s.Contains("  {v:'26.51',what:")) { throw "check 26.51 is in the fixture already" }

SubRx @'
  {v:'26.50',what:
'@ @'
  {v:'26.51',what:'settings10, his order 2026-10-14: CONTROLLER has STICK SENSITIVITY, STICK DEADZONE, INVERT AIM STICK and VIBRATION STRENGTH (drawn only where the browser can vibrate a pad), defaulting to what the pad always did: a stick inside the deadzone reads nothing, a sensitivity scales the travel to full, invert flips the aim stick up and down in a real poll and nothing else, and the vibration the pad is sent scales with the row',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy or reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof pollPad!=='function'||typeof padRumble!=='function'||typeof PAD==='undefined'||typeof RUMBLE==='undefined') return 'SKIP: no pad code here';
     if(typeof padDz!=='function'||typeof padSens!=='function'||typeof padInv!=='function'||typeof rumbleK!=='function') return 'Settings has no stick or vibration rows';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kS=CFG.padSens, kD=CFG.padDz, kI=CFG.padInvY, kR=CFG.rumbleK, kRu=CFG.rumble,
         kPAD={on:PAD.on,aimA:PAD.aimA,reach:PAD.reach,aiming:PAD.aiming,curOwn:PAD.curOwn}, kRG=RUMBLE.gp, kRUA=RUMBLE.usedAt, kGW=window.Gamepad, rows, rr, sn, j, rec=[], gp, a0, a1, b0, hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kNG=navigator.getGamepads, el;
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     function near(v,w){ return Math.abs(v-w)<1e-9; }
     function mkpad(ax){ var bt=[], i; for(i=0;i<17;i++) bt.push({pressed:false,value:0}); return {connected:true,id:'Xbox Wireless Controller',index:0,axes:ax,buttons:bt,mapping:'standard',vibrationActuator:{playEffect:function(t,o){ rec.push(o); return Promise.resolve(); }}}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null; keys={}; mouse.down=false;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the rows, in CONTROLLER, defaulting to what the pad did, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       [['padSens','padSens',1,[1,1.25,1.5,0.75,1]],['padDz','padDz',0.22,[0.22,0.32,0.4,0.12,0.22]],['padInvY','padInvY',0,[0,1,0]],['rumbleK','rumbleK',1,[1,1.5,0.5,1]]].forEach(function(q){
         var kk=q[0], r2=rowOf(kk), sn2, jj;
         if(!r2){ bad.push('ONE: Settings has no '+kk+' row'); return; }
         if(CFG[q[1]]!==q[2]) bad.push('ONE: a fresh profile has '+q[1]+' '+CFG[q[1]]+', not '+q[2]);
         if(gameOptLive(kk)!==r2.def) bad.push('ONE: the '+kk+' row reads CUSTOM on a fresh profile');
         if(secOf('go_'+kk)!=='CONTROLLER') bad.push('ONE: the '+kk+' row sits under '+secOf('go_'+kk)+', not CONTROLLER');
         sn2=[CFG[q[1]]]; for(jj=1;jj<q[3].length;jj++){ __opts.cycle(kk); sn2.push(CFG[q[1]]); }
         if(sn2.join(',')!==q[3].join(',')) bad.push('ONE: clicking '+kk+' steps it '+sn2.join(' > ')+', not '+q[3].join(' > '));
         if(typeof P.gameOpts[kk]!=='number') bad.push('ONE: the '+kk+' pick was not saved');
       });
       P.gameOpts={}; __opts.apply();
       // the vibration row is not drawn where the browser cannot vibrate a pad
       try{ window.Gamepad=undefined; renderSettings(); if(document.getElementById('go_rumbleK')) bad.push('ONE: the vibration row is drawn with no Gamepad vibration'); }catch(_gw){} finally{ window.Gamepad=kGW; }
       renderSettings(); if(!document.getElementById('go_rumbleK')) bad.push('ONE: the vibration row is not drawn where the browser can vibrate a pad');
       md.classList.remove('on');
       // TWO: the stick maths
       CFG.padDz=0.22; CFG.padSens=1;
       if(padAxis(0.2)!==0||!near(padAxis(0.5),(0.5-0.22)/0.78)||!near(padAxis(-1),-1)) bad.push('TWO: control: the default stick reads '+padAxis(0.2)+', '+padAxis(0.5)+', '+padAxis(-1));
       CFG.padDz=0.4; if(padAxis(0.3)!==0||!near(padAxis(0.5),(0.5-0.4)/0.6)) bad.push('TWO: a deadzone of 0.4 reads '+padAxis(0.3)+' and '+padAxis(0.5));
       CFG.padDz=0.12; if(!(padAxis(0.2)>0)) bad.push('TWO: a deadzone of 0.12 still reads a 0.2 stick as nothing');
       CFG.padDz=0.22; CFG.padSens=1.5; if(!near(padAxis(0.5),Math.min(1,1.5*(0.5-0.22)/0.78))||padAxis(1)!==1||padAxis(0.2)!==0) bad.push('TWO: a sensitivity of 1.5 reads '+padAxis(0.5));
       CFG.padSens=0.75; if(!near(padAxis(0.5),0.75*(0.5-0.22)/0.78)||!near(padAxis(1),0.75)) bad.push('TWO: a sensitivity of 0.75 reads '+padAxis(0.5)+' and '+padAxis(1));
       CFG.padSens=1;
       // THREE: a real poll: the aim stick pushed up, with and without the invert
       gp=mkpad([0,0,0,-1]); navigator.getGamepads=function(){ return [gp]; };
       CFG.padInvY=0; PAD.aimA=undefined; pollPad(); a0=PAD.aimA;
       if(!near(a0,-Math.PI/2)) bad.push('THREE: control: the aim stick up gave an aim angle of '+a0);
       CFG.padInvY=1; PAD.aimA=undefined; pollPad(); a1=PAD.aimA;
       if(!near(a1,Math.PI/2)) bad.push('THREE: INVERT AIM STICK gave an aim angle of '+a1+', not down');
       gp=mkpad([0,0,0.9,0]); navigator.getGamepads=function(){ return [gp]; }; PAD.aimA=undefined; pollPad(); b0=PAD.aimA;
       if(!near(b0,0)) bad.push('THREE: INVERT AIM STICK moved a sideways aim to '+b0);
       CFG.padInvY=0;
       // FOUR: the vibration the pad is sent
       gp=mkpad([0,0,0,0]); CFG.rumble=1; RUMBLE.gp=gp; RUMBLE.usedAt=(performance&&performance.now)?performance.now():Date.now();
       function buzz(k){ CFG.rumbleK=k; rec.length=0; RUMBLE.at=0; RUMBLE.s=0; RUMBLE.until=0; RUMBLE.usedAt=(performance&&performance.now)?performance.now():Date.now(); padRumble(0.4,200); return rec.length?rec[0].strongMagnitude:null; }
       a0=buzz(1); if(!near(a0||0,0.4)) bad.push('FOUR: control: a 0.4 buzz at STANDARD was sent as '+a0);
       a1=buzz(0.5); if(a1===null||!near(a1,0.2)) bad.push('FOUR: LIGHT sent '+a1+', not 0.2');
       b0=buzz(1.5); if(b0===null||!near(b0,0.6)) bad.push('FOUR: STRONG sent '+b0+', not 0.6');
       CFG.rumble=0; if(buzz(1)!==null) bad.push('FOUR: the vibration still reached the pad with Controller rumble off');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ window.Gamepad=kGW; if(hadOwn) navigator.getGamepads=kNG; else delete navigator.getGamepads; }catch(_n){}
       try{ CFG.padSens=kS; CFG.padDz=kD; CFG.padInvY=kI; CFG.rumbleK=kR; CFG.rumble=kRu; RUMBLE.gp=kRG; RUMBLE.usedAt=kRUA; RUMBLE.at=0; RUMBLE.s=0; RUMBLE.until=0; }catch(_c){}
       try{ pollPad(); PAD.on=kPAD.on; PAD.aimA=kPAD.aimA; PAD.reach=kPAD.reach; PAD.aiming=kPAD.aiming; PAD.curOwn=kPAD.curOwn; PAD.prev=[]; PAD.announced=false; }catch(_p){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
