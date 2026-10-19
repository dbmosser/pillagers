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

if ($s.Contains("  {v:'31.90',what:")) { throw "check 31.90 is in the fixture already" }

SubRx @'
  {v:'31.89',what:
'@ @'
  {v:'31.90',what:'J8 polling: null and disconnected slots pause in two polls, same slot says press a and physical A resumes; both player windows keep their pad reservations and exchange loss tags',
   run:function(){
     var NG=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),PK=Object.assign({},PAD),NK=Object.assign({},NET),post=netSamePost,focused=netPadFocused,live=netPadLive,pm=P.padmap,g,pads=[],posts=[],bad=[];
     function pd(ix){ var b=[];for(var j=0;j<17;j++)b.push({pressed:false,value:0});return {connected:true,index:ix,id:'Xbox check '+ix,mapping:'standard',timestamp:1,buttons:b,axes:[0,0,0,0]}; }
     function reset(s){
       if(pauseOpen) togglePauseBox(false);
       Object.keys(PAD).forEach(function(k){delete PAD[k];}); Object.assign(PAD,{on:false,idx:-1,prev:[],held:{},announced:true});
       NET.same=s;NET.pair='j8-check';NET.padIx=-1;NET.padOther=-1;NET.padWas=null;NET.padFwd=null;NET.padTs={};NET.padHad=false;NET.padPeerLost=false;NET.padLiveAt=netPadNow();
       g.paused=false;g.mapOpen=false;g.bagOpen=false;g.mapFirst=false;g.trade=null;g.wheel=null;g.forgeUI=null;posts=[];pads=[pd(0),pd(1)];pollPad();
     }
     function heading(){var h=document.querySelector('#pausebox h3');return h?h.textContent.toLowerCase():'';}
     function loss(s,disconnected){
       reset(s); var ix=s==='host'?1:0, other=1-ix, saved=pads[ix], before=PAD.ix;
       if(disconnected) saved.connected=false; else pads[ix]=null;
       PAD.firing=1;mouse.down=true;PAD.held.KeyE=1;keys.KeyE=true;
       pollPad();pollPad();
       var stopped=!!(pauseOpen&&g.paused&&heading()==='pad lost');
       if(!stopped)bad.push(s+' '+(disconnected?'connected:false':'null')+': no pad lost pause within two polls');
       if(mouse.down||keys.KeyE||PAD.mx||PAD.my)bad.push(s+': loss left an input held');
       if(PAD.ix!==before)bad.push(s+': the other pad took the lost slot');
       saved.connected=true;pads[ix]=saved;pollPad();var ready=!!(pauseOpen&&heading()==='press a');
       if(!ready)bad.push(s+': returning slot did not say press a');
       pads[other].buttons[0]={pressed:true,value:1};pollPad();
       if(stopped&&!pauseOpen)bad.push(s+': the other pad resumed the loss box');
       saved.buttons[0]={pressed:true,value:1};pollPad();
       if(!(stopped&&ready&&!pauseOpen&&!g.paused&&PAD.ix===ix&&PAD.prev[0]))bad.push(s+': physical A did not resume and spend its press');
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();P.padmap=null;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();__topClear();
       navigator.getGamepads=function(){return pads;};netSamePost=function(m){posts.push(JSON.parse(JSON.stringify(m)));return true;};netPadFocused=function(){return true;};
       loss('host',false);loss('p2',false);loss('host',true);loss('p2',true);
       // Solo reserves its played slot too, even with another connected pad available.
       reset(null);pads[0]=null;pollPad();pollPad();if(!pauseOpen||heading()!=='pad lost'||PAD.ix!==0)bad.push('solo: polling missed loss or another pad took over');
       // Each side stays live when only its partner loses a pad, and the actual pad message tells the covered window immediately.
       ['host','p2'].forEach(function(s){
         reset(s);var ix=s==='host'?1:0,other=1-ix;pads[other]=null;posts=[];pollPad();pollPad();
         if(pauseOpen||g.paused||PAD.ix!==ix||!PAD.on)bad.push(s+': partner loss stopped this window or stole its pad');
         var label=s==='host'?'p2 pad lost':'p1 pad lost';if(netPadHud()!==label)bad.push(s+': missing '+label+' tag');
         var m=posts.filter(function(q){return q.t==='pad';}).pop();if(!m||m.ix!==-1)bad.push(s+': missing-slot message not sent');
         if(m){
           // Switch to the other window data, with Chrome exposing no local pads there.
           NET.same=s==='host'?'p2':'host';NET.padWas=null;NET.padOther=-1;NET.padFwd=null;PAD.lost=null;PAD.lossRaid=g;PAD.lossIx=other;PAD.ix=other;
           netPadLive=function(){return false;};pads=[];netPadRecv(m);pollPad();pollPad();
           if(!pauseOpen||heading()!=='pad lost'||!g.paused)bad.push(s+': covered window missed forwarded loss');
           netPadLive=live;
         }
         reset(s);pads[ix]=null;posts=[];pollPad();var ownLoss=posts.filter(function(q){return q.t==='pad';}).pop();
         NET.same=s==='host'?'p2':'host';NET.padWas=null;NET.padFwd=null;NET.padPeerLost=false;
         if(ownLoss)netPadRecv(ownLoss);
         if(!ownLoss||!NET.padPeerLost||netPadHud()!==(s==='host'?'p1 pad lost':'p2 pad lost'))bad.push(s+': partner did not receive sender loss tag');
         reset(s);pads[other]=null;pollPad();pads[other]=pd(other);pollPad();
         if(NET.padPeerLost||PAD.ix!==ix||pauseOpen)bad.push(s+': partner reconnect did not clear tag or changed ownership');
       });
       return bad.length?bad.join('; '):null;
     }finally{
       netPadLive=live;netPadFocused=focused;netSamePost=post;
       try{padRelease();__endRaid('abandon');}catch(e){}__topClear();P.padmap=pm;
       if(own)navigator.getGamepads=NG;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,PK);
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,NK);
     }
   }},
  {v:'31.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
