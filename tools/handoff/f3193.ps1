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

if ($s.Contains("  {v:'31.93',what:")) { throw "check 31.93 is in the fixture already" }

SubRx @'
  {v:'31.92',what:
'@ @'
  {v:'31.93',what:'J7: three cold/late pad trials in both windows keep A on p2 and B on p1, pulse only the claimed pad, draw the matching two-second tag, and reclaim A without buzzing B; forwarded claims reject another slot',
   run:function(){
     if(typeof padClaimPoll!=='function'||typeof padClaimDraw!=='function'||typeof padClaimRecv!=='function') return 'no pad ownership feedback';
     var NK=Object.assign({},NET), PK=Object.assign({},PAD), RK=Object.assign({},RUMBLE), get=navigator.getGamepads, own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), post=netSamePost, focus=netPadFocused, live=netPadLive, now=netPadNow, proto=CanvasRenderingContext2D.prototype, ft=proto.fillText, cr=CFG.rumble, ck=CFG.rumbleK;
     var bad=[], pulses=[], posts=[], drawn=[], pads=[], clock=100, g, A, B;
     function pd(ix){var bs=[];for(var j=0;j<17;j++)bs.push({pressed:false,value:0});return {connected:true,index:ix,id:'ownership '+ix,mapping:'standard',timestamp:1,buttons:bs,axes:[0,0,0,0],vibrationActuator:{playEffect:function(type,o){pulses.push({ix:ix,type:type,o:o});return Promise.resolve();}}};}
     function reset(side,trial,late){
       if(pauseOpen)togglePauseBox(false); PAD.lost=null;PAD.lossIx=-1;PAD.lossRaid=null;PAD.claim=null;PAD.on=false;PAD.prev=[];PAD.mSpent=[];
       NET.same=side;NET.pair='cx-owner-'+trial+'-'+side;NET.padIx=-1;NET.padOther=-1;NET.padWas=null;NET.padFwd=null;NET.padTs={};NET.padPeerLost=false;NET.padLiveAt=clock;
       A=pd(0);B=pd(1);pads=late?[]:[A,B];pulses=[];posts=[];
     }
     function tag(side){
       drawn=[]; __frame(0.016);
       var want=side==='host'?'p1':'p2', col=side==='host'?'#f5b73b':'#5fd7e8', p=msPlayerScreen();
       var d=drawn.filter(function(q){return q.t===want;});
       if(d.length!==1||d[0].c!==col||Math.abs(d[0].x-p.x)>1||Math.abs(d[0].y-(p.y+44*hudRes()))>1)bad.push(side+': tag not drawn beside its pillager in the right colour');
       if(drawn.some(function(q){return q.t===(want==='p1'?'p2':'p1');}))bad.push(side+': other window tag drawn');
       clock+=1.99;if(padClaimDraw(p.x,p.y)!==want)bad.push(side+': tag expired early');
       clock+=0.02;if(padClaimDraw(p.x,p.y)!=='')bad.push(side+': tag outlasted two seconds');
     }
     function pulse(ix,label){if(pulses.length!==1||pulses[0].ix!==ix||pulses[0].type!=='dual-rumble'||pulses[0].o.duration!==250||Math.abs(pulses[0].o.strongMagnitude-0.6)>0.001)bad.push(label+': wrong ownership pulse');}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();__topClear();
       CFG.rumble=1;CFG.rumbleK=1;keys={};mouse.down=false;
       navigator.getGamepads=function(){return pads;};netSamePost=function(m){posts.push(m);return true;};netPadFocused=function(){return true;};netPadNow=function(){return clock;};
       // v28.xx (cw-cx-padowner): spy on the prototype; an own fillText left on ctx hides the later checks prototype spies.
       proto.fillText=function(t,x,y){if(this===ctx)drawn.push({t:String(t),x:x,y:y,c:this.fillStyle});return ft.apply(this,arguments);};
       for(var trial=0;trial<3;trial++) for(var late=0;late<2;late++) ['host','p2'].forEach(function(side){
         reset(side,trial,late);var ix=side==='host'?1:0;
         if(late){pollPad();if(pulses.length||PAD.claim)bad.push('empty window claimed a pad');pads=[A,null];pollPad();if(side==='host'&&pulses.length)bad.push('first pad went to p1');pads=[A,B];}
         pollPad();if(PAD.ix!==ix||!PAD.claim||PAD.claim.ix!==ix)bad.push(side+': A/B ownership wrong');pulse(ix,side);tag(side);
         pulses=[];pollPad();pollPad();if(pulses.length)bad.push(side+': steady polling repeated the pulse');
         pads=[null,B];pollPad();pulses=[];pads=[A,B];pollPad();
         if(side==='p2'){pulse(0,'replug A');if(!PAD.claim||PAD.claim.ix!==0)bad.push('p2 did not reclaim A');tag(side);}
         else if(pulses.length||PAD.ix!==1)bad.push('replug A buzzed or moved p1');
       });
       // v28.xx (cw-cx-padowner): the covered window has no actuator; its exact-slot request crosses the real message handler.
       reset('p2','forward',false);pollPad();var m=posts.filter(function(q){return q.t==='pad';}).pop();
       NET.same='host';NET.padWas=null;NET.padFwd=null;NET.padOther=-1;PAD.claim=null;PAD.lost=null;PAD.lossRaid=null;PAD.lossIx=-1;pads=[];posts=[];pulses=[];
       netPadLive=function(){return false;};if(!m||netPadRecv(m)!=='pad')bad.push('forward staging failed');pollPad();
       var req=posts.filter(function(q){return q.t==='padclaim';}).pop();if(!req||req.ix!==1||pulses.length)bad.push('covered p1 did not request only B');tag('host');
       NET.same='p2';RUMBLE.other=B;netPadLive=live;
       if(req){if(netSameOnMsg(req)!=='rumble')bad.push('forwarded B claim rejected');pulse(1,'forwarded B');pulses=[];RUMBLE.other=A;if(netSameOnMsg(req)!=='nopad'||pulses.length)bad.push('delayed B claim buzzed A');}
       CFG.rumble=0;PAD.claim=null;padClaimPoll(A);if(pulses.length)bad.push('rumble off ignored');
       return bad.length?bad.join('; '):null;
     }finally{
       proto.fillText=ft;netPadNow=now;netPadLive=live;netPadFocused=focus;netSamePost=post;
       if(own)navigator.getGamepads=get;else delete navigator.getGamepads;
       try{padRelease();__endRaid('abandon');}catch(e){}__topClear();
       [PAD,NET,RUMBLE].forEach(function(o,i){Object.keys(o).forEach(function(k){delete o[k];});Object.assign(o,[PK,NK,RK][i]);});CFG.rumble=cr;CFG.rumbleK=ck;
     }
   }},
  {v:'31.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
