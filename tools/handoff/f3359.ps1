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

if ($s.Contains("  {v:'33.59',what:")) { throw "check 33.59 is in the fixture already" }

SubRx @'
  {v:'33.58',what:
'@ @'
  {v:'33.59',what:'inside itch frame the pair talks over window.opener, not a BroadcastChannel: the host posts to the popup with the frame origin, the popup posts to its opener, words from another origin or another window are ignored, a player 2 window with no opener says so',
   run:function(){
     if(typeof netBridgeIn!=='function'||typeof netBridgeOn!=='function'||typeof netEmbOf!=='function') return 'FAIL: this build has no window bridge (netBridgeIn, netBridgeOn, netEmbOf)';
     var nk=['on','role','same','pair','mode','peers','p2win','p2url','pick','status','bc','sameBusy','err','sameT0','noLink','embP2','pend','code','padIx','padOther','padWas','padFwd','sndOn','sndOther','arcPick'], keep={}, i, bad=[], r, k;
     for(i=0;i<nk.length;i++) keep[nk[i]]=NET[nk[i]];
     var oEmb=reportEmbedded, oOpen=window.open, oBC=window.BroadcastChannel, oHL=netSameHostLink, oOp=window.opener, opens=[], bcs=0, said=[], oRef=netRefresh;
     var fake={closed:false,posted:[],postMessage:function(m,o){ this.posted.push({m:m,o:o}); },focus:function(){}};
     function has(t){ var n=0, j; for(j=0;j<fake.posted.length;j++) if(fake.posted[j].m&&fake.posted[j].m.pg==='pillagers'&&fake.posted[j].m.m&&fake.posted[j].m.m.t===t&&fake.posted[j].o===location.origin) n++; return n; }
     var msg=document.getElementById('modemsg');
     try{
       netRefresh=function(){};
       reportEmbedded=function(){ return true; };
       window.BroadcastChannel=function(){ bcs++; this.postMessage=function(){ bcs+=100; }; this.close=function(){}; };
       window.open=function(u,n,f){ opens.push({u:String(u),n:n,f:String(f||'')}); return fake; };
       netSameHostLink=function(){ return 'x'; };
       NET.on=true; NET.role='host'; NET.same=''; NET.pair=''; NET.peers=[]; NET.bc=null; NET.p2win=null; NET.sameT0=0; NET.noLink=0; NET.arcPick=0; NET.pend={state:'offer'}; NET.code='ZQXCODE';
       r=netSamePick('coop',function(){});
       if(r!=='opened') bad.push('embedded pick did not open ('+r+')');
       if(!opens.length||opens[0].f.indexOf('noopener')>=0) bad.push('the player 2 window was opened with noopener, which cuts the bridge');
       if(!opens.length||opens[0].u.indexOf('emb=1')<0) bad.push('the player 2 address has no emb=1: '+(opens[0]&&opens[0].u));
       if(!NET.bc||!NET.bc.br) bad.push('the embedded host channel is not the window bridge');
       if(!has('padpick')) bad.push('padpick never reached the popup with the frame origin');
       if(!has('snd')) bad.push('snd never reached the popup with the frame origin');
       if(bcs) bad.push('a BroadcastChannel was made or used in the frame ('+bcs+')');
       fake.posted.length=0;
       function ev(data,origin,source){ return netBridgeIn({data:data,origin:origin,source:source}); }
       r=ev({pg:'pillagers',m:{t:'ready',pair:NET.pair}},location.origin,{});
       if(r!=='source'||fake.posted.length) bad.push('a word from another window was taken ('+r+')');
       r=ev({pg:'pillagers',m:{t:'ready',pair:NET.pair}},'https://other.example',fake);
       if(r!=='origin'||fake.posted.length) bad.push('a word from another origin was taken ('+r+')');
       r=ev({pg:'other',m:{t:'ready',pair:NET.pair}},location.origin,fake);
       if(r!=='bad'||fake.posted.length) bad.push('a word without the pillagers tag was taken ('+r+')');
       r=ev({pg:'pillagers',m:{t:'ready',pair:'zzzzzz'}},location.origin,fake);
       if(r!=='ignored'||fake.posted.length) bad.push('a word with another pair code was taken ('+r+')');
       r=ev({pg:'pillagers',m:{t:'ready',pair:NET.pair}},location.origin,fake);
       if(r!=='offer'||!has('offer')) bad.push('the ready word from the popup did not bring the offer back to it ('+r+')');
       window.dispatchEvent(new MessageEvent('message',{data:{pg:'pillagers',m:{t:'ready',pair:NET.pair}},origin:location.origin,source:null}));   // the real listener, with no source: ignored, throws nothing
       // a host with no handle takes the window that speaks with its pair code
       NET.p2win=null; fake.posted.length=0;
       r=ev({pg:'pillagers',m:{t:'ready',pair:NET.pair}},location.origin,fake);
       if(NET.p2win!==fake) bad.push('a host with no handle did not take the window that answered ('+r+')');
       // the player 2 side
       NET.same=''; NET.bc=null; NET.pair=''; NET.p2win=null; fake.posted.length=0; NET.embP2=0;
       try{ window.opener=fake; }catch(_wo){}
       if(window.opener!==fake) bad.push('FAIL: this page cannot stub window.opener, so the player 2 side is untested');
       else {
         r=netSameBootP2('zqxpair','coop','?p2=1&emb=1&mode=coop&pair=zqxpair');
         if(r!=='ready'||!has('ready')) bad.push('an embedded player 2 window did not post ready to its opener ('+r+')');
         if(bcs) bad.push('player 2 used a BroadcastChannel in the frame ('+bcs+')');
         r=ev({pg:'pillagers',m:{t:'hostup',pair:'zqxpair'}},location.origin,{});
         if(r!=='source') bad.push('player 2 took a word from a window that is not its opener ('+r+')');
         NET.same='p2'; NET.bc=null; NET.pair='zqxpair';
         try{ window.opener=null; }catch(_w1){}
         fake.posted.length=0; if(msg) msg.textContent='';
         NET.same='p2'; NET.bc=null;
         r=netSameBootP2('zqxpair','coop','?p2=1&emb=1&mode=coop&pair=zqxpair');
         if(r!=='noopener') bad.push('an embedded player 2 window with no opener did not say so ('+r+')');
         if(!msg||String(msg.textContent||'').toLowerCase().indexOf('no link: pick 2 player in the player 1 window')<0) bad.push('the no-link callout is not on screen');
         if(fake.posted.length||NET.bc) bad.push('a player 2 window with no opener posted something');
       }
       // control: the top level keeps its own address and its BroadcastChannel
       reportEmbedded=function(){ return false; };
       NET.same=''; NET.bc=null; NET.pair='zqxpair'; NET.p2win=null; NET.arcPick=0;
       if(netP2Url('coop','zqxpair').indexOf('emb=1')>=0) bad.push('control: the top level player 2 address carries emb=1');
       NET.same='host';
       if(netBridgeOn()) bad.push('control: the top level host uses the bridge');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally {
       reportEmbedded=oEmb; window.open=oOpen; window.BroadcastChannel=oBC; netSameHostLink=oHL; netRefresh=oRef;
       try{ window.opener=oOp; }catch(_w2){}
       try{ netSndRelease(); }catch(_sr){}
       for(i=0;i<nk.length;i++) NET[nk[i]]=keep[nk[i]];
       try{ netModeMsg(''); }catch(_m){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
