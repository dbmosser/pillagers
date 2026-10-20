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

if ($s.Contains("  {v:'32.82',what:")) { throw "check 32.82 is in the fixture already" }

SubRx @'
  {v:'32.81',what:
'@ @'
  {v:'32.82',what:'an online invite code keeps its case through the host, the shown box, the copy, the paste box and the join read, the paste box names PTY1o as it looks, and a pad reaches the armour plate and the air strike on all six layouts',
   run:function(){
     var NG=navigator.getGamepads, own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), PK=Object.assign({},PAD), ns=NET.same, nowFn=netPadNow, pm=P.padmap, pp=P.padPreset, ps=P.padSticks;
     var nr=NET.role, nc=NET.code, nrp=NET.reply, nst=NET.status, ner=NET.err, nroster=NET.roster, cbD=Object.getOwnPropertyDescriptor(navigator,'clipboard'), pad, clock=100, g, p, ix, bad=[], code, d, parts, copied=null;
     function poll(down,axes){ var b=[], i; for(i=0;i<17;i++) b.push({pressed:down.indexOf(i)>=0,value:down.indexOf(i)>=0?1:0}); pad={connected:true,index:0,id:'Xbox check',mapping:'standard',buttons:b,axes:axes||[0,0,0,0]}; clock+=0.02; pollPad(); }
     try{
       // ONE: the invite code, from the host to the join read
       d={type:'offer',sdp:'v=0\r\no=- 4611731400430051336 2 IN IP4 127.0.0.1\r\nm=application 9 UDP/DTLS/SCTP webrtc-datachannel\r\na=ice-ufrag:AbCdEfGh\r\na=ice-pwd:QrStUvWxYz0123456789AB\r\na=fingerprint:sha-256 AA:BB:CC:DD:EE:FF:00:11\r\n'};
       code=sdpPackPlain(d);
       parts=netCodeParts(code);
       if(!parts||parts.type!=='offer'||!/[A-Z]/.test(parts.body)) return 'ONE: the test invite code is not mixed case or is not read: '+code.slice(0,12);
       if(code.indexOf('PTY1op')!==0) return 'ONE: the host code does not start PTY1op: '+code.slice(0,8);
       NET.role='host'; NET.code=code; NET.reply=''; NET.status=''; NET.err=''; NET.roster=NET.roster||[];
       renderParty();
       var shown=document.getElementById('partycode');
       txDom(document.body);
       if(!shown||shown.value!==code) return 'TWO: the shown invite code changed: '+(shown&&shown.value.slice(0,12));
       try{ Object.defineProperty(navigator,'clipboard',{configurable:true,value:{writeText:function(t){ copied=t; return Promise.resolve(); }}}); }catch(_c){}
       netCopy();
       if(copied!==code) return 'THREE: the copy did not hand over the exact code: '+String(copied).slice(0,12);
       var pin=document.getElementById('partyin');
       pin.value=copied; txDom(document.body);
       if(pin.value!==code) return 'FOUR: the paste box changed the code';
       var back=sdpUnpackPlain(pin.value);
       if(!back||back.type!=='offer'||back.sdp!==d.sdp) return 'FIVE: the join read did not get the host offer back';
       if(sdpUnpackPlain(code.toLowerCase())) return 'FIVE: a lower case code reads, so this guard proves nothing';
       var ph=pin.getAttribute('placeholder')||'', ph2=(document.getElementById('partyreplyin').getAttribute('placeholder')||'');
       if(ph.indexOf('PTY1o')<0) return 'SIX: the paste box placeholder does not name the code as it looks: '+ph;
       if(ph2.indexOf('PTY1a')<0) return 'SIX: the reply box placeholder does not name the code as it looks: '+ph2;
       if(ncFix('Start with PTY1o. No CAPS here')!=='start with PTY1o. no caps here') return 'SIX: the tag exemption lets other words keep capitals: '+ncFix('Start with PTY1o. No CAPS here');
       // SEVEN: a pad, on every layout, uses an armour plate and calls an air strike
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); NET.same=null;
       if(ARCADE.on) return 'SEVEN: the arcade is on after __topClear'; if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SEVEN: arcadeDeploy built no raid'; g=__state(); g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.trade=null; g.forgeUI=null; g.wheel=null;
       p=g.player; p.iv=99; p.downed=false; p.roll=0; g.ents.length=0;
       navigator.getGamepads=function(){ return [pad]; }; netPadNow=function(){ return clock; };
       PAD.announced=true;
       try{ if(typeof easyLive==='function'&&easyLive()) easyAnswer(false); }catch(_ez){}   // the easy mode question takes the first A press for yes: not what this tests
       if(!flowOn()) return 'SEVEN: the raid flow is off, so no air strike can be tested';
       for(ix=0;ix<PAD_PRESETS.length;ix++){
         var nm=PAD_PRESETS[ix].name, M, ax, at;
         padPresetApply(ix); M=padMapArr(); PAD.prev=[]; poll([]);
         // the armour plate: the belt is guns only, so the item wheel is the route. Hold the wheel button, push the aim stick down
         // (the plate is the bottom segment), let go to take it out, then pull the trigger to slot it.
         g.bag=['plate']; p.armor=0; p.prepA=null; p.prep=null; p.hand=null; G.wheel=null; p.fired=false; mouse.down=false; p.trigYield=0;
         ax=(PAD_PRESETS[ix].sticks==='swap')?[0,1,0,0]:[0,0,0,1];
         poll([M[13]],ax); if(!g.wheel) bad.push(nm+': the wheel button did not open the item wheel');
         else { wheelTick(0.05); poll([M[13]],ax); wheelTick(0.05);
           if(g.wheel.list[g.wheel.sel]&&g.wheel.list[g.wheel.sel].k!=='plate') bad.push(nm+': the aim stick down picked '+g.wheel.list[g.wheel.sel].k+', not the plate');
           poll([],ax); }
         if(!p.hand||p.hand.k!=='plate') bad.push(nm+': letting go of the wheel button did not take the plate out (hand '+(p.hand&&p.hand.k)+')');
         else { poll([]); __sim(0.2); __sim(0.2); poll([M[7]]); __sim(0.05); __sim(0.05); poll([]); __sim(0.05);
           if(!p.prepA||G.bag.indexOf('plate')>=0) bad.push(nm+': the trigger with the plate out did not start slotting it'); }
         p.prepA=null; p.hand=null; g.wheel=null; mouse.down=false; p.fired=false; PAD.prev=[]; poll([]);
         // the air strike: both bumpers arm it, the trigger calls it
         at=airS(); at.m=AIR.need; at.rdy=1; at.aim=0; at.aimT=0; at.sk=[]; at.used=0; PAD.lbAt=null; PAD.rbAt=null; PAD.airChord=0;
         poll([M[4],M[5]]); var dbg='after1 aim'+at.aim+' chord'+PAD.airChord+' on'+PAD.on+' map'+M.join('.')+' modal'+(padOpenModal()&&padOpenModal().id)+' mSp'+JSON.stringify(PAD.mSpent)+' lb'+PAD.lbAt+' rb'+PAD.rbAt+' prev'+JSON.stringify(PAD.prev); poll([M[4],M[5]]); poll([]);
         if(!at.aim) { bad.push(nm+': both bumpers did not arm the air strike ('+dbg+' flow'+flowOn()+' wheel'+!!g.wheel+' cook'+p.cooking+' hand'+!!p.hand+' bag'+g.bagOpen+' map'+g.mapOpen+' down'+p.downed+' paused'+g.paused+' ready'+airReady()+')'); }
         else { flowTick(0.2); poll([M[7]]); flowTick(0.1); flowTick(0.1); poll([]);
           if(at.used!==1||!at.sk.length) bad.push(nm+': the trigger did not call the air strike (used '+at.used+')'); }
         at.aim=0; at.sk=[]; mouse.down=false; poll([]);
       }
       if(bad.length) return bad.join('; ');
       return null;
     }finally{
       NET.same=ns; netPadNow=nowFn; P.padmap=pm; P.padPreset=pp; P.padSticks=ps;
       NET.role=nr; NET.code=nc; NET.reply=nrp; NET.status=nst; NET.err=ner; NET.roster=nroster; try{ renderParty(); }catch(_r){}
       try{ if(cbD) Object.defineProperty(navigator,'clipboard',cbD); else delete navigator.clipboard; }catch(_cd){}
       try{ document.getElementById('partyin').value=''; }catch(_pi){}
       try{padRelease(); __endRaid('abandon');}catch(e){} __topClear(); try{ __cleanProfile(); }catch(_cp){}
       if(own) navigator.getGamepads=NG; else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];}); Object.assign(PAD,PK); PADB.sig=''; try{ padLabelsApply(); }catch(_pl){}
     }
   }},
  {v:'32.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
