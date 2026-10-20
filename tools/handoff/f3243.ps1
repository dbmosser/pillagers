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

if ($s.Contains("  {v:'32.43',what:")) { throw "check 32.43 is in the fixture already" }

SubRx @'
  {v:'32.42',what:
'@ @'
  {v:'32.43',what:'forge choices have a full-screen scrim, one close target, readable effects, neutral current tier and dollar prices; purchase receipt has readable cost and docks above the hotbar',
   run:function(){
     if(typeof gunCardMetrics!=='function')return 'forge finish not installed';
     var keep=JSON.stringify(P),mine=ARCADE.mine,g,PR=CanvasRenderingContext2D.prototype,ft=PR.fillText,fr=PR.fillRect,text=[],scrim=0;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();
       if(!g||g.over||!g.player)return 'no live raid';
       g.ents=[];P.credits=10000;g.cs={s:0,k:0,b:{}};ARCADE.mine=0;
       g.player.wep=forgeApply(Object.assign({},WEAPONS.rifle),1);g.player.downed=false;
       if(!forgeOpen()||!g.forgeUI)return 'no MK III picker';
       PR.fillRect=function(x,y,w,h){if(this===ctx&&x===0&&y===0&&w===W&&h===H&&String(this.fillStyle).indexOf('0.8')>=0)scrim++;return fr.apply(this,arguments);};
       PR.fillText=function(t,x,y){if(this===ctx)text.push({t:String(t).toLowerCase(),px:msgPx(this.font),x:x,y:y,col:this.fillStyle});return ft.apply(this,arguments);};
       drawForgeUI();
       if(scrim!==1)return 'forge has no full-screen scrim';
       if(g.forgeUI.cells.length!==4||g.forgeUI.closeBox.w<40)return 'missing choices or close target';
       if(text.some(function(t){return t.t==='close';}))return 'duplicate close legend';
       if(!text.some(function(t){return t.t==='current';}))return 'current tier is not labeled';
       var s=gunCardMetrics().s,effects=text.filter(function(t){return /^(burn|panic|chain|stun|slow|freeze|shred|anti-machine)$/.test(t.t);});
       if(effects.length!==8||effects.some(function(t){return t.px<Math.round(16*s);}))return 'element effects are too small or missing';
       if(text.filter(function(t){return t.t==='$6,000';}).length!==4)return 'missing dollar prices';
       if(!forgeBuy(0)||P.credits!==4000||g.cs.s!==0||ARCADE.mine!==0)return 'element purchase changed stash or score';
       text=[];var C=g.gunCard,cmp=gunCompare(C.w,C.vs);gunCardDraw(cmp,900,700,1,C.route);
       var cost=text.filter(function(t){return t.t==='cost $6,000';})[0];
       if(!cost||cost.px<20*s-0.1||text.some(function(t){return t.t==='=';}))return 'receipt cost or stat hierarchy is wrong';
       g.hotCells=[{x:W*0.3,y:H*0.88,w:80,h:80}];var pos=gunCardSpot(cmp,C.route),sz=gunCardSize(cmp,C.route);
       if(Math.abs((pos.xR-sz.w)-g.hotCells[0].x)>1||pos.yB>=g.hotCells[0].y-16*s)return 'receipt does not dock above first slot';
       return null;
     }finally{
       PR.fillText=ft;PR.fillRect=fr;
       try{if(g&&!g.over)__endRaid('abandon');}catch(_e){}
       ARCADE.mine=mine;__topClear();__applyLoaded(JSON.parse(keep));saveProfile();
     } }},
  {v:'32.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
