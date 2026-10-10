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

if ($s.Contains("  {v:'22.19',what:")) { throw "check 22.19 is in the fixture already" }

SubRx @'
  {v:'22.18',what:
'@ @'
  {v:'22.19',what:'on the Undercroft floor the controller Y that takes a trade offer is spent on it: the station Y key (PARTY, HIRE, RACKS) is not held until Y is let go, and Y with no offer still works the station',
   run:function(){
     if(typeof pollPad!=='function'||typeof netHubGiftKey!=='function'||typeof netGiftSend!=='function'||typeof padOpenModal!=='function'||typeof PAD==='undefined'||typeof NET!=='object'||!NET) return 'SKIP: no floor controller here';
     var NK={}, k, NGA=navigator.getGamepads, padK={}, pk, k0=keys, st0=state, g0=G, oGS=netGiftSend, oS2=say2, sent=[], dnY=false, none=false, bad=[], m0={x:mouse.x,y:mouse.y,down:mouse.down,init:mouse.init};
     function pad(){ if(none) return []; var b=[],n; for(n=0;n<17;n++) b.push({pressed:(n===3&&dnY),value:(n===3&&dnY)?1:0,touched:(n===3&&dnY)}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function poll(y){ dnY=!!y; pollPad(); }
     for(k in NET) NK[k]=NET[k];
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     padK.prev=(PAD.prev||[]).slice(); if(PAD.held){ padK.held={}; for(pk in PAD.held) padK.held[pk]=PAD.held[pk]; }
     try{
       __topClear(); __runPrep();
       if(typeof ATT!=='undefined'&&ATT&&ATT.on) return 'SKIP: the attract clip is playing';
       G=null; state='hub'; keys={};
       if(padOpenModal()) return 'SKIP: staging: a window is open over the floor';
       netGiftSend=function(s,m){ sent.push(m); return true; }; say2=function(){};
       NET.same=''; NET.hg={};
       PAD.announced=true; PAD.prev=[]; PAD.held={}; PAD.yGift=0;
       navigator.getGamepads=pad;
       poll(false); poll(false);
       // CONTROL: Y with no offer waiting holds the station Y key, and letting go lets go of it
       poll(true);
       if(!keys['KeyF']) return 'SKIP: staging: Y on the floor with no offer did not hold the station key';
       poll(false);
       if(keys['KeyF']) return 'SKIP: staging: letting go of Y did not let go of the station key';
       // An offer is waiting, and Y takes it
       NET.hg={in:{id:'zqk30',k:'bandage',from:1,t:Date.now()}};
       poll(true);
       if(!(NET.hg.in&&NET.hg.in.yes)||!sent.length) return 'SKIP: staging: Y did not take the waiting offer';
       if(keys['KeyF']) bad.push('the Y that took the offer also held the station Y key, so PARTY, HIRE or RACKS opened over the trade');
       poll(true);
       if(keys['KeyF']) bad.push('Y still held after taking the offer held the station Y key on the next frame');
       poll(false); poll(true);
       if(!keys['KeyF']) bad.push('a fresh Y after the offer was taken did not work the station');
       poll(false);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ none=true; dnY=false; pollPad(); }catch(_p){}
       navigator.getGamepads=NGA; netGiftSend=oGS; say2=oS2;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       keys=k0||{}; state=st0; G=g0; mouse.x=m0.x; mouse.y=m0.y; mouse.down=m0.down; mouse.init=m0.init;
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
