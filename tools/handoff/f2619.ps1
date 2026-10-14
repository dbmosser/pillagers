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

if ($s.Contains("  {v:'26.19',what:")) { throw "check 26.19 is in the fixture already" }

SubRx @'
  {v:'26.18',what:
'@ @'
  {v:'26.19',what:'his note: THE OVERSEER sees and shoots from 1.4 times as far as a plain Warden (868, not 620), fires at a player it sees even past its lair leash while it holds its ground and never walks off after him, sees whatever the side its sprite faces, and fires nothing through a wall or at a player behind it',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof bossTick!=='function'||typeof updateEnts!=='function'||typeof spotFree!=='function'||typeof losClear!=='function'||typeof mkWarden!=='function') return 'SKIP: no raid or no boss in this fixture';
     if(typeof NET==='object'&&NET&&NET.on) return 'SKIP: a party is live';
     var bad=[], g, p, e=null, i, E0=null, oSay=say, px0=null, py0=null, cbOff=false, pc0, L, base, W, A, B, B2, C, D, r, dir, fc, ok;
     var okPt=function(q){ return q.x>200&&q.y>200&&q.x<WORLD_W-200&&q.y<WORLD_H-200&&spotFree(g.map,q.x,q.y,24); };
     var find=function(sep,lo,hi,maxRb,seen,ks){
       var rbs=[0,250,500,750,1000], x, j, k, a, c, b, q, dl;
       for(x=0;x<rbs.length;x++){
         if(rbs[x]>maxRb) continue;
         for(j=0;j<24;j++){
           a=j*Math.PI/12; b={x:L.x+Math.cos(a)*rbs[x],y:L.y+Math.sin(a)*rbs[x]};
           if(!okPt(b)) continue;
           for(k=0;k<24;k++){
             if(ks&&ks.indexOf(k)<0) continue;
             c=k*Math.PI/12; q={x:b.x+Math.cos(c)*sep,y:b.y+Math.sin(c)*sep}; dl=Math.hypot(q.x-L.x,q.y-L.y);
             if(dl<lo||dl>hi||!okPt(q)) continue;
             if(!!losClear(b.x,b.y,q.x,q.y,g.vseg)!==seen) continue;
             return {b:b,q:q,rb:rbs[x],dl:dl,dir:c};
           }
         }
       }
       return null;
     };
     var run=function(s,face,n,alert,pin){
       var f, o={rounds:0,wind:0,maxl:0,d0:0,d1:0,seen:false,off:0};
       e.x=s.b.x; e.y=s.b.y; e.tx=e.x; e.ty=e.y; e.cd=0; e.windup=null; e.state='patrol'; e.seenYou=false; e.announced=true; e.alert=alert||0; e.overheat=0; e.blind=0; e.stunT=0; e.frozenT=0; e.path=null; e.pathI=0; e.pathT=0; e.pathGoal=null; e.pathFail=false;
       p.x=s.q.x; p.y=s.q.y; p.downed=false; g.bullets.length=0;
       e.face=(face===undefined)?s.dir:face;
       o.d0=Math.hypot(s.q.x-e.x,s.q.y-e.y);
       for(f=0;f<n;f++){
         if(pin){ e.x=s.b.x; e.y=s.b.y; e.face=(face===undefined)?s.dir:face; }
         updateEnts(0.016);
         if(e.windup!==null&&e.windup!==undefined) o.wind++;
         o.maxl=Math.max(o.maxl,Math.hypot(e.x-L.x,e.y-L.y));
       }
       o.rounds=g.bullets.filter(function(x){ return x.owner===e; }).length;
       o.d1=Math.hypot(p.x-e.x,p.y-e.y); o.seen=!!e.seenYou; o.off=Math.abs(angDiff(Math.atan2(p.y-e.y,p.x-e.x),e.face));
       return o;
     };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       say=function(){};
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].boss&&g.ents[i].hp>0){ e=g.ents[i]; break; }
       if(!e){ if(CFG.boss===0){ cbOff=true; CFG.boss=1; } g.t=Math.max(g.t||0,2.5); try{ e=bossTick(true); }catch(_bt){ e=null; } }
       if(!e||e.lairX===undefined) return 'SKIP: no Overseer in this raid';
       g.bossDone=1; g.lightning=0; pc0=g.pConceal; g.pConceal=1; G.pCrouch=false;
       p=g.player; px0=p.x; py0=p.y; p.iv=99; p.hp=100; p.downed=false;
       E0=g.ents; g.ents=[e]; L={x:e.lairX,y:e.lairY};
       if(typeof refreshVseg==='function') refreshVseg();
       base=(CFG.wardenRng===undefined?620:CFG.wardenRng);
       if(e.rng!==Math.round(base*1.4)) bad.push('THE OVERSEER sees '+e.rng+' out, not '+Math.round(base*1.4)+' (1.4 times a Warden)');
       W=mkWarden(L.x,L.y); if(W.rng!==base) bad.push('a plain Warden sees '+W.rng+' out, not its own '+base);
       A=find(780,0,1000,750,true);
       B=find(560,1150,1500,900,true);
       B2=find(900,1150,1700,900,true);
       C=find(450,0,1000,750,false);
       D=find(500,0,1000,750,true);
       if(!A||!B||!B2||!C||!D) return 'SKIP: staging: no open ground for '+(A?'':'A ')+(B?'':'B ')+(B2?'':'B2 ')+(C?'':'C ')+(D?'':'D ');
       // A: inside the leash, 780 away (past a Warden 620, inside its 868), a clear line: it fires
       r=run(A,undefined,320,0,true);
       if(r.rounds<1) bad.push('with a clear line at '+Math.round(r.d0)+' and the player inside its leash it fired nothing in 5 seconds (windup '+r.wind+' frames, seen '+r.seen+')');
       // B: past the leash, 560 away, inside its reach: it holds its ground and fires
       r=run(B,undefined,320,0,false);
       if(r.rounds<1) bad.push('past its leash ('+Math.round(B.dl)+' from the lair) and '+Math.round(r.d0)+' from it with a clear line it fired nothing in 5 seconds (windup '+r.wind+' frames, faces him within '+r.off.toFixed(2)+')');
       if(r.maxl>B.rb+12) bad.push('past its leash it walked '+Math.round(r.maxl-B.rb)+' farther from its lair');
       if(r.d1<r.d0-12) bad.push('past its leash it closed '+Math.round(r.d0-r.d1)+' on the player');
       // B2: past the leash and out of its reach (900): no round, and it does not chase
       r=run(B2,undefined,320,4,false);
       if(r.rounds>0) bad.push('past its leash and '+Math.round(r.d0)+' away, beyond its reach, it fired '+r.rounds+' rounds');
       if(Math.hypot(e.tx-L.x,e.ty-L.y)>80) bad.push('past its leash and out of reach it was walking to a spot '+Math.round(Math.hypot(e.tx-L.x,e.ty-L.y))+' from its lair, not home');
       // C: a wall between: no round, never seen
       r=run(C,undefined,100,0,true);
       if(r.rounds>0||r.seen) bad.push('through a wall at '+Math.round(r.d0)+' it '+(r.rounds>0?'fired '+r.rounds+' rounds':'saw the player'));
       // D: its sprite looks at him (the side of its heading) though the cone is turned 80 degrees away: it sees him; then it turns to face him and fires
       dir=D.dir; ok=false;
       for(i=0;i<2&&!ok;i++){ fc=dir+(i?-1.4:1.4); ok=((Math.cos(fc)>=0)===(D.q.x>=D.b.x)); }
       if(!ok) return 'SKIP: staging: no side-facing heading';
       r=run(D,fc,4,0,true);
       if(!r.seen) bad.push('its sprite looks his way at '+Math.round(r.d0)+' with a clear line and it did not see him');
       r=run(D,fc,320,0,false);
       if(r.rounds<1) bad.push('it saw him on the side it faces and never fired in 5 seconds');
       // E: its back to him (the sprite looks away): not seen
       fc=dir+Math.PI;
       r=run(D,fc,4,0,true);
       if(r.seen) bad.push('with its back to him at '+Math.round(r.d0)+' it saw him');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=oSay; if(cbOff) CFG.boss=0;
       try{ if(g) g.pConceal=pc0; }catch(_c){}
       try{ if(E0&&G) G.ents=E0; }catch(_r){}
       try{ if(G&&G.player&&px0!==null){ G.player.x=px0; G.player.y=py0; G.player.iv=0; } }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
