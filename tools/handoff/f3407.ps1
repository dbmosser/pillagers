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

if ($s.Contains("  {v:'34.07',what:")) { throw "check 34.07 is in the fixture already" }

SubRx @'
  {v:'34.06',what:
'@ @'
  {v:'34.07',what:'hub pad-held items have a large lifted portrait and lime target ring; section labels are readable',
   run:function(){
     var pp=P,sv=saveProfile,ns=NET.same,no=NET.on,ao=ARCADE.on,at=ATT.on,wn=WNSEEN,st=state,hb=HB,g=G,pk=Object.assign({},PAD),dev=INDEV.dev,legacy=INDEV.legacy;
     var ow=W,oh=H,di=drawIconSprite,sr=ctx.strokeRect,ft=ctx.fillText,icons=[],rings=[],labels=[],bad=[];
     try{
       P=JSON.parse(JSON.stringify(pp));saveProfile=function(){};__runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       NET.same=null;NET.on=false;ARCADE.on=false;ATT.on=false;WNSEEN=true;__hubEnter();__topClear();pauseOpen=false;hubBagOpenSet(false);
       [].forEach.call(document.querySelectorAll('.modal.on,.pausebox.on,#hub.on,#title.on'),function(e){e.classList.remove('on');});
       P.kit=['gun_rifle','gun_shotgun','medkit'];P.hotAssign={4:'gun_shotgun'};PAD.on=true;INDEV.dev='pad';
       __forceSize(1920,1080);hubBagOpenSet(true);drawHubBag();
       var h=hubBagG;h.bagBelt=true;h.bagBeltSel=4;h.drag={key:'gun_shotgun',fromHot:4,pad:1};
       drawIconSprite=function(c,k,x,y,z){icons.push({k:k,x:x,y:y,z:z});return di.apply(this,arguments);};
       ctx.strokeRect=function(x,y,w,hh){rings.push({x:x,y:y,w:w,h:hh,c:String(this.strokeStyle)});return sr.apply(this,arguments);};
       ctx.fillText=function(t){if(t==='equipped'||t==='tactical belt')labels.push(parseFloat((/([\d.]+)px/.exec(this.font)||[])[1]));return ft.apply(this,arguments);};
       drawHubBag();var c=h.hotCells[4];
       if(!rings.some(function(r){return r.c==='#e6ff3d'&&r.x<=c.x&&r.y<=c.y&&r.x+r.w>=c.x+c.w&&r.y+r.h>=c.y+c.h;}))bad.push('held target has no visible lime ring');
       if(!icons.some(function(i){return i.k==='gun_shotgun'&&i.z>=c.w*.6&&i.x>c.x+c.w/2&&i.y<c.y+c.h/2;}))bad.push('held portrait is small or not visibly lifted');
       if(labels.length<2||labels.some(function(n){return !(n>=20);}))bad.push('section labels remain small');
       return bad.length?bad.join('; '):null;
     }finally{
       drawIconSprite=di;ctx.strokeRect=sr;ctx.fillText=ft;try{hubBagOpenSet(false);__endRaid('abandon');}catch(e){}__topClear();__forceSize(ow,oh);
       P=pp;saveProfile=sv;NET.same=ns;NET.on=no;ARCADE.on=ao;ATT.on=at;WNSEEN=wn;state=st;HB=hb;G=g;INDEV.dev=dev;INDEV.legacy=legacy;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
     }
   }},
  {v:'34.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
