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

if ($s.Contains("  {v:'35.60',what:")) { throw "check 35.60 is in the fixture already" }

SubRx @'
  {v:'35.59',what:
'@ @'
  {v:'35.60',what:'blocked browser pad reads and a throwing pad handler cannot stop real smooth-look frames in either window role',
   run:function(){
     var ng=navigator.getGamepads, own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),
       pk=Object.assign({},PAD), nk=Object.assign({},NET), rk=Object.assign({},RUMBLE), cp=Object.assign({},CFG),
       kk=keys, mm=Object.assign({},mouse), pp=pollPad, rr=render2D, nf=netPadFocused, np=netSamePost,
       oldTs=lastTs, reads=0, calls=0, draws=0, g, side, phase, j, before, clock, bad=[];
     function held(){
       keys={KeyD:true,ShiftLeft:true}; mouse.down=true;
       PAD.on=true; PAD.mx=1; PAD.my=1; PAD.held={ShiftLeft:1}; PAD.firing=0; PAD.adsing=0;
       PAD.lossRaid=null; PAD.lossIx=-1; PAD.lost=null; PAD.claim=null;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       NET.on=false; NET.same='';
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'no live raid';
       __topClear(); g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.rise=null;
       g.ents=[]; g.zones=[]; g.player.iv=9999;
       CFG.xfPix=0; CFG.fpsCap=0; CFG.superhot=0; CFG.gfxAuto=0;
       netPadFocused=function(){return true;}; netSamePost=function(){return true;};
       navigator.getGamepads=function(){reads++;throw new DOMException('pads blocked by frame policy','SecurityError');};
       render2D=function(dt){
         var c=__gfxCount([wc,ctx],['fillRect','drawImage','fillText'],function(){return rr(dt);});
         if(c.total>0) draws++;
         return c.ret;
       };
       clock=performance.now();
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host'; NET.role=side?'join':'host'; NET.seat=side; NET.on=false;
         NET.pair='cx-padpollguard'; NET.padFwd=null; NET.padWas=null; NET.padIx=-1; NET.padOther=-1;
         pollPad=pp; held(); before=reads;
         try{pollPad();}catch(e){return NET.same+': blocked pad read escaped: '+e.name;}
         if(reads!==before+1||PAD.on||PAD.mx||PAD.my||keys.ShiftLeft||!keys.KeyD||!mouse.down)
           bad.push(NET.same+': blocked read did not release only pad input');
         for(phase=0;phase<2;phase++){
           pollPad=phase?function(){calls++;throw new Error('pad handler failure');}:pp;
           held(); draws=0; before=g.t; var n=phase?calls:reads;
           for(j=0;j<3;j++){
             try{__loop(clock+=20);}catch(e){return NET.same+'/'+phase+': frame stopped: '+e.message;}
           }
           if(draws!==3||(phase?calls:reads)!==n+3) bad.push(NET.same+'/'+phase+': only '+draws+' of three frames drew');
           if(!(g.t>before)) bad.push(NET.same+'/'+phase+': raid clock stopped');
           if(PAD.on||PAD.mx||PAD.my||keys.ShiftLeft||!keys.KeyD||!mouse.down)
             bad.push(NET.same+'/'+phase+': pad input stayed held or keyboard/mouse was cleared');
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       pollPad=pp; render2D=rr; netPadFocused=nf; netSamePost=np;
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       try{padRelease();NET.on=false;NET.same='';__endRaid('abandon');}catch(_end){} __topClear();
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
       Object.assign(RUMBLE,rk);Object.assign(CFG,cp);keys=kk;Object.assign(mouse,mm);lastTs=oldTs;
       padBodyCls();
     }
   }},
  {v:'35.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
