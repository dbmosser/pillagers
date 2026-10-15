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

if ($s.Contains("  {v:'28.10',what:")) { throw "check 28.10 is in the fixture already" }

SubRx @'
  {v:'28.09',what:
'@ @'
  {v:'28.10',what:'cloud-menus-air-strike-keys: the air strike prompts name the key and the pad buttons as set: G moved to K reads K, previous gun moved to Y reads Y + RB, and the defaults still read G and LB + RB',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof airHint!=='function'||typeof airS!=='function'||typeof pbn!=='function'||typeof keysOf!=='function'||typeof PAD==='undefined'||typeof AIR==='undefined') return 'SKIP: no arcade, pad or air strike in this fixture';
     var bad=[], g=null, p=null, A=null, oIv, own=false, labs=[], texts=[], oK=hudKey, oT=hudText;
     var hadKm=Object.prototype.hasOwnProperty.call(P,'keymap'), kKm=P.keymap, hadPm=Object.prototype.hasOwnProperty.call(P,'padmap'), kPm=P.padmap;
     var hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kNG=navigator.getGamepads, padNow=false, kPAD={on:PAD.on,brand:PAD.brand,aiming:PAD.aiming,curOwn:PAD.curOwn};
     function idle(){ var bt=[], q; for(q=0;q<17;q++) bt.push({pressed:false,value:0}); return {connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:bt,mapping:'standard'}; }
     function look(tag,pad,plate,line,hint){
       var h;
       padNow=!!pad; PAD.on=!!pad; PAD.brand='xbox';
       labs=[]; A.m=AIR.need; A.rdy=1; A.aim=0; __frame(0.016); PAD.on=!!pad;
       if(labs.indexOf(plate)<0) bad.push(tag+': the ready plate says '+(labs.join(',')||'nothing')+', not '+plate);
       texts=[]; A.m=AIR.need; A.rdy=1; A.aim=1; __frame(0.016); PAD.on=!!pad;
       if(!texts.some(function(s){ return s.indexOf(line+' CANCEL')>=0; })) bad.push(tag+': the aim line says '+(texts.filter(function(s){ return (/CANCEL/).test(s); }).join(',')||'nothing')+', not '+line+' CANCEL');
       A.aim=0; h=airHint();
       if(h!==hint) bad.push(tag+': AIR STRIKE READY says '+h+', not '+hint);
     }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99; keys={}; mouse.down=false; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.wheel=null;
       A=airS();
       hudKey=function(l){ labs.push(String(l)); return oK.apply(this,arguments); };
       hudText=function(s){ texts.push(String(s)); return oT.apply(this,arguments); };
       own=true;
       navigator.getGamepads=function(){ return padNow?[idle()]:[]; };
       P.keymap={}; P.padmap={}; KEYS.inv=null;
       look('ONE keyboard as shipped',false,'G',' G','PRESS G');
       P.keymap={KeyG:'KeyK'}; KEYS.inv=null;
       look('TWO keyboard with G on K',false,'K',' K','PRESS K');
       P.keymap={}; KEYS.inv=null;
       look('THREE pad as shipped',true,'LB+RB',' LB + RB','LB + RB');
       P.padmap={4:3,3:4};
       look('FOUR pad with previous gun on Y',true,'Y+RB',' Y + RB','Y + RB');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own){ hudKey=oK; hudText=oT; }
       try{ if(hadKm) P.keymap=kKm; else delete P.keymap; if(hadPm) P.padmap=kPm; else delete P.padmap; KEYS.inv=null; keysInv(); }catch(_k){}
       try{ if(hadOwn) navigator.getGamepads=kNG; else delete navigator.getGamepads; }catch(_n){}
       try{ PAD.prev=[]; PAD.airChord=0; PAD.lbAt=null; PAD.rbAt=null; PAD.lbHeld=0; PAD.rbHeld=0; PAD.on=kPAD.on; PAD.brand=kPAD.brand; PAD.aiming=kPAD.aiming; PAD.curOwn=kPAD.curOwn; if(typeof padRelease==='function') padRelease(); }catch(_p){}
       try{ if(A){ A.aim=0; } }catch(_a){}
       keys={}; mouse.down=false;
       try{ if(p){ p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'28.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
