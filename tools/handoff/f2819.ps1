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

if ($s.Contains("  {v:'28.19',what:")) { throw "check 28.19 is in the fixture already" }

SubRx @'
  {v:'28.18',what:
'@ @'
  {v:'28.19',what:'cloud-coop-convoy-dest: when the host leaves during a machine convoy warning, player 2 window runs the convoy with the host destination: the world word carries it, and after the takeover the carrier stays on the map and heads for that same point',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof netHostGone!=='function'||typeof evLaunch!=='function'||typeof evTick!=='function'||typeof flowTick!=='function'||typeof updateEnts!=='function') return 'SKIP: no arcade, party or events in this fixture';
     var g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, oSay=say, sent=[], w=null, h={seat:0,state:'in'}, HF=null, PF={}, staged=false, ev, E, car, i, dx, dy, oIv=null;
     function word(){ var q; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd') return sent[q]; return null; }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; NET.upSeed=g.seed>>>0; g.flow=HF; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; g.flow=PF; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99;
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.entMap={};
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       say=function(){};
       HF=g.flow||{}; HF.ev={plan:[],live:[],n:0,wrecks:[]};
       asHost(); g.t=60;
       ev=evLaunch('convoy'); if(!ev) return 'SKIP: the host launched no convoy';
       if(!isFinite(ev.d.dx)||!isFinite(ev.d.dy)) return 'the host convoy has no destination';
       dx=Math.round(ev.d.dx); dy=Math.round(ev.d.dy);
       sent.length=0; netWorldSend(); w=word(); if(!w) return 'the host sent no world word';
       asTwo(); netOnMsg(h,JSON.stringify(w));
       E=PF.ev&&PF.ev.live&&PF.ev.live[0];
       if(!E||E.id!=='convoy') return 'player 2 window did not take the convoy warning';
       if(!netHostGone('out')) return 'player 2 window did not take over the raid';
       PF.ev.plan=[];
       for(i=0;i<100;i++){ g.t+=0.25; flowTick(0.25); }
       E=PF.ev.live[0];
       if(!E||E.ph!=='live') return 'the convoy did not go live in player 2 window after the takeover ('+(E?E.ph:'none')+')';
       car=E.d.car; if(!car) return 'the convoy went live with no carrier';
       for(i=0;i<20;i++){ updateEnts(0.05); evTick(0.05); }
       if(!isFinite(car.x)||!isFinite(car.y)) return 'the carrier went to '+car.x+','+car.y+' (the destination never came over: '+E.d.dx+','+E.d.dy+')';
       if(car.tx!==dx||car.ty!==dy) return 'the carrier heads for '+car.tx+','+car.ty+', not the host destination '+dx+','+dy;
       if(g.ents.indexOf(car)<0) return 'the carrier left the map';
       return null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{
       netSendFast=oSF; netSend=oS; say=oSay;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(p&&oIv!==null) p.iv=oIv;
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
   }},
  {v:'28.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
