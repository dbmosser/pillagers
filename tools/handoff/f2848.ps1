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

if ($s.Contains("  {v:'28.48',what:")) { throw "check 28.48 is in the fixture already" }

SubRx @'
  {v:'28.47',what:
'@ @'
  {v:'28.48',what:'cloud-coop-teammate-shield-bubble: a SHIELD BUBBLE power-up is seen round the teammate in the other window too, both ways, in a normal raid, and only while it is up',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof netUpTick!=='function'||typeof netOnMsg!=='function'||typeof netUpDrawOne!=='function'||typeof pwrS!=='function') return 'SKIP: no party in this fixture';
     var NK={}, k, oSF=netSendFast, oS=netSend, oSay=say, oArc=null, oEl=null, sent=[], g=null, p, S, hadPwr, oSh, oCar, st, e, rel, n0, n1;
     function word(){ sent.length=0; NET.upAcc=1; netUpTick(1); for(var i=sent.length-1;i>=0;i--) if(sent[i].t==='st'&&sent[i].k==='r') return sent[i]; return null; }
     function seat(n){ for(var i=0;i<NET.up.length;i++) if(NET.up[i]&&NET.up[i].seat===n) return NET.up[i]; return null; }
     function arcs(x){ var n=0; wc.arc=function(){ n++; return oArc.apply(wc,arguments); }; wc.ellipse=function(){ n++; return oEl.apply(wc,arguments); };
       try{ netUpDrawOne(x); }finally{ wc.arc=oArc; wc.ellipse=oEl; } return n; }
     function host(st,peers){ NET.role='host'; NET.seat=0; NET.up=[]; NET.peers=peers; sent.length=0; netOnMsg(NET.peers[0],JSON.stringify(st)); return seat(1); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: the raid did not start';
       if(!wc||typeof wc.arc!=='function') return 'SKIP: no world canvas';
       p=g.player; hadPwr=!!G.pwr; S=pwrS(); oSh=S.act.shield; oCar=G.career; oArc=wc.arc; oEl=wc.ellipse;
       for(k in NET) NK[k]=NET[k];
       say=function(){ return 0; };
       if(!G.arcade) G.career=1;
       NET.on=true; NET.max=4; NET.up=[]; NET.upSeed=g.seed>>>0; NET.upAcc=0; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'PLAYER 2'},{seat:2,name:'PLAYER 3'}];
       netSendFast=function(q,m){ if(m===undefined) m=q; sent.push(JSON.parse(JSON.stringify(m))); return true; }; netSend=netSendFast;
       // player 2 window with the SHIELD BUBBLE up
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}];
       S.act.shield=10;
       st=word(); if(!st) return 'SKIP: player 2 sent no state word';
       if(st.pb!==1) return 'player 2 has the SHIELD BUBBLE up but his state word carries no bubble flag (pb '+st.pb+')';
       e=host(st,[{seat:1,state:'in'},{seat:2,state:'in'}]);
       if(!e) return 'the host filed no teammate from the word';
       if(e.pb!==1) return 'the host did not keep his bubble flag (pb '+e.pb+')';
       rel=null; for(k=sent.length-1;k>=0;k--) if(sent[k].t==='st'&&sent[k].s===1){ rel=sent[k]; break; }
       if(!rel||rel.pb!==1) return 'the host did not pass his bubble on to a third window';
       n1=arcs(e); e.pb=0; n0=arcs(e); e.pb=1;
       if(n1-n0<2) return 'the host window drew no bubble round player 2 ('+n1+' arcs with it, '+n0+' without)';
       // and with no bubble
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; S.act.shield=0;
       st=word(); if(!st) return 'SKIP: player 2 sent no second word';
       if(st.pb) return 'with no bubble up the word still carries pb';
       e=host(st,[{seat:1,state:'in'}]);
       if(!e||e.pb!==0) return 'with no bubble the host still holds pb '+(e&&e.pb);
       if(arcs(e)!==n0) return 'with no bubble the host still draws extra arcs round player 2';
       // the host's own bubble seen in player 2 window
       NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; NET.up=[]; S.act.shield=10;
       st=word(); if(!st||st.pb!==1) return 'the host has the SHIELD BUBBLE up but his word carries no bubble flag';
       NET.role='join'; NET.seat=1; NET.up=[]; NET.peers=[{seat:0,state:'in'}];
       netOnMsg(NET.peers[0],JSON.stringify(st)); e=seat(0);
       if(!e||e.pb!==1) return 'player 2 window did not keep the host bubble flag';
       return null;
     }catch(x){ return 'threw: '+String(x&&x.message||x); }
     finally{
       netSendFast=oSF; netSend=oS; say=oSay;
       if(oArc) wc.arc=oArc; if(oEl) wc.ellipse=oEl;
       if(g&&G){ if(S) S.act.shield=oSh; if(!hadPwr) delete G.pwr; G.career=oCar; }
       for(k in NK) NET[k]=NK[k];
       try{ __endRaid('abandon'); }catch(_){}
       try{ __topClear(); }catch(_){}
     }
   }},
  {v:'28.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
