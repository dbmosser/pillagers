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

if ($s.Contains("  {v:'36.22',what:")) { throw "check 36.22 is in the fixture already" }

SubRx @'
  {v:'36.21',what:
'@ @'
  {v:'36.22',what:'active reload damage and stim time share a real 16px detail floor and the style-guide muted ink',
   run:function(){
     var g,p,ft=ctx.fillText,kk=keys,mm=mouse.down,seen={},bad=[],us,ownUS=false;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       ownUS=Object.prototype.hasOwnProperty.call(P,'uiScale');us=P.uiScale;P.uiScale=1;
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.mapOpen=false;g.bagOpen=false;g.paused=false;g.sim=false;keys={};mouse.down=false;
       p.arStk=3;p.arBonus=1;p.arMul=1.35;p.arGun=p.wep;p.ammo=3;p.reloading=0;p.stimT=5;
       ctx.fillText=function(t){
         var text=String(t).toLowerCase(),m=ctx.getTransform(),px=parseFloat((/([\d.]+)px/.exec(ctx.font)||[])[1]),d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1;
         seen[text]={px:px*Math.sqrt(m.a*m.a+m.b*m.b)/d/hudRes(),col:ctx.fillStyle};return ft.apply(this,arguments);
       };
       ctx.save();try{var hd=(typeof DPRH==='number'&&DPRH>0)?DPRH:1;ctx.setTransform(hd,0,0,hd,0,0);drawStatusIcons();}finally{ctx.restore();}
       ['+35% damage','5s'].forEach(function(t){
         if(!seen[t]||!isFinite(seen[t].px)||seen[t].px<15.99)bad.push(t+' detail below 16px ('+(seen[t]?seen[t].px.toFixed(3):'not drawn')+')');
         else if(seen[t].col!=='#aaa498')bad.push(t+' detail does not use tx-2');
       });
       return bad.length?bad.join('; '):null;
     }finally{
       ctx.fillText=ft;keys=kk;mouse.down=mm;
       try{if(p){p.arStk=0;p.arBonus=0;p.stimT=0;}__endRaid('abandon');}catch(_e){}__topClear();
       if(ownUS)P.uiScale=us;else delete P.uiScale;
     }
   }},
  {v:'36.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
