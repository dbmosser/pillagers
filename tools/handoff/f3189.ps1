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

if ($s.Contains("  {v:'31.89',what:")) { throw "check 31.89 is in the fixture already" }

SubRx @'
  {v:'31.88',what:
'@ @'
  {v:'31.89',what:'X uses R beside loot during combat, E when calm, preserves its held choice and prioritizes revives',
   run:function(){
     var NG=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), PK=Object.assign({},PAD), ns=NET.same,pm=P.padmap,pad,g;
     function poll(down){var b=[];for(var i=0;i<17;i++)b.push({pressed:down&&i===2,value:down&&i===2?1:0});pad={connected:true,index:0,id:'Xbox check',mapping:'standard',buttons:b,axes:[0,0,0,0]};pollPad();}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); NET.same=null; P.padmap=null;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state(); __topClear(); g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.trade=null;g.forgeUI=null;g.wheel=null;
       navigator.getGamepads=function(){return [pad];}; PAD.prev=[];PAD.held={};PAD.xWas=false;PAD.xAfterTrade=0;PAD.announced=true;
       g.ents=[];g.t=10;g.player.roll=0;g.player.hand=null;g.player.ammo=1;g.player.reserve=30;g.player.hurtAt=-100;g.player.lastShot=9900;g.nearContainer={};
       poll(false);poll(true);if(!keys.KeyR||keys.KeyE||PAD.xMode!=='KeyR')return 'X searched beside loot during combat';
       g.player.lastShot=-1e9; poll(true);if(!keys.KeyR||keys.KeyE)return 'held X changed its job';
       poll(false);poll(true);if(!keys.KeyE||keys.KeyR)return 'X did not search when calm';
       poll(false);g.player.lastShot=9900;g.player.reserve=0;poll(true);if(!keys.KeyE||keys.KeyR)return 'X wastes its press on a reload with no rounds';
       poll(false);g.player.reserve=30;g.nearDown={};poll(true);if(!keys.KeyE||keys.KeyR)return 'X reload blocked a revive';
       return null;
     }finally{
       try{padRelease();__endRaid('abandon');}catch(e){} __topClear(); NET.same=ns;P.padmap=pm;
       if(own)navigator.getGamepads=NG;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,PK);
     }
   }},
  {v:'31.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
