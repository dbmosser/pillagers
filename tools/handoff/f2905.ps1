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

if ($s.Contains("  {v:'29.05',what:")) { throw "check 29.05 is in the fixture already" }

SubRx @'
  {v:'29.04',what:
'@ @'
  {v:'29.05',what:'cw-lanetarget: in co-op a Sentry winding up on player 2 (its target, the way it faces) draws its aim lane at player 2, not on the host who stands within the old snap cone; solo still snaps the lane onto the player',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, s=null, a, j, sx, sy, bx, by, E0=null, NK={}, k, L, aw, tgt, toMate, toHost;
     function deg(r){ return r*180/Math.PI; }
     function adiff(x,y){ var q=((x-y)%360+540)%360-180; return Math.abs(q); }
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player;
       for(j=0;j<48&&!s;j++){
         a=j/48*6.2832; sx=p.x+Math.cos(a)*220; sy=p.y+Math.sin(a)*220;
         if(!losClear(p.x,p.y,sx,sy,G.vseg)) continue;
         aw=Math.atan2(p.y-sy,p.x-sx)+30*Math.PI/180; bx=sx+Math.cos(aw)*150; by=sy+Math.sin(aw)*150;
         if(losClear(sx,sy,bx,by,G.vseg)) s=mkSentry(sx,sy);
       }
       if(!s) return 'SKIP: staging: no open ground for a sentry and a teammate';
       E0=g.ents; g.ents=[s];
       NET.on=true; NET.max=4; NET.specG=null; NET.upSeed=G.seed>>>0; NET.role='host'; NET.seat=0;
       NET.roster=[{seat:0,name:'A'},{seat:1,name:'B'}]; NET.peers=[{seat:1,state:'in'}];
       NET.up=[{seat:1,n:5,age:0,sd:G.seed>>>0,tx:bx,ty:by,tf:0,dn:0,mv:0}];
       tgt=netTargetFor(s);
       if(tgt===p) return 'SKIP: staging: the sentry does not pick player 2';
       toMate=Math.atan2(by-s.y,bx-s.x); toHost=Math.atan2(p.y-s.y,p.x-s.x);
       // ONE: co-op, the machine faces player 2, its target, mid windup: the lane is on player 2
       s.face=toMate; s.windup=0.2;
       L=telegraphLane(s);
       if(!L) bad.push('ONE: no lane during a co-op windup');
       else if(adiff(deg(Math.atan2(L.uy,L.ux)),deg(toMate))>1) bad.push('ONE: the lane points '+adiff(deg(Math.atan2(L.uy,L.ux)),deg(toMate)).toFixed(1)+' degrees off player 2, the target ('+adiff(deg(Math.atan2(L.uy,L.ux)),deg(toHost)).toFixed(1)+' off the host)');
       // TWO: co-op, the machine targets the host: the lane still snaps onto the host
       NET.up[0].tx=s.x+(s.x-p.x)*3; NET.up[0].ty=s.y+(s.y-p.y)*3;
       if(netTargetFor(s)===p){ s.face=toHost+0.4; L=telegraphLane(s); if(!L||adiff(deg(Math.atan2(L.uy,L.ux)),deg(toHost))>0.5) bad.push('TWO: the co-op lane on the host, its target, no longer snaps onto him'); }
       // FOUR: player 2's window (join): player 2 nearer than the host, the machine's target, the lane snaps onto player 2 there too
       NET.role='join'; NET.seat=1; NET.roster=[{seat:0,name:'A'},{seat:1,name:'B'}]; NET.peers=[{seat:0,state:'in'}];
       NET.up=[{seat:0,n:5,age:0,sd:G.seed>>>0,tx:s.x+(s.x-p.x)*2,ty:s.y+(s.y-p.y)*2,tf:0,dn:0,mv:0}];
       if(netTargetFor(s)===p){ s.face=toHost+0.4; s.windup=0.2; L=telegraphLane(s); if(!L||adiff(deg(Math.atan2(L.uy,L.ux)),deg(toHost))>0.5) bad.push('FOUR: on player 2 window the lane on player 2, its target, does not snap onto him'); }
       else bad.push('FOUR: staging: on player 2 window the machine did not pick player 2');
       // THREE: solo, the lane still snaps onto the player
       for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k];
       s.face=toHost+0.5; s.windup=0.2;
       L=telegraphLane(s);
       if(!L) bad.push('THREE: no lane in solo during a windup');
       else if(adiff(deg(Math.atan2(L.uy,L.ux)),deg(toHost))>0.5) bad.push('THREE: the solo lane no longer snaps onto the player');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; if(g&&E0) g.ents=E0; if(g) g.bullets.length=0; }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'29.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
