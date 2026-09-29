# Bot crash sweep: plays full raids with the game's own bot (__simSeedsFull) over many seeds in one headless Chrome and
# records every error with its seed. Progress is in the page title, so a busy page can still be watched.
#   powershell -File tools\handoff\botsweep.ps1 -Cdp 9336 -Port 8804 -From 5000 -N 200
# Read the result later with: cdp.ps1 -Port <Cdp> -Match botsweep... -Expr "JSON.stringify(window.__BS)"
param([int]$Cdp=9336,[int]$Port=8804,[int]$From=5000,[int]$N=200,[int]$Map=-1)
$c='C:\claudecode\dark raiders\tools\cdp.ps1'
try{ Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/version") -TimeoutSec 2 | Out-Null }catch{ powershell -NoProfile -ExecutionPolicy Bypass -File $c -Start -Port $Cdp -Profile ("$env:TEMP\pillagers-cdp"+$Cdp) | Out-Null }
(Invoke-RestMethod ("http://127.0.0.1:$Cdp/json")) | Where-Object { $_.type -eq 'page' } | ForEach-Object { try{ Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/close/"+$_.id) | Out-Null }catch{} }
$t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Cdp/json/new?http://localhost:$Port/fixture.html"); Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/activate/"+$t.id) | Out-Null
for($i=0;$i -lt 40;$i++){ Start-Sleep 1; $r=powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "$Port/fixture" -TimeoutSec 10 -Expr "String(typeof __simSeedsFull==='function')" 2>$null; if($r -eq 'true'){ break } }
$e=@"
(function(){
  var from=$From, n=$N, i=0, out={done:0,n:n,errs:[],over:{},finished:false};
  window.__BS=out;
  var P0=__P(), c0=(P0.crashes||[]).length; if($Map>=0) P0.mapIx=$Map; out.map=P0.mapIx;
  window.addEventListener('error',function(ev){ out.errs.push('window: '+String(ev.message).slice(0,200)); });
  var mc=new MessageChannel();
  mc.port1.onmessage=function(){
    for(var k=0;k<2&&i<n;k++,i++){
      var sd=from+i;
      try{ var r=__simSeedsFull([sd])[0]; out.over[r.outcome]=(out.over[r.outcome]||0)+1; }
      catch(x){ out.errs.push('seed '+sd+': '+String(x&&x.message||x).slice(0,160)+' @ '+String(x&&x.stack||'').split('\n').slice(1,3).join(' ').replace(/\s+/g,' ').slice(0,200)); }
      out.done=i+1;
    }
    document.title='botsweep '+from+' at '+out.done+'/'+n+' errs '+out.errs.length+(out.done>=n?' done':'');
    if(i<n) mc.port2.postMessage(0);
    else { var cr=(__P().crashes||[]).slice(c0); cr.forEach(function(c){ out.errs.push('saved crash: '+String(c.msg).slice(0,160)+' x'+(c.n||1)+' '+(c.where||'')); }); out.finished=true; document.title='botsweep '+from+' at '+n+'/'+n+' errs '+out.errs.length+' done'; }
  };
  mc.port2.postMessage(0);
  return 'started '+n+' raids from seed '+from;
})()
"@
powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "$Port/fixture" -TimeoutSec 60 -Expr $e 2>$null
