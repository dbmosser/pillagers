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

if ($s.Contains("  {v:'31.87',what:")) { throw "check 31.87 is in the fixture already" }

SubRx @'
  {v:'31.86',what:
'@ @'
  {v:'31.87',what:'RS crowbar uses the real melee cooldown, blocks panels, holds aim for 80 ms and leaves focus to LT',
   run:function(){
     var NG=navigator.getGamepads, own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), PK=Object.assign({},PAD), ns=NET.same, pm=P.padmap, nowFn=netPadNow, ms=meleeStrike, fw=fireWeapon, pad, clock=100, calls=0, shots=0, g;
     function poll(button,axes){ var b=[]; for(var i=0;i<17;i++) b.push({pressed:i===button,value:i===button?1:0}); pad={connected:true,index:0,id:'Xbox check',mapping:'standard',buttons:b,axes:axes||[0,0,0,0]}; pollPad(); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); NET.same=null; P.padmap=null;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state(); __topClear(); g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.trade=null;g.forgeUI=null;g.wheel=null;
       navigator.getGamepads=function(){return [pad];}; netPadNow=function(){return clock;};
       PAD.announced=true; PAD.prev=[]; PAD.adsT=0; PAD.adsTog=false; PAD.meleeDown=false; PAD.meleeAimUntil=0;
       g.player.roll=0; g.searching=null; g.player.downed=false; g.player.meleeAt=undefined; g.t=10;
       meleeStrike=function(){calls++;return ms();}; fireWeapon=function(){shots++;};
       poll(-1,[0,0,1,0]); var a=PAD.aimA;
       poll(11,[0,0,0,1]);
       if(calls!==1||shots!==1) return 'RS did not make exactly one real crowbar swing: '+calls+'/'+shots;
       if(PAD.adsTog||g.player.ads) return 'RS still focuses aim';
       if(Math.abs(PAD.aimA-a)>1e-6) return 'the click nudged the aim angle';
       clock+=0.04; poll(11,[0,0,0,1]); if(calls!==1||PAD.aimA!==a) return 'held RS repeats or the 80 ms aim hold ended early';
       clock+=0.05; poll(11,[0,0,0,1]); if(Math.abs(PAD.aimA-Math.PI/2)>0.001) return 'aim did not resume after 80 ms';
       g.t+=0.1; poll(-1); poll(11); if(shots!==1) return 'a second click bypassed the melee cooldown';
       g.t+=1; poll(-1); poll(11); if(shots!==2) return 'a fresh click after cooldown did not swing';
       var props=['bagOpen','mapOpen','wheel','trade','forgeUI'];
       for(var j=0;j<props.length;j++){ poll(-1); g[props[j]]=props[j]==='trade'?{stock:[]}:props[j]==='forgeUI'?{n:1,sel:0}:props[j]==='wheel'?{pad:0}:true; var before=calls; poll(11); if(calls!==before) return 'RS swung under '+props[j]; g[props[j]]=props[j].indexOf('Open')>=0?false:null; }
       poll(-1); poll(6); if(!g.player.ads||!PAD.adsAim) return 'LT no longer holds focus'; poll(-1); if(g.player.ads||PAD.adsAim) return 'LT release left focus latched';
       PADB.sig=''; padLabelsApply(); if(PADLABEL.KeyV!=='RS') return 'crowbar label is not RS';
       return null;
     }finally{
       meleeStrike=ms; fireWeapon=fw; netPadNow=nowFn; NET.same=ns; P.padmap=pm;
       try{padRelease(); __endRaid('abandon');}catch(e){} __topClear();
       if(own) navigator.getGamepads=NG; else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];}); Object.assign(PAD,PK); PADB.sig=''; padLabelsApply();
     }
   }},
  {v:'31.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
