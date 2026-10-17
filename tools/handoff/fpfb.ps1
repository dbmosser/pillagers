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

if ($s.Contains("  {v:'28.92',what:")) { throw "check 28.92 is in the fixture already" }

SubRx @'
  {v:'28.91',what:
'@ @'
  {v:'28.92',what:'cloud-coop-p2-hit-stop-rule: the host holds a body for hit stop by the same rule for player 2 rounds as for its own (a heavy gun round, 40 or more before multipliers), so a rifle word into a spine, a frag word or a melee word holds nothing and a Magnum word into a plate holds the body',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof netOnMsg!=='function'||typeof netShotSend!=='function'||typeof mkBulwark!=='function'||typeof netEntMake!=='function'||typeof hitStopOn!=='function'||typeof updateBullets!=='function') return 'SKIP: the co-op shot path is not here';
     var bad=[], g=null, p=null, NK={}, k, oS=netSend, oSF=netSendFast, posted=[], h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false, e=null, m=null, n, a, aa, x=0, y=0, dx=1, dy=0, found=false, w, r;
     function shoot(gid,dmg){ g.bullets.length=0; g.bullets.push({x:x-dx*30,y:y-dy*30,vx:dx*1180,vy:dy*1180,dmg:dmg,life:0.4,player:true,owner:p,tint:'#fff',el:'',thru:0,gid:gid}); }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.entMap={901:e}; g.ents=[e]; }
     function take(word){ e.hp=5000; e.stopT=0; netOnMsg(hp,JSON.stringify(word)); return e.stopT||0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100;
       for(a=0;a<32;a++){ aa=a/32*6.2832; dx=Math.cos(aa); dy=Math.sin(aa); x=p.x+dx*150; y=p.y+dy*150; if(spotFree(g.map,x,y,40)&&rayHitG(x-dx*60,y-dy*60,dx,dy,60)>=59.5){ found=true; break; } }
       if(!found) return 'SKIP: no clear lane next to the player';
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0;
       netSendFast=function(q,mm){ return true; };
       netSend=function(q,mm){ posted.push(JSON.parse(JSON.stringify(mm))); return true; };
       e=mkBulwark(x,y); e.hp=e.maxhp=5000; e.face=Math.atan2(-dy,-dx); e.stopT=0;
       // ONE: the host takes player 2 words by the host rule
       asHost();
       r=take({t:'shot',id:901,dmg:59.8,x:p.x,y:p.y,a:0});
       if(r!==0) bad.push('ONE: a rifle word of 59.8 (a light round into a spine) with no heavy mark held the body ('+r+')');
       r=take({t:'shot',id:901,dmg:7.44,x:p.x,y:p.y,a:0,hs:1});
       if(Math.abs(r-HITSTOP_T)>1e-9) bad.push('ONE: a Magnum word of 7.44 into a plate marked heavy did not hold the body ('+r+')');
       r=take({t:'shot',id:901,dmg:80,x:p.x,y:p.y,a:0});
       if(r!==0) bad.push('ONE: a frag or melee word of 80 held the body, the host own blasts never do ('+r+')');
       // TWO: player 2 window marks a heavy gun round and not a light one
       NET.role='join'; NET.seat=1; NET.peers=[h]; NET.entMap={};
       m=netEntMake(901,'bulwark',x,y); m.hp=m.maxhp=5000; m.face=e.face; m.nIn=1; NET.entMap[901]=m; g.ents=[m];
       posted.length=0; shoot('magnum',62); for(n=0;n<6&&!posted.length;n++) updateBullets(1/60);
       w=posted.filter(function(q){ return q&&q.t==='shot'; })[0];
       if(!w) bad.push('TWO: player 2 Magnum round sent no shot word');
       else if(w.hs!==1) bad.push('TWO: player 2 Magnum round (62) did not mark the word heavy ('+JSON.stringify(w)+')');
       m.hp=5000; posted.length=0; shoot('rifle',23); for(n=0;n<6&&!posted.length;n++) updateBullets(1/60);
       w=posted.filter(function(q){ return q&&q.t==='shot'; })[0];
       if(!w) bad.push('TWO: player 2 rifle round sent no shot word');
       else if('hs' in w) bad.push('TWO: player 2 rifle round (23) marked the word heavy ('+JSON.stringify(w)+')');
     }catch(x2){ bad.push('threw: '+String(x2&&x2.message||x2)); }
     finally{
       netSend=oS; netSendFast=oSF;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join(' | '):null;
   }},
  {v:'28.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
