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

if ($s.Contains("  {v:'27.09',what:")) { throw "check 27.09 is in the fixture already" }

SubRx @'
  {v:'27.08',what:
'@ @'
  {v:'27.09',what:'coop3, the two player first: the lockdown alarm fences player 2 as well: sealed in he cannot walk out, sealed out he cannot walk in, the doors open after the seal and let him through, and he is told so',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof evLaunch!=='function'||typeof evTick!=='function'||typeof lockSealed!=='function') return 'SKIP: no arcade, party or events in this fixture';
     var bad=[], A=null, g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, sent=[], w=null, ev=null, E, e2, i, oIv, oSh, oAr, h={seat:0,state:'in'}, staged=false, d, HE=null, PE={plan:null,live:[],n:0,wrecks:[]}, lines=[], rs=say, own=false;
     function word(){ var q, r=null; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd'){ r=sent[q]; break; } return r; }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; g.flow.ev=HE; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; g.flow.ev=PE; }
     function sendTake(){ sent.length=0; asHost(); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); return w; }
     function launch(){ var q; HE.live=[]; PE.live=[]; asHost(); q=evLaunch('lock'); return q; }
     function ang(q){ var a, j, R=q.r; for(j=0;j<16;j++){ a=j*Math.PI/8; if(spotFree(g.map,q.x+Math.cos(a)*(R-17),q.y+Math.sin(a)*(R-17),8)&&spotFree(g.map,q.x+Math.cos(a)*(R+17),q.y+Math.sin(a)*(R+17),8)&&spotFree(g.map,q.x+Math.cos(a)*(R+120),q.y+Math.sin(a)*(R+120),8)&&spotFree(g.map,q.x+Math.cos(a)*(R-60),q.y+Math.sin(a)*(R-60),8)) return a; } return null; }
     function at(q,a,off){ p.x=q.x+Math.cos(a)*(q.r+off); p.y=q.y+Math.sin(a)*(q.r+off); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.arcSh=0; p.armor=0; p.iv=0;
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       HE=evS(); HE.plan=[]; HE.live=[];
       g.ents=g.ents.filter(function(q){ return !(q&&q.kind!=='peddler'&&q.kind!=='stray'&&dist(q,p)<1600); });
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0;
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       // ONE: sealed IN. The host launches a lockdown; player 2 stands inside the ring when it slams, and cannot walk out
       ev=launch();
       if(!ev) return 'SKIP: staging: the lockdown found no ground';
       sendTake();
       A=ang(ev); if(A===null) return 'SKIP: staging: no open ground on the lockdown ring';
       at(ev,A,-60); p.downed=false; p.dying=0;
       asHost(); ev.t=ev.warn; evTick(0.01);
       if(ev.ph!=='live') return 'SKIP: staging: the host lockdown did not go live';
       lines.length=0; sendTake();
       E=PE;
       if(E.live.length!==1||E.live[0].ph!=='live'||E.live[0].d.pSide!==1) bad.push('ONE: player 2 inside the ring has side '+(E.live[0]&&E.live[0].d.pSide)+' ('+(E.live[0]&&E.live[0].ph)+'), not inside');
       if(!lines.some(function(m){ return /^SEALED IN/.test(m); })) bad.push('ONE: player 2 was not told SEALED IN ('+lines.join(' / ')+')');
       at(ev,A,120);
       for(i=0;i<3;i++) flowTick(0.1);
       d=Math.hypot(p.x-ev.x,p.y-ev.y);
       if(d>ev.r+0.5) bad.push('ONE: sealed in, player 2 stands '+Math.round(d-ev.r)+' outside a ring of '+ev.r);
       // TWO: sealed OUT. Player 2 stands outside and cannot walk in
       ev=launch();
       if(!ev) return 'SKIP: staging: the second lockdown found no ground';
       sendTake();
       A=ang(ev); if(A===null) return 'SKIP: staging: no open ground on the second lockdown ring';
       at(ev,A,120);
       asHost(); ev.t=ev.warn; evTick(0.01); sendTake();
       E=PE;
       if(E.live.length!==1||E.live[0].d.pSide!==2) bad.push('TWO: player 2 outside the ring has side '+(E.live[0]&&E.live[0].d.pSide)+', not outside');
       at(ev,A,-40);
       for(i=0;i<3;i++) flowTick(0.1);
       d=Math.hypot(p.x-ev.x,p.y-ev.y);
       if(d<ev.r-0.5) bad.push('TWO: sealed out, player 2 stands '+Math.round(ev.r-d)+' inside a ring of '+ev.r);
       // THREE: the doors open after the seal: player 2 walks through and is told
       lines.length=0;
       E.live[0].lt=LOCK.seal+1;
       at(ev,A,120);
       for(i=0;i<3;i++) flowTick(0.1);
       at(ev,A,-40);
       for(i=0;i<3;i++) flowTick(0.1);
       if(Math.hypot(p.x-ev.x,p.y-ev.y)>ev.r-1) bad.push('THREE: with the doors open player 2 was still held outside the ring');
       if(!lines.some(function(m){ return /^DOORS OPEN/.test(m); })) bad.push('THREE: player 2 was not told DOORS OPEN ('+lines.join(' / ')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own) say=rs;
       netSendFast=oSF; netSend=oS;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(g&&HE) g.flow.ev=HE; }catch(_ev){}
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
