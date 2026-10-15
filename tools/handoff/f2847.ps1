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

if ($s.Contains("  {v:'28.47',what:")) { throw "check 28.47 is in the fixture already" }

SubRx @'
  {v:'28.46',what:
'@ @'
  {v:'28.47',what:'cloud-coop-teammate-bare-hands: a teammate with a grenade or heal out, searching, cutting a seal or on Bare Hands is drawn with bare hands in the other window, both ways, as he sees himself',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof netUpTick!=='function'||typeof netOnMsg!=='function'||typeof netUpDrawOne!=='function'||typeof drawOp!=='function'||typeof handTake!=='function') return 'SKIP: no party in this fixture';
     var NK={}, k, oSF=netSendFast, oS=netSend, oDO=drawOp, oSay=say, sent=[], modes=[], g=null, p, ow, oh, ohT, res=[], st, rel;
     function word(){ sent.length=0; NET.upAcc=1; netUpTick(1); for(var i=sent.length-1;i>=0;i--) if(sent[i].t==='st'&&sent[i].k==='r') return sent[i]; return null; }
     function drawn(e){ modes=[]; drawOp=function(){ modes.push(arguments[7]); }; try{ netUpDrawOne(e); }finally{ drawOp=oDO; } return modes[0]; }
     function seat(n){ for(var i=0;i<NET.up.length;i++) if(NET.up[i]&&NET.up[i].seat===n) return NET.up[i]; return null; }
     function asP2(st){ var r={role:NET.role,seat:NET.seat,peers:NET.peers}, m, e;
       NET.role='join'; NET.seat=1; NET.up=[]; NET.peers=[{seat:0,state:'in'}];
       try{ netOnMsg(NET.peers[0],JSON.stringify(st)); e=seat(0); m=e?drawn(e):'(no teammate)'; }
       finally{ NET.role=r.role; NET.seat=r.seat; NET.peers=r.peers; NET.up=[]; }
       return m; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:['frag','frag','bandage'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: the raid did not start';
       p=g.player; ow=p.wep; oh=p.hand; ohT=G.handsT;
       for(k in NET) NK[k]=NET[k];
       say=function(){ return 0; };
       NET.on=true; NET.max=4; NET.role='host'; NET.seat=0; NET.up=[]; NET.upSeed=g.seed>>>0; NET.peers=[{seat:1,state:'in'}]; NET.upAcc=0; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'PLAYER 2'}];
       netSendFast=function(q,m){ if(m===undefined) m=q; sent.push(JSON.parse(JSON.stringify(m))); return true; }; netSend=netSendFast;
       p.hand=null; G.handsT=0; G.punchT=0;
       st=word(); if(!st) return 'SKIP: no state word was sent';
       if(!p.wep||p.wep.id==='fists') return 'SKIP: the raid gave no gun';
       res.push(['host with nothing in hand',asP2(st),'']);
       if(G.bag.indexOf('frag')<0) G.bag.push('frag');
       handTake('frag'); if(!p.hand) return 'SKIP: the frag would not come out';
       st=word(); res.push(['host with a frag out',asP2(st),'none']);
       p.hand=null; G.handsT=0.25;
       st=word(); res.push(['host searching',asP2(st),'none']);
       G.handsT=0; p.wep=Object.assign({},WEAPONS.fists);
       st=word(); res.push(['host on Bare Hands',asP2(st),'none']);
       p.wep=ow;
       // player 2 takes a frag out: his own word reaches the host, and the host passes it on to a third window
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; NET.up=[];
       if(G.bag.indexOf('frag')<0) G.bag.push('frag');
       handTake('frag'); if(!p.hand) return 'SKIP: the frag would not come out for player 2';
       st=word(); p.hand=null;
       if(!st) return 'SKIP: player 2 sent no state word';
       NET.role='host'; NET.seat=0; NET.up=[]; NET.peers=[{seat:1,state:'in'},{seat:2,state:'in'}]; sent.length=0;
       netOnMsg(NET.peers[0],JSON.stringify(st));
       res.push(['player 2 with a frag out, seen by the host',seat(1)?drawn(seat(1)):'(no teammate)','none']);
       rel=null; for(k=sent.length-1;k>=0;k--) if(sent[k].t==='st'&&sent[k].s===1){ rel=sent[k]; break; }
       res.push(['player 2 with a frag out, passed on by the host',rel?(rel.hd?'none':''):'(nothing passed on)','none']);
       for(k=0;k<res.length;k++) if(res[k][1]!==res[k][2]) return res[k][0]+': the teammate is drawn with mode "'+res[k][1]+'", should be "'+res[k][2]+'"';
       return null;
     }catch(e){ return 'threw: '+String(e&&e.message||e); }
     finally{
       drawOp=oDO; netSendFast=oSF; netSend=oS; say=oSay;
       if(p){ p.wep=ow; p.hand=oh; } if(g) G.handsT=0;
       for(k in NK) NET[k]=NK[k];
       try{ __endRaid('abandon'); }catch(_){}
       try{ __topClear(); }catch(_){}
     }
   }},
  {v:'28.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
