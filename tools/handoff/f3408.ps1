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

if ($s.Contains("  {v:'34.08',what:")) { throw "check 34.08 is in the fixture already" }

SubRx @'
  {v:'34.07',what:
'@ @'
  {v:'34.08',what:'hub backpack belt spans its grid with nine slots; held item is labelled and gun details share one surrounding panel',
   run:function(){
     var pp=P,sv=saveProfile,ns=NET.same,no=NET.on,ao=ARCADE.on,at=ATT.on,wn=WNSEEN,st=state,hb=HB,g=G,pk=Object.assign({},PAD),dev=INDEV.dev;
     var ow=W,oh=H,hp=hudPlate,ft=ctx.fillText,plates=0,held=false,bad=[];
     try{
       P=JSON.parse(JSON.stringify(pp));saveProfile=function(){};__runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       NET.same=null;NET.on=false;ARCADE.on=false;ATT.on=false;WNSEEN=true;__hubEnter();__topClear();pauseOpen=false;hubBagOpenSet(false);
       [].forEach.call(document.querySelectorAll('.modal.on,.pausebox.on,#hub.on,#title.on'),function(e){e.classList.remove('on');});
       P.kit=['gun_rifle','gun_shotgun','medkit'];P.hotAssign={4:'gun_shotgun'};PAD.on=true;INDEV.dev='pad';__forceSize(1920,1080);
       hubBagOpenSet(true);drawHubBag();var h=hubBagG;h.bagBelt=true;h.bagBeltSel=4;h.drag={key:'gun_shotgun',fromHot:4,pad:1};
       ctx.fillText=function(t){if(String(t).toLowerCase()==='held')held=true;return ft.apply(this,arguments);};
       drawHubBag();
       var cells=h.hotCells,grid=h.bagCells,first=cells[0],last=cells[cells.length-1];
       if(cells.length!==9)bad.push('the belt no longer has nine controls');
       if(!grid.length||Math.abs(first.x-grid[0].x)>1||Math.abs(last.x+last.w-(grid[0].x+h.bagCols*grid[0].w+(h.bagCols-1)*8))>2)bad.push('the belt does not span the grid width');
       if(!held)bad.push('held item has no held label');
       hudPlate=function(){plates++;return hp.apply(this,arguments);};
       var oldG=G;try{G=h;gunCardDraw(gunCompare(WEAPONS.shotgun,h.player.wep),1800,700,1,null);}finally{G=oldG;}
       if(plates)bad.push('gun details still draw a second framed plate inside the surrounding pane');
       return bad.length?bad.join('; '):null;
     }finally{
       hudPlate=hp;ctx.fillText=ft;try{hubBagOpenSet(false);__endRaid('abandon');}catch(e){}__topClear();__forceSize(ow,oh);
       P=pp;saveProfile=sv;NET.same=ns;NET.on=no;ARCADE.on=ao;ATT.on=at;WNSEEN=wn;state=st;HB=hb;G=g;INDEV.dev=dev;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
     }
   }},
  {v:'34.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
