param([int]$Cdp=9344,[int]$Port=8806,[int]$Raids=30,[int]$Sec=6)
# MEMORY OVER A LONG SESSION (2026-10-02): Raids raids back to back under the live loop, Sec seconds each, the JS heap sampled
# after every raid. A heap whose floor keeps climbing is a leak. One JSON line: the samples, first, last and the floor of the
# last five against the floor of the first five.
$c='C:\claudecode\dark raiders\tools\cdp.ps1'
(Invoke-RestMethod ("http://127.0.0.1:$Cdp/json")) | Where-Object { $_.type -eq 'page' -and $_.url -like "*$Port*" } | ForEach-Object { try{ Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/close/"+$_.id) | Out-Null }catch{} }
$t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Cdp/json/new?http://localhost:$Port/fixture.html"); Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/activate/"+$t.id) | Out-Null
Start-Sleep 15
$g=@"
(async function(){
 var R=$Raids, SEC=$Sec, s, heap=[], G, p, errs=[], on=function(e){ errs.push(String(e.message||e).slice(0,100)); };
 window.addEventListener('error',on); __pinDPR(1);
 function mb(){ return performance.memory?Math.round(performance.memory.usedJSHeapSize/1048576):-1; }
 for(s=0;s<R;s++){
   try{ __runPrep(); }catch(e){} try{ __deploy({kit:[],safe:null,mapIx:s%2,seed:3000+s*101}); }catch(e){ errs.push('deploy '+s+': '+e.message); continue; }
   G=__state(); if(!G||G.over) continue; p=G.player;
   await new Promise(function(res){ var t0=performance.now(); (function tick(){ try{ if(G.player) p=G.player; p.hp=p.maxhp||100; p.downed=0; }catch(_){} if(performance.now()-t0<SEC*1000&&!G.over) requestAnimationFrame(tick); else res(); })(); });
   try{ __endRaid('abandon'); __topClear(); }catch(e){}
   heap.push(mb());
 }
 window.removeEventListener('error',on);
 function mn(a){ return a.length?Math.min.apply(null,a):null; }
 return JSON.stringify({raids:heap.length,heapMB:heap,first:heap[0],last:heap[heap.length-1],floorFirst5:mn(heap.slice(0,5)),floorLast5:mn(heap.slice(-5)),errs:errs.slice(0,5)});
})()
"@
powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "$Port/fixture" -TimeoutSec ($Raids*($Sec+8)+60) -Expr $g 2>$null
