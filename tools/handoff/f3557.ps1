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

if ($s.Contains("  {v:'35.57',what:")) { throw "check 35.57 is in the fixture already" }

SubRx @'
  {v:'35.56',what:
'@ @'
  {v:'35.57',what:'pad container reload and search labels meet the 16px floor and sit above the head in both windows at 1080p and 4k; keyboard prompt geometry stays unchanged',
   run:function(){
     var pk=Object.assign({},PAD),nk=Object.assign({},NET),ik=Object.assign({},INDEV),cp=Object.assign({},CFG),pm=P.keymap,
         hp=hudPrompt,ft=ctx.fillText,ow=W,oh=H,g,p,ct,side,size,mode,cap=[],text=[],collect=false,bad=[],base,res,k,expected,label,skin;
     function near(a,b){return Math.abs(a-b)<0.6;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';__topClear();
       INDEV.legacy=false;NET.on=false;P.keymap=null;CFG.xfPix=0;keys={};mouse.down=false;
       g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.legendOn=0;g.ents=[];g.searching=null;
       g.nearPad=false;g.nearDown=null;g.nearDoor=null;g.nearForge=null;g.nearPed=null;g.nearSeal=null;g.nearStray=null;
       ct=g.containers.filter(function(c){return !c.opened;})[0];if(!ct)return 'no camera box';ct.x=p.x+12;ct.y=p.y;ct.tag='cache';g.nearContainer=ct;
       p.hand=null;p.downed=false;p.roll=0;p.drawT=0;p.reloading=0;p.reserve=60;p.wep=cloneObj(WEAPONS.rifle);p.hurtAt=g.t;p.iv=9999;
       PAD.on=true;PAD.brand='xbox';PAD.xWas=false;PAD.xMode=null;
       hudPrompt=function(s,x,y,o){if(collect)cap.push({s:String(s).toLowerCase(),x:x,y:y});return hp.apply(this,arguments);};
       ctx.fillText=function(s,x,y){
         if(collect){var m=/([\d.]+)px/.exec(this.font),t=this.getTransform(),d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1;
           text.push({s:String(s).toLowerCase(),px:m?(+m[1])*Math.abs(t.a)/d:0});}
         return ft.apply(this,arguments);
       };
       for(size=0;size<2;size++){
         __forceSize(size?3840:1920,size?2160:1080);res=hudRes();
         for(side=0;side<2;side++){
           NET.same=side?'p2':'host';NET.seat=side?1:0;
           for(mode=0;mode<3;mode++){
             INDEV.dev=mode===2?'kb':'pad';p.ammo=mode===0?2:p.wep.mag;
             render2D(0);base=w2s(ct.x,26,ct.y);cap=[];text=[];collect=true;try{drawHUD();}finally{collect=false;}
             expected=mode===0?'[x] reload':mode===1?'[x] search cache':'[e] search cache';
             label=cap.filter(function(r){return r.s===expected;})[0];skin=text.filter(function(r){return r.s===expected;})[0];
             k=NET.same+'/'+(size?'4k':'1080')+'/'+mode;
             if(!label||!skin){bad.push(k+': prompt not drawn '+expected);continue;}
             if(!near(label.x,base.x)||!near(label.y,base.y-(mode===2?0:LH(24)*res)))bad.push(k+': prompt did not clear the head or keyboard moved');
             if(mode<2&&skin.px<15.9*res)bad.push(k+': label is only '+skin.px.toFixed(1)+'px');
             if(mode===2&&!near(skin.px,(+(/([\d.]+)px/.exec(FS(TYPE.head))||[0,0])[1])*HUDPROMPTZ*res))bad.push(k+': keyboard scale changed');
           }
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       collect=false;hudPrompt=hp;ctx.fillText=ft;
       try{NET.on=false;NET.same='';__endRaid('abandon');}catch(e){}__topClear();__forceSize(ow,oh);
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
       Object.assign(INDEV,ik);Object.assign(CFG,cp);P.keymap=pm;keys={};mouse.down=false;
     }
   }},
  {v:'35.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
