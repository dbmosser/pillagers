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

if ($s.Contains("  {v:'28.35',what:")) { throw "check 28.35 is in the fixture already" }

SubRx @'
  {v:'28.34',what:
'@ @'
  {v:'28.35',what:'cloud-coop-p2-close-call: an enemy round that reaches player 2 while his roll i-frames are up pays him CLOSE CALL in his own window (stamina back, +25), exactly as the host is paid; the host marks a round with rd:1, a blast does not, and a standing player 2 just takes the hit',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof closeCall!=='function'||typeof netBulletPeer!=='function'||typeof netAreaHitPeers!=='function'||typeof netOnMsg!=='function') return 'SKIP: no arcade, close call or pair channel in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oS=netSend, oSF=netSendFast, sent=[], staged=false, oSh, oAr, oMine=ARCADE.mine, host={seat:0,state:'in'}, w=null, s0, r, i;
     try{
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; p.arcSh=0; p.armor=0;
       g.ents=[]; g.bullets.length=0;
       for(k in NET) NK[k]=NET[k];
       staged=true;
       netSendFast=function(q,m){ return true; };
       netSend=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       NET.on=true; NET.max=4; NET.specG=null; NET.specTick=false; NET.upSeed=g.seed>>>0;
       // ONE (host window): an enemy round reaches player 2's body: the hit word says it was a round
       NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQK MATE'}];
       NET.up=[{seat:1,n:1,age:0,sd:g.seed>>>0,tx:p.x+300,ty:p.y,tf:0,dn:0}];
       sent.length=0;
       r=netBulletPeer({x:p.x+300,y:p.y,vx:900,vy:0,dmg:20,life:0.3,player:false,owner:{kind:'crawler',name:'X'},tint:'#f00'});
       for(i=0;i<sent.length;i++) if(sent[i].t==='hit') w=sent[i];
       if(!r||!w) bad.push('ONE: the round on player 2 sent no hit word ('+r+', '+JSON.stringify(sent)+')');
       else if(w.rd!==1) bad.push('ONE: the hit word for a round does not say it was a round: '+JSON.stringify(w));
       // TWO (host window): a blast on player 2 is not a round (the host is paid only for a round)
       sent.length=0;
       netAreaHitPeers(p.x+300,p.y,120,function(){ return 10; },'blast','');
       if(!sent.length||sent[0].t!=='hit') bad.push('TWO: the blast sent no hit word '+JSON.stringify(sent));
       else if(sent[0].rd) bad.push('TWO: a blast is marked as a round: '+JSON.stringify(sent[0]));
       if(!w) w={t:'hit',seat:1,dmg:20,kind:'crawler',name:'X',x:p.x-20,y:p.y,rd:1};
       // THREE (player 2 window): rolling with the i-frames up, the round word pays CLOSE CALL
       NET.role='join'; NET.seat=1; NET.peers=[host]; NET.up=[];
       p.roll=0.3; p.iv=0.2; p.stam=10; p.ccT=undefined; p.hp=100; s0=ARCADE.mine|0;
       netOnMsg(host,JSON.stringify(w));
       if(Math.abs(p.stam-Math.min(100,10+ROLLSTAM))>0.01) bad.push('THREE: player 2 rolled through a round and got no stamina back (stamina '+p.stam+')');
       if(((ARCADE.mine|0)-s0)!==CC_PTS) bad.push('THREE: player 2 rolled through a round and the score moved by '+((ARCADE.mine|0)-s0)+', not '+CC_PTS);
       if(p.hp!==100) bad.push('THREE: the i-frames did not stop the round (hp '+p.hp+')');
       // FOUR (player 2 window): standing still, the same word just hurts him, no reward
       p.roll=0; p.iv=0; p.stam=10; p.ccT=undefined; p.hp=100; s0=ARCADE.mine|0;
       netOnMsg(host,JSON.stringify(w));
       if(p.stam!==10) bad.push('FOUR: a standing player 2 got stamina from a round ('+p.stam+')');
       if(((ARCADE.mine|0)-s0)!==0) bad.push('FOUR: a standing player 2 was paid '+((ARCADE.mine|0)-s0)+' for a round');
       if(!(p.hp<100)) bad.push('FOUR: a standing player 2 took no damage from the round (hp '+p.hp+')');
     }catch(x){ bad.push('threw: '+String(x&&x.stack||x).slice(0,300)); }
     finally{
       netSend=oS; netSendFast=oSF; keys={};
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.roll=0; p.iv=0; } }catch(_q){}
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.mine=oMine; }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join(' | '):null;
   }},
  {v:'28.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
