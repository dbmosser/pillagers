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

if ($s.Contains("  {v:'37.73',what:")) { throw "check 37.73 is in the fixture already" }

SubRx @'
  {v:'37.72',what:
'@ @'
  {v:'37.73',what:'the paired keyboard chip clears the actual raid score box and reads at least 75 percent of the drawn score font at 1080p and 4k in both local seats, with legacy hub placement intact',
   run:function(){
     var nk=Object.assign({},NET),pp=P,cp=Object.assign({},CFG),ao=ARCADE.on,nf=netPadFocused,np=netSamePost,ht=hudText,sh=arcadeScoreHud;
     var oldTag=document.getElementById('kbmark'),oldCSS=oldTag&&oldTag.style.cssText,ow=W,oh=H,g,bad=[],capture=false,scorePx=0,side,tv,i,tag;
     function ok(b,s){if(!b)bad.push(tag+': '+s);}
     function hit(a,b){return a.x<b.x+b.w&&a.x+a.w>b.x&&a.y<b.y+b.h&&a.y+a.h>b.y;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();P=JSON.parse(JSON.stringify(P));P.hud={};ARCADE.on=false;
       __deploy({kit:['gun_shotgun'],safe:null,mapIx:0,seed:4242});g=__state();if(!g||g.over||!g.player)return 'no live raid';
       __topClear();g.mapFirst=0;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.sim=false;g.career=1;g.arcade=false;g.player.iv=9999;g.player.downed=false;
       NET.on=false;netPadFocused=function(){return true;};netSamePost=function(){return true;};
       arcadeScoreHud=function(){capture=true;try{return sh.apply(this,arguments);}finally{capture=false;}};
       hudText=function(t,x,y){if(capture)scorePx=Math.max(scorePx,msgPx(ctx.font)*Math.abs(ctx.getTransform().d));return ht.apply(this,arguments);};
       for(i=0;i<2;i++)for(tv=0;tv<2;tv++)for(side=0;side<2;side++){
         __forceSize(i?3840:1920,i?2160:1080);__pinDPR(1);CFG.hudTv=tv;
         NET.same=side?'p2':'host';NET.role=side?'join':'host';NET.seat=side;NET.pair='cx-kbscoreclear';NET.p2win=side?null:{closed:false};
         tag=W+' '+NET.same+' hud '+tv;scorePx=0;render2D(0);kbMarkTick();
         var e=document.getElementById('kbmark'),cr=hcv.getBoundingClientRect(),sx=cr.width/W,sy=cr.height/H;
         ok(!!e&&getComputedStyle(e).display!=='none','keyboard chip absent');
         ok(SCOREBOX.g===g&&SCOREBOX.w>0&&SCOREBOX.h>0&&scorePx>0,'score did not draw');
         if(!e||SCOREBOX.g!==g)continue;
         var r=e.getBoundingClientRect(),a={x:r.left,y:r.top,w:r.width,h:r.height},b={x:cr.left+SCOREBOX.x*sx,y:cr.top+SCOREBOX.y*sy,w:SCOREBOX.w*sx,h:SCOREBOX.h*sy};
         ok(!hit(a,b),'keyboard chip overlaps score');
         ok(r.top>=b.y+b.h+6*railZ()*sy,'keyboard chip has no clear gap below score');
         ok(Math.abs(r.left-b.x)<1.5,'keyboard chip lost score left alignment');
         var cs=getComputedStyle(e),zoom=1;for(var p=e;p&&p.nodeType===1;p=p.parentElement){var z=parseFloat(getComputedStyle(p).zoom);if(z>0)zoom*=z;}
         ok(parseFloat(cs.fontSize)*zoom+0.1>=scorePx*sy*0.75,'keyboard font '+cs.fontSize+' zoom '+zoom+' versus drawn score '+scorePx*sy);
         ok(r.right<=cr.right&&r.bottom<=cr.bottom,'keyboard chip leaves canvas');
         ok(e.textContent==='keyboard'&&cs.color==='rgb(127, 196, 160)','keyboard words or colour changed');
         var ss=state;state='hub';kbMarkSet(true);
         ok(e.style.left==='50%'&&e.style.top==='6px'&&e.style.transform==='translateX(-50%)'&&e.style.fontSize==='16px'&&e.style.padding==='4px 8px','Undercroft layout changed or inherited raid sizing');
         state=ss;kbMarkTick();netPadFocused=function(){return false;};kbMarkTick();ok(e.style.display==='none','unfocused window kept keyboard marker');netPadFocused=function(){return true;};
       }
       return bad.length?bad.join('; '):null;
     }finally{
       hudText=ht;arcadeScoreHud=sh;netPadFocused=nf;netSamePost=np;
       try{NET.on=false;if(g&&!g.over)__endRaid('abandon');}catch(_e){}
       __forceSize(ow,oh);__topClear();__resetCfg();__cleanProfile();
       P=pp;Object.assign(CFG,cp);ARCADE.on=ao;Object.assign(NET,nk);
       var el=document.getElementById('kbmark');if(el){if(oldTag)el.style.cssText=oldCSS;else el.remove();}
     }
   }},
  {v:'37.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
