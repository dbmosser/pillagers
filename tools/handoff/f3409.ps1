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

if ($s.Contains("  {v:'34.09',what:")) { throw "check 34.09 is in the fixture already" }

SubRx @'
  {v:'34.08',what:
'@ @'
  {v:'34.09',what:'linked teammate pad loss draws one 20px warning panel in the top band clear of extract and score, in both roles',
   run:function(){
     var ng=navigator.getGamepads, own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), nk=Object.assign({},NET), pk=Object.assign({},PAD), post=netSamePost, focus=netPadFocused, pm=P.padmap;
     var ft=ctx.fillText, panel=uiPanel, pads=[], g, tags=[], panels=[], callouts=[], label='', bad=[], collecting=false;
     function point(x,y){var m=ctx.getTransform(),d=DPR||1;return {x:(m.a*x+m.c*y+m.e)/d,y:(m.b*x+m.d*y+m.f)/d,z:Math.abs(m.d)/d};}
     function pd(ix){var b=[];for(var i=0;i<17;i++)b.push({pressed:false,value:0});return {connected:true,index:ix,id:'Xbox tag '+ix,mapping:'standard',timestamp:1,buttons:b,axes:[0,0,0,0]};}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();__topClear();
       if(!g||!g.player||g.over)return 'no raid staged';
       keys={};mouse.down=false;g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.player.iv=999;P.padmap=null;
       navigator.getGamepads=function(){return pads;};netSamePost=function(){return true;};netPadFocused=function(){return true;};
       ctx.fillText=function(s,x,y){
         if(collecting){var p=point(x,y),sz=parseFloat((/([\d.]+)px/.exec(ctx.font)||[0,0])[1])*p.z, text=String(s).toLowerCase();
           var r={x:p.x,y:p.y,sz:sz,font:ctx.font,c:ctx.fillStyle};
           if(text===label)tags.push(r);
           if(/^extract\b/.test(text)||text==='team score'||text==='score'){
             var tw=ctx.measureText(s).width*p.z,left=p.x-(ctx.textAlign==='center'?tw/2:(ctx.textAlign==='right'?tw:0));
             callouts.push({left:left,right:left+tw,top:p.y-sz,bottom:p.y+sz*0.3});
           }
         }return ft.apply(this,arguments);
       };
       uiPanel=function(c,x,y,w,h,accent){if(collecting&&c===ctx&&accent===UIC.warn){var p=point(x,y);panels.push({x:p.x,y:p.y,w:w*p.z,h:h*p.z});}return panel.apply(this,arguments);};
       ['host','p2'].forEach(function(side){
         if(pauseOpen)togglePauseBox(false);
         Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,{on:false,idx:-1,prev:[],held:{},announced:true});
         NET.same=side;NET.pair='pad-tag-check';NET.padIx=-1;NET.padOther=-1;NET.padWas=null;NET.padFwd=null;NET.padTs={};NET.padPeerLost=false;NET.padHad=false;NET.padLiveAt=netPadNow();
         g.paused=false;pads=[pd(0),pd(1)];pollPad();pads[side==='host'?0:1]=null;pollPad();pollPad();
         if(!NET.padPeerLost||pauseOpen||g.paused){bad.push(side+': teammate loss staging failed');return;}
         // v28.xx (cw-cx-padlosttag): an active extraction draws its real callout during the same frame.
         g.beaconT=8;g.active.beaconT=8;g.shipHold=null;
         label=side==='host'?'p2 pad lost':'p1 pad lost';tags=[];panels=[];callouts=[];collecting=true;
         try{__frame(0.016);}finally{collecting=false;}
         var z=Math.max(0.75,Math.min(2.2,H/1080)),b=panels[0],t=tags[0];
         if(tags.length!==1||panels.length!==1){bad.push(side+': expected one tag and warning panel, got '+tags.length+'/'+panels.length);return;}
         if(Math.abs(t.sz-20*z)>0.5||!/600 /.test(t.font)||t.c!==UIC.warn)bad.push(side+': tag is not the 20px condensed warning');
         if(Math.abs(b.h-48*z)>0.5||Math.abs(b.x+b.w/2-W/2)>1)bad.push(side+': warning panel size or centre is wrong');
         if(b.y<H*0.24||b.y+b.h>H*0.43)bad.push(side+': warning escaped the top band '+b.y);
         if(t.x<b.x+12*z||t.y<b.y||t.y>b.y+b.h)bad.push(side+': text escaped its panel');
         if(!callouts.length)bad.push(side+': no extract callout drawn');
         callouts.forEach(function(c){if(b.x<c.right&&b.x+b.w>c.left&&b.y<c.bottom+8*z&&b.y+b.h>c.top-8*z)bad.push(side+': tag overlaps extract or score');});
       });
       return bad.length?bad.join('; '):null;
     }finally{
       collecting=false;ctx.fillText=ft;uiPanel=panel;netSamePost=post;netPadFocused=focus;
       try{padRelease();__endRaid('abandon');}catch(e){}__topClear();P.padmap=pm;
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
     }
   }},
  {v:'34.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
