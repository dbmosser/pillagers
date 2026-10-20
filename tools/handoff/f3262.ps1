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

if ($s.Contains("  {v:'32.62',what:")) { throw "check 32.62 is in the fixture already" }

SubRx @'
  {v:'32.61',what:
'@ @'
  {v:'32.62',what:'View tap opens and closes the bag; View hold opens goals with raid status, releases cleanly and never opens the bag',
   run:function(){
     var NG=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), PK=Object.assign({},PAD), ns=NET.same,pm=P.padmap,nf=netPadNow,pad,clock=100,g,draw=raidStatusDraw,draws=0;
     function poll(down){var b=[];for(var i=0;i<17;i++)b.push({pressed:down&&i===8,value:down&&i===8?1:0});pad={connected:true,index:0,id:'Xbox check',mapping:'standard',buttons:b,axes:[0,0,0,0]};pollPad();}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.same=null;P.padmap=null;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();__topClear();g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.trade=null;g.forgeUI=null;g.wheel=null;
       navigator.getGamepads=function(){return [pad];};netPadNow=function(){return clock;};PAD.announced=true;PAD.prev=[];PAD.viewAt=null;
       poll(false);poll(true);clock+=0.1;poll(false);if(!g.bagOpen)return 'View tap did not open the bag';
       poll(true);clock+=0.1;poll(false);if(g.bagOpen)return 'View tap did not close the bag';
       poll(true);clock+=0.26;poll(true);if(!keys.AltLeft||g.bagOpen)return 'View hold did not open status without the bag';
       g.arcade=true;g.flow={goals:[{id:'fixture',t:'test goal',n:3,v:1,chip:1,done:0}]};
       raidStatusDraw=function(){draws++;return draw();};drawHUD();
       if(!draws||!RSTAT.lines.some(function(s){return /test goal/i.test(s);}))return 'the held status did not show the goals together';
       poll(false);if(keys.AltLeft||g.bagOpen)return 'View release left status or opened the bag';
       keys.AltLeft=true;draws=0;drawHUD();if(!draws)return 'keyboard Alt no longer opens status';keys.AltLeft=false;
       poll(true);clock+=0.3;poll(true);padRelease();if(keys.AltLeft)return 'a panel left status held';
       return null;
     }finally{
       raidStatusDraw=draw;netPadNow=nf;try{padRelease();__endRaid('abandon');}catch(e){}__topClear();NET.same=ns;P.padmap=pm;
       if(own)navigator.getGamepads=NG;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,PK);PADB.sig='';padLabelsApply();
     }
   }},
  {v:'32.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
