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

if ($s.Contains("  {v:'28.43',what:")) { throw "check 28.43 is in the fixture already" }

SubRx @'
  {v:'28.42',what:
'@ @'
  {v:'28.43',what:'cloud-coop-takeover-goals-kept: when the host leaves, player 2 picks up the raid with the party run goal progress the host had (7 of 10 kills stays 7, not his own 3), and 3 more kills finish the goal',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof netHostGone!=='function'||typeof goalsTick!=='function'||typeof goalProg!=='function'||typeof flowTick!=='function'||typeof GOALS!=='object') return 'SKIP: no arcade, party or run goals in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, oSay=say, sent=[], w=null, h={seat:0,state:'in'}, hp={seat:1,state:'in'}, HF=null, PF={}, staged=false, own=false, oIv=null, i, hk=null, pk=null, took, hv={}, gl;
     function word(){ var q; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd') return sent[q]; return null; }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.upSeed=g.seed>>>0; g.flow=HF; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; g.flow=PF; }
     function pick(F){ var q; for(q=0;F.goals&&q<F.goals.length;q++) if(F.goals[q].id==='kill10') return F.goals[q]; return null; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99;
       say=function(){ return 0; }; own=true;
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.entMap={};
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(){ return true; };
       HF=g.flow||{};
       asHost(); g.t=30; flowTick(0.01);
       if(!HF.goals||!HF.goals.length) return 'SKIP: staging: the raid drew no goals';
       hk=pick(HF);
       if(!hk){ HF.goals[0]={id:'kill10',t:GOALS.kill10.t,n:GOALS.kill10.n,chip:GOALS.kill10.chip,v:0,done:0}; hk=HF.goals[0]; }
       // the host has 7 kills for the party
       HF.kills=7; goalsTick(0.01);
       if(hk.v!==7) return 'SKIP: staging: the host kill goal reads '+hk.v+' of 10, not 7';
       for(i=0;i<HF.goals.length;i++) hv[HF.goals[i].id]=HF.goals[i].done?-1:(HF.goals[i].v|0);
       sent.length=0; netWorldSend(); w=word(); asTwo();
       if(!w) return 'SKIP: staging: no world word';
       netOnMsg(h,JSON.stringify(w));
       pk=pick(PF);
       if(!pk||pk.v!==7) return 'SKIP: staging: player 2 kill goal reads '+(pk?pk.v:'none')+' before the takeover, not 7';
       // player 2 had 3 kills of his own on his window
       PF.kills=3;
       // THE HOST WINDOW CLOSES: player 2 picks up the raid
       took=netHostGone('out');
       if(took!==true) return 'SKIP: staging: netHostGone did not take over ('+took+')';
       for(i=0;i<5;i++) flowTick(0.1);
       pk=pick(PF);
       if(!pk) bad.push('player 2 lost the kill goal at the takeover');
       else if(pk.v!==7||pk.done) bad.push('after the takeover the party kill goal reads '+pk.v+' of 10'+(pk.done?' done':'')+', not the 7 the host had');
       for(i=0;PF.goals&&i<PF.goals.length;i++){ gl=PF.goals[i]; if(hv[gl.id]>0&&!gl.done&&(gl.v|0)<hv[gl.id]) bad.push('after the takeover goal '+gl.id+' fell from '+hv[gl.id]+' to '+gl.v); }
       // 3 more kills of his own finish it
       PF.kills+=3; flowTick(0.1);
       pk=pick(PF);
       if(pk&&!pk.done) bad.push('after 3 more kills the party kill goal reads '+pk.v+' of 10 and is not done');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       netSendFast=oSF; netSend=oS;
       if(own) say=oSay;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(p&&oIv!==null) p.iv=oIv;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join(' | '):null;
   }},
  {v:'28.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
