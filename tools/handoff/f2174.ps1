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

if ($s.Contains("  {v:'21.74',what:")) { throw "check 21.74 is in the fixture already" }

SubRx @'
  {v:'21.73',what:
'@ @'
  {v:'21.74',what:'on a controller X at THE SEAL or at a survivor holds E, so the seal cuts and the survivor gets his item; X with nothing in reach, or beside a seal already open, still reloads; the seal prompt names the pad button',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof pollPad!=='function'||typeof drawHUD!=='function'||typeof navigator.getGamepads!=='function'||typeof PAD!=='object'||!PAD||typeof NET!=='object'||!NET) return 'SKIP: no raid or pad here';
     var NG=navigator.getGamepads, ownNG=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), NK={}, k, bad=[], g, pad=null, i, b, r, on0=PAD.on, br0=PAD.brand, an0=PAD.announced, mx0=mouse.x, my0=mouse.y, seen=[], hadT=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oFT=ctx.fillText, kb, pd;
     function mk(x){ b=[]; for(i=0;i<17;i++) b.push({pressed:(i===2&&x),value:(i===2&&x)?1:0,touched:(i===2&&x)}); return {connected:true,id:'seal check pad',index:0,mapping:'standard',timestamp:1,buttons:b,axes:[0,0,0,0]}; }
     function near(o){ g.nearContainer=null; g.nearPad=null; g.nearDown=null; g.nearDoor=null; g.nearPed=null; g.nearSeal=o.seal||null; g.nearStray=o.stray||null; }
     function xPress(o){ var res; near(o); keys={}; PAD.held={}; PAD.xWas=false; PAD.xMode=null; PAD.xAfterTrade=0; PAD.xNearN=null; pad=mk(false); pollPad(); near(o); pad=mk(true); pollPad(); res=keys['KeyE']?'E':(keys['KeyR']?'R':'nothing'); pad=mk(false); pollPad(); keys={}; return res; }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[]; NET.same=null;
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       g.player.roll=0; g.player.downed=false; g.bagOpen=false; g.mapOpen=false; g.trade=null; g.searching=null;
       navigator.getGamepads=function(){ return [pad]; };
       r=xPress({}); if(r!=='R') return 'SKIP: staging: X with nothing in reach held '+r+', not reload';
       r=xPress({seal:{x:g.player.x+20,y:g.player.y,done:0,gained:0}}); if(r!=='E') bad.push('X at the seal held '+r+', not E, so the seal never cuts');
       r=xPress({stray:{kind:'stray',found:1,hostile:false,helped:0,x:g.player.x+20,y:g.player.y}}); if(r!=='E') bad.push('X at a survivor held '+r+', not E, so he never gets his item');
       r=xPress({stray:{kind:'stray',found:1,hostile:true,helped:0,x:g.player.x+20,y:g.player.y}}); if(r!=='R') bad.push('X beside a hostile survivor held '+r+', not reload');
       r=xPress({seal:{x:g.player.x+20,y:g.player.y,done:1,gained:0}}); if(r!=='R') bad.push('X beside a seal already open held '+r+', not reload');
       near({});
       if(g.seal&&!g.seal.done){
         mouse.x=Math.round(W*0.5); mouse.y=Math.round(H*0.4);
         ctx.fillText=function(s){ seen.push(String(s)); return oFT.apply(this,arguments); };
         PAD.on=false; g.nearSeal=g.seal; seen=[]; try{ drawHUD(); }catch(_h1){}
         kb=seen.filter(function(s){ return / TO CUT THE SEAL$/.test(s); });
         PAD.on=true; PAD.brand='xbox'; g.nearSeal=g.seal; seen=[]; try{ drawHUD(); }catch(_h2){}
         pd=seen.filter(function(s){ return / TO CUT THE SEAL$/.test(s); });
         g.nearSeal=null;
         if(kb.length){
           if(keysOf('KeyE')==='KeyE'&&kb[0]!=='HOLD E TO CUT THE SEAL') bad.push('on the keyboard the seal prompt reads '+kb[0]);
           if(pd.indexOf('HOLD X TO CUT THE SEAL')<0) bad.push('on a controller the seal prompt reads '+(pd[0]||'nothing')+', not HOLD X');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(hadT) ctx.fillText=oFT; else delete ctx.fillText;
       if(ownNG) navigator.getGamepads=NG; else { try{ delete navigator.getGamepads; }catch(_d){} if(navigator.getGamepads!==NG) navigator.getGamepads=NG; }
       keys={}; try{ padRelease(); }catch(_pr){}
       PAD.on=on0; PAD.brand=br0; PAD.announced=an0; PAD.xMode=null; PAD.xWas=false; mouse.x=mx0; mouse.y=my0;
       try{ var g1=__state(); if(g1){ g1.nearSeal=null; g1.nearStray=null; } }catch(_n){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
