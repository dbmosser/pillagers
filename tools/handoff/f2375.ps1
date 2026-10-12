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

if ($s.Contains("  {v:'23.75',what:")) { throw "check 23.75 is in the fixture already" }

SubRx @'
  {v:'23.74',what:
'@ @'
  {v:'23.75',what:'his #6 in co-op: a Tripwire Mine of player 2 is strung for real on the host under his seat, its kill is his, and the copies come down when it goes',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netThrTake!=='function'||typeof tripArm!=='function'||typeof tickTrips!=='function'||typeof netEntsPeer!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSend=netSend, sent=[], g=null, p, e=null, ex0, ey0, eh0, i, c, r, T, mx, my, best=null, ux, uy,
         ha={state:'in',seat:0}, pa={state:'in',seat:1}, pb={state:'in',seat:2};
     function got(kk,q){ return sent.filter(function(w){ return w.m&&w.m.t==='thr'&&w.m.k===kk&&(!q||w.q===q); }); }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player;
       for(i=0;i<16&&!best;i++){
         var an=i*Math.PI/8, cx=Math.cos(an), cy=Math.sin(an), lx=p.x+cx*300, ly=p.y+cy*300;
         if(rayHitG(p.x,p.y,cx,cy,380)>=379&&rayHitG(lx,ly,-cy,cx,130)>=129&&rayHitG(lx,ly,cy,-cx,130)>=129) best={ux:cx,uy:cy};
       }
       if(!best) return 'SKIP: staging: no clear lane at the spawn';
       ux=best.ux; uy=best.uy; mx=Math.round(p.x+ux*300); my=Math.round(p.y+uy*300);
       for(i=0;i<g.ents.length;i++){ c=g.ents[i]; if(c&&c.kind==='crawler'&&c.hp>0&&!c.finished){ e=c; break; } }
       if(!e) return 'SKIP: staging: no crawler in this raid';
       ex0=e.x; ey0=e.y; eh0=e.hp;
       netSend=function(q,m){ sent.push({q:q,m:JSON.parse(JSON.stringify(m))}); return true; };
       NET.specG=null; NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[pa,pb]; NET.up=[];
       g.trips=[];
       r=netThrTake(pa,{t:'thr',k:'trip',x:mx,y:my,ax:Math.round(mx-uy*80),ay:Math.round(my+ux*80),bx:Math.round(mx+uy*80),by:Math.round(my-ux*80),id:'s1-1',s:3});
       if(r!=='thr:trip') bad.push('the host did not take the wire of player 2 ('+r+')');
       else if(g.trips.length!==1||g.trips[0].seat!==1||g.trips[0].fx) bad.push('the host did not string a real wire under seat 1 ('+JSON.stringify(g.trips)+')');
       if(!got('trip',pb).length) bad.push('the host did not pass the wire of player 2 on to the other window');
       if(got('trip',pa).length) bad.push('the host sent player 2 his own wire back');
       if(g.trips.length===1){
         sent.length=0; g.trips[0].arm=0;
         e.hp=40; e.byPlayer=false; e.bySeat=0; e.x=mx-ux*15; e.y=my-uy*15; tickTrips(0.016); e.x=mx+ux*15; e.y=my+uy*15; tickTrips(0.016);
         if(g.trips.length) bad.push('a crawler crossed the wire of player 2 on the host and it did not go off');
         else {
           if(!(e.hp<=0)) bad.push('the crawler lived');
           else if(e.byPlayer!==false||e.bySeat!==1) bad.push('the kill went to byPlayer '+e.byPlayer+' seat '+e.bySeat+', not to seat 1');
           var tg=got('tgo');
           if(!tg.length||tg[0].m.id!=='s1-1'||!tg[0].m.b) bad.push('the host did not tell the party the wire went off');
         }
       }
       sent.length=0; g.trips=[]; e.hp=eh0;
       NET.role='join'; NET.seat=1; NET.peers=[ha];
       if(!netEntsPeer()) return 'SKIP: staging: the window does not read as player 2 up top';
       r=netThrTake(ha,{t:'thr',k:'trip',x:mx,y:my,ax:Math.round(mx-uy*80),ay:Math.round(my+ux*80),bx:Math.round(mx+uy*80),by:Math.round(my-ux*80),id:'p-7'});
       if(r!=='thr:trip'||g.trips.length!==1||!g.trips[0].fx) bad.push('player 2 did not string a copy of the host wire ('+r+')');
       r=netThrTake(ha,{t:'thr',k:'tgo',x:mx,y:my,id:'p-7',b:1});
       if(r!=='thr:tgo'||g.trips.length) bad.push('player 2 kept the copy after the host said it went ('+r+')');
       g.trips=[]; sent.length=0;
       T=tripArm({sx:p.x,sy:p.y,tx:mx,ty:my});
       if(!T||!T.fx) bad.push('the wire player 2 strung is real in his own window, where the bodies are copies');
       if(!got('trip',ha).length) bad.push('a wire player 2 strung was not told to the host');
       else if(!(/^s1-/).test(got('trip',ha)[0].m.id)) bad.push('his wire id '+got('trip',ha)[0].m.id+' does not carry his seat');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       netSend=oSend;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(e){ e.x=ex0; e.y=ey0; e.hp=eh0; e.byPlayer=false; e.bySeat=0; } var g2=__state(); if(g2&&!g2.over){ g2.trips=[]; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
