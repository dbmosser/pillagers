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

if ($s.Contains("  {v:'36.88',what:")) { throw "check 36.88 is in the fixture already" }

SubRx @'
  {v:'36.87',what:
'@ @'
  {v:'36.88',what:'cw-coopsmooth, his answer 2.27 b: on the other screen a partner and a machine walking at a steady speed move a steady distance each frame (spread under 20 percent) and sit under 50 ms behind, stop without running on, and are not led into a wall',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netEntsEase!=='function'||typeof netEntsApply!=='function'||typeof netOnState!=='function'||typeof netUpTick!=='function'||typeof netEntMake!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], g, wl, wgr, o, w, i, gaps=[6,7,6,5], sink=0;
     function walk(label,put,ease,pos){
       var f, t, acc=0, gi=0, need=gaps[0], real, x, px=null, st=[], lag=0, n=0, mn=1e9, mx=0, sum=0, over=0, dt=1/60;
       put(300);
       for(f=1;f<=60*5;f++){
         t=f*dt; real=300+150*Math.min(t,3);
         acc++; if(acc>=need){ acc=0; gi++; need=gaps[gi%gaps.length]; put(real); }
         ease(dt);
         x=pos();
         if(t>=1&&t<3){ st.push(x-px); lag+=(real-x)/150; n++; }
         if(t>3) over=Math.max(over,x-750);
         px=x;
       }
       st.forEach(function(s){ mn=Math.min(mn,s); mx=Math.max(mx,s); sum+=s; });
       if(!(sum/st.length>0)) bad.push(label+' does not move');
       else if((mx-mn)/(sum/st.length)>=0.2) bad.push(label+' steps from '+mn.toFixed(2)+' to '+mx.toFixed(2)+' px a frame at a steady speed (spread '+Math.round((mx-mn)/(sum/st.length)*100)+' percent, must be under 20)');
       if(lag/n>=0.05) bad.push(label+' sits '+Math.round(lag/n*1000)+' ms behind (must be under 50)');
       if(over>=20) bad.push(label+' runs on '+Math.round(over)+' px past where it stopped');
       if(Math.abs(pos()-750)>3) bad.push(label+' rests '+Math.round(pos()-750)+' px from where it stopped');
     }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(typeof netLeadSample!=='function') bad.push('no lead is read from the last two samples');
       else{
         w=g.map.walls.filter(function(q){ return q.w>=20&&q.h>=20; })[0];
         if(w){ o={}; netLeadSample(o,w.x-12,w.y+w.h/2,w.x-27,w.y+w.h/2,0.1); if(o.nlead) bad.push('a body 12 px before a wall, walking at it, is still led into it'); }
       }
       wl=g.map.walls; wgr=g.wgrid; g.map.walls=[]; g.wgrid=null;   // a clear floor for the walk
       if(typeof netLeadSample==='function'){ o={}; netLeadSample(o,500,500,485,500,0.1); if(!o.nlead||Math.abs(o.nvx-150)>1) bad.push('a body on open ground did not get its speed read ('+o.nvx+')'); }
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0; NET.entMap={}; NET.entLast=0;
       walk('a machine on the player 2 screen',
         function(real){ netEntsApply({state:'in'},{sd:g.seed>>>0,n:NET.entLast+1,e:[[961,0,real,300,0,0,20,0]]}); },
         function(dt){ netEntsEase(dt); },
         function(){ var e=NET.entMap[961]; return e?e.x:0; });
       NET.role='host'; NET.seat=0; NET.peers=[]; NET.roster=[{seat:0,name:'a'},{seat:1,name:'b'}]; NET.up=[null,null];
       walk('the partner',
         function(real){ netOnState({state:'in',seat:1},{t:'st',k:'r',sd:g.seed,x:real,y:300,hp:100,m:1}); },
         function(dt){ netUpTick(dt); },
         function(){ return NET.up[1]?NET.up[1].x:0; });
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(wl){ g.map.walls=wl; g.wgrid=wgr; } }catch(_w){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'36.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
