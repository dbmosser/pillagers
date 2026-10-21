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

if ($s.Contains("  {v:'33.61',what:")) { throw "check 33.61 is in the fixture already" }

SubRx @'
  {v:'33.60',what:
'@ @'
  {v:'33.61',what:'inside itch frame the player 2 marks and the shared settings cross the bridge: a beat with raid 1 makes the pick say player 2 is in a raid, a changed sound or split key is sent and applied, only the three shared keys are taken',
   run:function(){
     if(typeof netBeatIn!=='function'||typeof netBeatPost!=='function'||typeof netBridgeTick!=='function'||typeof netBridgeKv!=='function'||typeof netBridgeKvAll!=='function') return 'FAIL: this build has no bridge marks (netBeatIn, netBeatPost, netBridgeTick, netBridgeKv, netBridgeKvAll)';
     var nk=['on','role','same','pair','mode','peers','p2win','p2url','pick','status','bc','sameBusy','err','sameT0','noLink','embP2','pend','code','mateBeat','brKv','brKvT','arcPick'], keep={}, i, bad=[], r, k;
     for(i=0;i<nk.length;i++) keep[nk[i]]=NET[nk[i]];
     var lsk=[NET_WHO_KEY,NET_SPLIT_KEY,KID_SHARE_KEY,'salvagerun:p2raid','salvagerun:p2live'], lsv={}, prof=null;
     for(i=0;i<lsk.length;i++){ try{ lsv[lsk[i]]=localStorage.getItem(lsk[i]); }catch(_a){ lsv[lsk[i]]=null; } }
     try{ prof=localStorage.getItem('salvagerun:profile'); }catch(_p){ prof=null; }
     var oEmb=reportEmbedded, oOpen=window.open, oHL=netSameHostLink, oOp=window.opener, oSnd=netSndApply, oRP=renderParty, oKS=kidSync, oRef=netRefresh, opens=0, snds=0, kids=0;
     var fake={closed:false,posted:[],postMessage:function(m,o){ this.posted.push({m:m,o:o}); },focus:function(){}};
     function ev(data,origin,source){ return netBridgeIn({data:data,origin:origin,source:source}); }
     function kvs(){ var o=[], j, p; for(j=0;j<fake.posted.length;j++){ p=fake.posted[j]; if(p.m&&p.m.pg==='pillagers'&&p.m.m&&p.m.m.t==='kv'&&p.o===location.origin) o.push(p.m.m); } return o; }
     try{
       netRefresh=function(){}; renderParty=function(){}; netSndApply=function(){ snds++; }; kidSync=function(){ kids++; return true; };
       reportEmbedded=function(){ return true; };
       window.open=function(){ opens++; return fake; };
       netSameHostLink=function(){ return 'x'; };
       try{ localStorage.removeItem('salvagerun:p2raid'); localStorage.removeItem('salvagerun:p2live'); }catch(_b){}
       NET.on=true; NET.role='host'; NET.same=''; NET.pair=''; NET.peers=[]; NET.bc=null; NET.p2win=null; NET.sameT0=0; NET.noLink=0; NET.arcPick=0; NET.mateBeat=null; NET.brKv={}; NET.brKvT=0; NET.pend=null; NET.code='';
       // a beat from the popup, before any pick: the handle is taken and the pick refuses to open over its raid
       r=ev({pg:'pillagers',m:{t:'beat',raid:1}},'https://other.example',fake);
       if(r!=='origin'||NET.mateBeat) bad.push('a beat from another origin was taken ('+r+')');
       r=ev({pg:'pillagers',m:{t:'beat',raid:1}},location.origin,fake);
       if(r!=='beat'||NET.p2win!==fake) bad.push('a beat from the popup was not taken or did not give the handle ('+r+')');
       if(typeof p2RaidNow==='function'&&!p2RaidNow()) bad.push('p2RaidNow does not see the bridged raid beat');
       r=netSamePick('coop',function(){});
       if(r!=='p2raid') bad.push('with player 2 in a raid (bridged beat) the pick did not refuse ('+r+')');
       if(opens) bad.push('the pick opened a window over a live player 2 raid');
       r=ev({pg:'pillagers',m:{t:'beat',raid:1}},location.origin,{});
       if(r!=='source') bad.push('a beat from another window was taken ('+r+')');
       r=ev({pg:'pillagers',m:{t:'beat',raid:0}},location.origin,fake);
       NET.mateBeat={live:Date.now(),raid:0};
       try{ localStorage.removeItem('salvagerun:p2raid'); }catch(_c){}
       if(typeof p2RaidNow==='function'&&p2RaidNow()) bad.push('p2RaidNow still sees a raid after a beat with raid 0');
       reportEmbedded=function(){ return false; };
       r=ev({pg:'pillagers',m:{t:'beat',raid:1}},location.origin,fake);
       if(r!=='off') bad.push('control: a beat was taken at the top level ('+r+')');
       reportEmbedded=function(){ return true; };
       // player 2 posts its beat to the opener
       try{ window.opener=fake; }catch(_d){}
       if(window.opener!==fake) bad.push('FAIL: this page cannot stub window.opener, so the beat post is untested');
       else {
         fake.posted.length=0;
         if(!netBeatPost('?p2=1&emb=1')||!fake.posted.length||fake.posted[0].m.pg!=='pillagers'||fake.posted[0].m.m.t!=='beat'||fake.posted[0].o!==location.origin) bad.push('player 2 did not post its beat to the opener');
         fake.posted.length=0;
         if(netBeatPost('?p2=1')||fake.posted.length) bad.push('control: a top level player 2 window posted a beat');
       }
       try{ window.opener=oOp; }catch(_e){}
       // the shared settings
       NET.same='host'; NET.pair='zqxpair'; NET.mode='coop'; NET.p2win=fake; NET.bc=netBridgeChan(); NET.brKv={}; NET.brKvT=0; fake.posted.length=0;
       try{ localStorage.setItem(NET_WHO_KEY,'p2'); localStorage.setItem(NET_SPLIT_KEY,'1'); localStorage.setItem(KID_SHARE_KEY,'{"kd":1}'); }catch(_f){}
       netBridgeTick(10000);
       if(kvs().length) bad.push('the first tick sent settings that did not change');
       try{ localStorage.setItem(NET_SPLIT_KEY,'0'); }catch(_g){}
       netBridgeTick(10400);
       if(kvs().length) bad.push('the settings were compared again inside a second');
       netBridgeTick(11200);
       r=kvs();
       if(r.length!==1||r[0].k!==NET_SPLIT_KEY||r[0].v!=='0'||r[0].pair!=='zqxpair') bad.push('a changed split key was not sent ('+JSON.stringify(r)+')');
       fake.posted.length=0; netBridgeTick(12400);
       if(kvs().length) bad.push('an unchanged setting was sent again');
       // received
       r=ev({pg:'pillagers',m:{t:'kv',pair:'zqxpair',k:NET_SPLIT_KEY,v:'1'}},location.origin,fake);
       if(r!=='kv'||localStorage.getItem(NET_SPLIT_KEY)!=='1'||snds!==1) bad.push('a received split key was not written and applied once ('+r+', '+snds+')');
       r=ev({pg:'pillagers',m:{t:'kv',pair:'zqxpair',k:KID_SHARE_KEY,v:'{"kd":2}'}},location.origin,fake);
       if(r!=='kv'||localStorage.getItem(KID_SHARE_KEY)!=='{"kd":2}'||kids!==1) bad.push('a received kid setting was not written and applied once ('+r+', '+kids+')');
       fake.posted.length=0; netBridgeTick(14000);
       if(kvs().length) bad.push('a setting that was just received was sent back');
       r=ev({pg:'pillagers',m:{t:'kv',pair:'zqxpair',k:'salvagerun:profile',v:'{"zqx":1}'}},location.origin,fake);
       try{ if(r!=='ignored'||localStorage.getItem('salvagerun:profile')!==prof) bad.push('a kv for the save key was taken ('+r+')'); }catch(_h){}
       r=ev({pg:'pillagers',m:{t:'kv',pair:'zzzzzz',k:NET_SPLIT_KEY,v:'0'}},location.origin,fake);
       if(r!=='ignored'||localStorage.getItem(NET_SPLIT_KEY)!=='1') bad.push('a kv with another pair code was taken ('+r+')');
       // the host values go out when the pair links
       fake.posted.length=0;
       r=ev({pg:'pillagers',m:{t:'ready',pair:'zqxpair'}},location.origin,fake);
       var ks=kvs(), got=0;
       for(i=0;i<ks.length;i++) if(ks[i].k===NET_WHO_KEY&&ks[i].v==='p2') got++;
       if(ks.length!==3||got!==1) bad.push('the host did not post its three shared settings on ready ('+ks.length+', '+got+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally {
       reportEmbedded=oEmb; window.open=oOpen; netSameHostLink=oHL; netSndApply=oSnd; renderParty=oRP; kidSync=oKS; netRefresh=oRef;
       try{ window.opener=oOp; }catch(_w){}
       for(i=0;i<lsk.length;i++){ try{ if(lsv[lsk[i]]===null) localStorage.removeItem(lsk[i]); else localStorage.setItem(lsk[i],lsv[lsk[i]]); }catch(_x){} }
       try{ if(prof===null) localStorage.removeItem('salvagerun:profile'); else localStorage.setItem('salvagerun:profile',prof); }catch(_y){}
       for(i=0;i<nk.length;i++) NET[nk[i]]=keep[nk[i]];
       try{ netModeMsg(''); }catch(_m){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
