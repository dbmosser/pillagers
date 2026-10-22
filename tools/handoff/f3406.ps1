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

if ($s.Contains("  {v:'34.06',what:")) { throw "check 34.06 is in the fixture already" }

SubRx @'
  {v:'34.05',what:
'@ @'
  {v:'34.06',what:'the hub backpack is a centred 90 percent card on a visible scrim with a visible focusable X; close and B preserve the kit',
   run:function(){
     var pp=P,sv=saveProfile,st=state,hb=HB,g=G,wn=WNSEEN,ns=NET.same,no=NET.on,ao=ARCADE.on,at=ATT.on,pk=Object.assign({},PAD),ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads');
     var ow=W,oh=H,fr=ctx.fillRect,rec=[],bad=[],pad;
     function poll(b){pad={connected:true,index:0,id:'Xbox card',mapping:'standard',axes:[0,0,0,0],buttons:[]};for(var i=0;i<17;i++)pad.buttons.push({pressed:i===b,value:i===b?1:0});pollPad();}
     function tap(b){poll(-1);poll(b);poll(-1);}
     try{
       P=JSON.parse(JSON.stringify(pp));saveProfile=function(){};
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.same=null;NET.on=false;ARCADE.on=false;ATT.on=false;WNSEEN=true;
       __hubEnter();__topClear();pauseOpen=false;hubBagOpenSet(false);
       [].forEach.call(document.querySelectorAll('.modal.on,.pausebox.on,#hub.on,#title.on'),function(e){e.classList.remove('on');});
       P.kit=['gun_rifle','medkit'];P.hotAssign={};
       ctx.fillRect=function(x,y,w,h){rec.push({x:x,y:y,w:w,h:h,c:String(this.fillStyle).replace(/\s/g,''),a:this.globalAlpha});return fr.apply(this,arguments);};
       var sizes=[[1920,1080],[3840,2160]];
       for(var q=0;q<sizes.length;q++){
         __forceSize(sizes[q][0],sizes[q][1]);hubBagOpenSet(true);rec=[];drawHubBag();
         var b=hubBagG.bagPanel,x=document.getElementById('hubbagclose'),r=x&&x.getBoundingClientRect();
         if(!b||Math.abs(b.x+b.w/2-W/2)>1||Math.abs(b.y+b.h/2-H/2)>1||Math.abs(b.w-W*.9)>2||Math.abs(b.h-H*.9)>2)bad.push(W+': backpack is not centred at 90 percent');
         if(!rec.some(function(v){return v.x===0&&v.y===0&&v.w===W&&v.h===H&&v.c==='rgba(6,7,8,0.8)'&&v.a===1;}))bad.push(W+': no visible full-screen 80 percent scrim');
         if(!x||x.textContent!=='\u00d7'||!r||r.width<40||r.height<40||getComputedStyle(x).display==='none'||getComputedStyle(x).visibility==='hidden')bad.push(W+': no visible X button');
         else {x.focus();if(document.activeElement!==x)bad.push(W+': X is not focusable');x.click();if(hubBagOpen||P.kit.join(',')!=='gun_rifle,medkit')bad.push(W+': X did not close and preserve the kit');}
         hubBagOpenSet(false);
       }
       navigator.getGamepads=function(){return [pad];};PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.announced=true;PAD.aSpent=true;PAD.focus=null;
       tap(8);drawHubBag();if(!hubBagOpen)bad.push('View did not reopen the card');
       tap(1);if(hubBagOpen||P.kit.join(',')!=='gun_rifle,medkit')bad.push('B did not close and preserve the kit');
       var xb=document.getElementById('hubbagclose');if(xb&&getComputedStyle(xb).display!=='none')bad.push('the X remains after B close');
       return bad.length?bad.join('; '):null;
     }finally{
       ctx.fillRect=fr;try{hubBagOpenSet(false);__endRaid('abandon');}catch(e){}__topClear();__forceSize(ow,oh);
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       P=pp;saveProfile=sv;state=st;HB=hb;G=g;WNSEEN=wn;NET.same=ns;NET.on=no;ARCADE.on=ao;ATT.on=at;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
     }
   }},
  {v:'34.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
