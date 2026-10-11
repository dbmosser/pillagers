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

if ($s.Contains("  {v:'23.46',what:")) { throw "check 23.46 is in the fixture already" }

SubRx @'
  {v:'23.45',what:
'@ @'
  {v:'23.46',what:'arcade23, his yes 2026-10-11: one-button quick heal in the arcade, with a Bandage carried and hp 40 G and pad D-DOWN start the heal wind-up without the belt, a Bandage above 85 is refused, a held D-DOWN heals once, the controls card names G and D-DOWN, and in a normal raid G still uses the belt and D-DOWN starts no heal',
   run:function(){
     var bad=[], g=null, g2=null, p, rows, nUH=0, realUH=useHot, ownUH=false, down13=false, padK={}, pk, ownPad=false,
         NG=navigator.getGamepads, ownNG=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), nB='band'+'age';
     function kd(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true})); }
     function pad(){ var b=[], q; for(q=0;q<17;q++) b.push({pressed:(q===13&&down13),value:(q===13&&down13)?1:0,touched:false}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function stage(gg,hp){ var pl=gg.player; pl.hp=hp; pl.healQ=0; pl.healRate=0; pl.healCap=undefined; pl.healLo=undefined; pl.healHi=0; pl.prep=null; gg.bag.length=0; gg.bag.push(nB); keys={}; }
     function stubPad(){ if(ownPad) return; for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
       padK.prev=(PAD.prev||[]).slice(); if(PAD.held){ padK.held={}; for(pk in PAD.held) padK.held[pk]=PAD.held[pk]; }
       ownPad=true; PAD.announced=true; PAD.prev=[]; PAD.held={}; navigator.getGamepads=pad; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(typeof arcadeQuickHeal!=='function') return 'no arcadeQuickHeal in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(typeof keysOf==='function'&&keysOf('KeyG')!=='KeyG') return 'SKIP: G is rebound in the fixture profile';
       if(!ITEMS[nB]) return 'SKIP: no Bandage item';
       if(__state()&&!__state().over) __endRaid('abandon');
       useHot=function(){ nUH++; return realUH.apply(this,arguments); }; ownUH=true;
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return 'SKIP: arcadeDeploy built no arcade raid';
       try{ attStop(); }catch(_as){}
       g=__state(); p=g.player; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!p||p.downed||p.dying||p.specOut) return 'SKIP: the arcade player is not standing';
       rows=arcadeCardRows();
       if(!rows||!rows[6]||rows[6][0]!=='HEAL') bad.push('the controls card has no HEAL row 7');
       else { if(rows[6][1]!==keyName(keysOf('KeyG'))) bad.push('the HEAL row keyboard label is '+rows[6][1]);
         if(rows[6][2].indexOf('D-DOWN')<0) bad.push('the HEAL row pad label is '+rows[6][2]); }
       // G on the keyboard, hp 40 with a Bandage
       stage(g,40); nUH=0;
       kd('KeyG','g');
       if(!p.prep||p.prep.kind!=='heal'||p.prep.key!==nB) bad.push('G in the arcade did not start the Bandage wind-up ('+JSON.stringify(p.prep)+')');
       if(g.bag.indexOf(nB)>=0) bad.push('G in the arcade did not spend the Bandage');
       if(nUH) bad.push('G in the arcade also used the belt');
       // the Bandage cap: above 85 it is refused
       stage(g,90); nUH=0;
       kd('KeyG','g');
       if(p.prep) bad.push('G at hp 90 started a Bandage (they stop at 85)');
       if(g.bag.indexOf(nB)<0) bad.push('G at hp 90 spent the Bandage');
       // D-DOWN on the pad
       stage(g,40); stubPad();
       down13=false; pollPad(); down13=true; pollPad();
       if(!p.prep||p.prep.kind!=='heal'||p.prep.key!==nB) bad.push('pad D-DOWN in the arcade did not start the Bandage wind-up ('+JSON.stringify(p.prep)+')');
       stage(g,40); pollPad();
       if(p.prep) bad.push('a held D-DOWN started a second heal');
       down13=false; pollPad();
       try{ arcadeLeave(); }catch(_lv){}
       // a normal raid: G still uses the belt, D-DOWN starts no heal
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       if(arcadeQuickHeal()) bad.push('arcadeQuickHeal acted in a normal raid');
       stage(g2,40); nUH=0;
       kd('KeyG','g');
       if(!nUH) bad.push('G in a normal raid did not use the belt');
       stage(g2,40); stubPad();
       down13=false; pollPad(); down13=true; pollPad(); down13=false; pollPad();
       if(g2.player.prep) bad.push('pad D-DOWN in a normal raid started a heal');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownUH){ try{ useHot=realUH; }catch(_u){} }
       try{ if(ownNG) navigator.getGamepads=NG; else { try{ delete navigator.getGamepads; }catch(_d){} if(navigator.getGamepads!==NG) navigator.getGamepads=NG; } }catch(_n){}
       if(ownPad){
         try{ pollPad(); }catch(_p){}
         try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
