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

if ($s.Contains("  {v:'32.63',what:")) { throw "check 32.63 is in the fixture already" }

SubRx @'
  {v:'32.62',what:
'@ @'
  {v:'32.63',what:'Xbox button pictures are selected for every live pad id and in the real poll path',
   run:function(){
     var ids=['Xbox 360 Controller (XInput STANDARD GAMEPAD)','DualSense Wireless Controller (STANDARD GAMEPAD Vendor: 054c Product: 0ce6)','054c','generic pad'],NG=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), PK=Object.assign({},PAD),ns=NET.same,pm=P.padmap,g,pad;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.same=null;P.padmap=null;
       for(var j=0;j<ids.length;j++)if(padBrandOf({id:ids[j]})!=='xbox')return 'non-Xbox glyphs for '+ids[j];
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();__topClear();g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.trade=null;g.forgeUI=null;g.wheel=null;
       var b=[];for(var i=0;i<17;i++)b.push({pressed:i===6,value:i===6?1:0});pad={connected:true,index:0,id:ids[1],mapping:'standard',buttons:b,axes:[0,0,0,0]};
       navigator.getGamepads=function(){return [pad];};PAD.announced=true;PAD.prev=[];pollPad();PADB.sig='';padLabelsApply();
       if(PAD.brand!=='xbox'||keyLabel('KeyE','E')!=='X'||keyLabel('Space','SPACE')!=='A')return 'live poll selected non-Xbox button pictures';
       if(padB('A B X Y LB RB LT RT')!=='A B X Y LB RB LT RT')return 'live prompts translate away from Xbox';
       return null;
     }finally{
       try{padRelease();__endRaid('abandon');}catch(e){}__topClear();NET.same=ns;P.padmap=pm;
       if(own)navigator.getGamepads=NG;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,PK);PADB.sig='';padLabelsApply();
     }
   }},
  {v:'32.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
