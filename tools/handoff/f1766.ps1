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

if ($s.Contains("  {v:'17.66',what:")) { throw "check 17.66 is in the fixture already" }

SubRx @'
  {v:'17.65',what:
'@ @'
  {v:'17.66',what:'his ruling 2026-10-01: a teammate who died or extracted cannot join that raid again (no button, the lift says so, the host refuses); one who abandoned can',
   run:function(){
     if(typeof netLateReply!=='function'||typeof netUpEnd!=='function'||typeof netLateBtn!=='function') return 'SKIP: this build has no drop-in';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||!window.__hubEnter) return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], sent=[], oSend=netSend, oB=netBroadcast, oSay=say, oNS=netSay, oSwf=sayWhenFree, st0=state, sd, peer, held, w;
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       netSend=function(p,m){ sent.push(m); return true; }; netBroadcast=function(m){ sent.push(m); };
       say=function(){}; netSay=function(){}; sayWhenFree=function(){};
       sd=G.seed>>>0;
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.lateBan=0;
       NET.upSeed=sd; netUpEnd('dead');
       G=null; state='hub'; __hubEnter(); NET.hostSeed=sd;
       try{ var o0=document.getElementById('joinlate'); if(o0&&o0.parentNode) o0.parentNode.removeChild(o0); }catch(_o){}
       netLateBtn();
       if(document.getElementById('joinlate')) bad.push('a teammate who died was offered JOIN THE RAID IN PROGRESS for that raid');
       sent.length=0; held=netGuestHeld();
       if(!held) bad.push('a teammate who died was let up alone at the lift');
       if(sent.some(function(m){ return m&&m.t==='raidq'; })) bad.push('the lift asked to join the raid a teammate died in');
       NET.lateBan=0; NET.upSeed=sd; netUpEnd('abandon'); NET.hostSeed=sd; netLateBtn();
       if(!document.getElementById('joinlate')) bad.push('a teammate who abandoned was not offered JOIN THE RAID IN PROGRESS');
       NET.on=false; NET.role=null; NET.peers=[];   // a window counted as a teammate is held at the lift, so the host raid is built outside the party
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no host raid';
       NET.on=true;
       peer={seat:1,state:'in'}; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.lateOut={};
       netUpAnnounce(G);
       netUpWord(peer,{t:'up',st:'out',how:'extract'});
       sent.length=0; netLateReply(peer);
       if(sent.some(function(m){ return m&&m.t==='raid'; })) bad.push('the host let a teammate who extracted back into the raid');
       if(!sent.some(function(m){ return m&&m.t==='raidno'&&m.why==='out'; })) bad.push('the host did not tell the teammate who extracted he is out of this raid');
       NET.lateOut={}; netUpWord(peer,{t:'up',st:'out',how:'abandon'});
       sent.length=0; netLateReply(peer);
       if(!sent.some(function(m){ return m&&m.t==='raid'; })) bad.push('the host refused a teammate who abandoned');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netBroadcast=oB; say=oSay; netSay=oNS; sayWhenFree=oSwf; state=st0;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var jb=document.getElementById('joinlate'); if(jb&&jb.parentNode) jb.parentNode.removeChild(jb); }catch(_j){}
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
