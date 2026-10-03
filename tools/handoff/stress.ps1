param([int]$Cdp=9344,[int]$Port=8806,[string]$Ns='40,80,120',[int]$Sec=8,[double]$Throttle=0)
# A BUSY SCREEN (his worry 2026-10-02): N extra bodies chasing the player, eight rounds every third frame, every body kept alive,
# for Sec seconds; the frame interval under the live loop (median, p95, worst) and the update and draw on their own.
# One JSON line per N. Needs a headless Chrome on $Cdp (tools\cdp.ps1 -Start -Port) and a server on $Port serving tools\.
$c='C:\claudecode\dark raiders\tools\cdp.ps1'
(Invoke-RestMethod ("http://127.0.0.1:$Cdp/json")) | Where-Object { $_.type -eq 'page' -and $_.url -like "*$Port*" } | ForEach-Object { try{ Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/close/"+$_.id) | Out-Null }catch{} }
$t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Cdp/json/new?http://localhost:$Port/fixture.html"); Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/activate/"+$t.id) | Out-Null
Start-Sleep 15
foreach($N in ($Ns -split ',')){
$g=@"
(async function(){
 var N=$N, SEC=$Sec, M=window.__movers, G, p, i, e, mk, t0, last, times=[], frames=0, upd=[], drw=[], k, a, r;
 __pinDPR(1); try{ __runPrep(); }catch(e){} __deploy({kit:[],safe:null,mapIx:0,seed:4242}); G=__state(); if(!G||G.over) return 'no raid';
 p=G.player;
 for(i=0;i<N;i++){ a=i*2.399; r=180+i*5; try{ e=(i%3===0)?M.mkRaider(p.x+Math.cos(a)*r,p.y+Math.sin(a)*r,null,false):M.mkSentry(p.x+Math.cos(a)*r,p.y+Math.sin(a)*r); }catch(ex){ e=null; } if(!e) continue; e.state='chase'; e.seenYou=true; e.tx=p.x; e.ty=p.y; e.alert=4; G.ents.push(e); }
 await new Promise(function(res){ t0=performance.now(); last=t0;
   (function tick(){ var now=performance.now(), d=now-last; last=now; frames++; if(frames>10) times.push(d);
     try{ if(G.player) p=G.player; p.hp=p.maxhp||100; p.downed=0; }catch(_){}
     if(frames%3===0) for(k=0;k<8;k++) G.bullets.push({x:p.x,y:p.y,vx:Math.cos(k*0.8)*1180,vy:Math.sin(k*0.8)*1180,dmg:1,life:0.5,player:true,owner:p,tint:'#ffd48a'});
     for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(e&&e.hp<=0) e.hp=e.maxhp||100; }
     if(now-t0<SEC*1000&&!G.over) requestAnimationFrame(tick); else res(); })(); });
 for(i=0;i<40;i++){ var a0=performance.now(); try{ __ents(0.016); }catch(e1){} var a1=performance.now(); try{ __frame(0.016); }catch(e2){} var a2=performance.now(); upd.push(a1-a0); drw.push(a2-a1); }
 times.sort(function(x,y){return x-y;}); upd.sort(function(x,y){return x-y;}); drw.sort(function(x,y){return x-y;});
 function q(arr,f){ return arr.length?+arr[Math.min(arr.length-1,Math.floor(arr.length*f))].toFixed(1):null; }
 var out={n:N,ents:G.ents.length,bullets:G.bullets.length,sparks:(G.sparks||[]).length,frames:times.length,over:G.over||null,ms:{med:q(times,0.5),p95:q(times,0.95),worst:q(times,1)},update:{med:q(upd,0.5),p95:q(upd,0.95)},draw:{med:q(drw,0.5),p95:q(drw,0.95)}};
 try{ __endRaid('abandon'); __topClear(); }catch(e3){}
 return JSON.stringify(out);
})()
"@
powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "$Port/fixture" -TimeoutSec 120 -Throttle $Throttle -Expr $g 2>$null
}
