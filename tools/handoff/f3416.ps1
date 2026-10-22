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

if ($s.Contains("  {v:'34.16',what:")) { throw "check 34.16 is in the fixture already" }

SubRx @'
  {v:'34.15',what:
'@ @'
  {v:'34.16',what:'after controls fold, the f1 hint uses its screen anchor rather than the old compact-list transform and stays clear of the bot list',
   run:function(){
     var g, ph=P.hud, z0=LEGZ0, hz=HUDZ.legend, anchor0=_legAnchorY, base0=_legBase, od=drawLegend, op=padOn, ft=ctx.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), transforms=[], hints=[], bad=[], k;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||!g.player) return 'no raid';
       g.mapOpen=false; g.mapFirst=0; g.bagOpen=false; g.paused=true; g.player.downed=false; keys={}; mouse.down=false;
       // v28.xx (cw-cx-foldedhint): the width clamp can shrink LEGZ0 to 0.9; stage the real saved user zoom too, so the pre-fold draw is reliably enlarged.
       P.hud={legend:{z:1.7}}; LEGZ0=1.7; HUDZ.legend=1.7; padOn=function(){ return false; };
       drawLegend=function(){ var m=ctx.getTransform(), d=DPRH||1; transforms.push({mode:g.legendOn,a:m.a/d,d:m.d/d,x:m.e/d,y:m.f/d}); return od.apply(this,arguments); };
       ctx.fillText=function(s,x,y){
         var text=String(s).toLowerCase(), m=ctx.getTransform(), d=DPRH||1;
         if(!g.legendOn&&/controls/.test(text)){
           var px=parseFloat((/([\d.]+)px/.exec(ctx.font)||[0,16])[1]);
           hints.push({x:(m.a*x+m.e)/d,y:(m.d*y+m.f)/d,w:ctx.measureText(String(s)).width*Math.abs(m.a)/d,h:px*Math.abs(m.d)/d});
         }
         return ft.apply(this,arguments);
       };
       g.legendOn=1; g.legendAutoDone=false; g.legendExtDone=false; g.beaconT=null;
       if(raidClockOn()) g.timeLeft=(g.raidLen===undefined?CFG.raidSec:g.raidLen)-5; else g.t=5;
       __frame(0); __frame(0);
       if(!transforms.length||transforms[transforms.length-1].a<1.1) bad.push('compact control panel was not staged with a real zoom');
       if(raidClockOn()) g.timeLeft=(g.raidLen===undefined?CFG.raidSec:g.raidLen)-35; else g.t=35;
       __frame(0); __frame(0);
       if(g.legendOn!==0) bad.push('controls did not naturally fold at thirty seconds');
       var tr=transforms[transforms.length-1], hint=hints[hints.length-1], board=HUDBOX.raiders;
       if(!tr||Math.abs(tr.a-1)>1e-6||Math.abs(tr.d-1)>1e-6||Math.abs(tr.y)>1e-6) bad.push('folded hint inherited compact-list zoom or vertical shift');
       if(!hint) bad.push('f1 controls hint did not draw');
       else{
         if(hint.h<16-1e-6) bad.push('folded hint is below the 16px label floor');
         if(hint.y-hint.h<0||hint.y>H) bad.push('folded hint left the screen');
         if(board&&hint.x<board.x+board.w&&hint.x+hint.w>board.x&&hint.y>board.y&&hint.y-hint.h<board.y+board.h) bad.push('folded hint overlaps the bot list');
       }
       P.hud.legend={dx:24,dy:16}; __frame(0); tr=transforms[transforms.length-1];
       if(Math.abs(tr.x-24)>1e-6||Math.abs(tr.y-16)>1e-6||Math.abs(tr.a-1)>1e-6) bad.push('folded hint lost the existing user drag offset');
       return bad.length?bad.join('; '):null;
     }finally{
       drawLegend=od; padOn=op; if(own) ctx.fillText=ft; else delete ctx.fillText;
       P.hud=ph; LEGZ0=z0; HUDZ.legend=hz; _legAnchorY=anchor0; _legBase=base0;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     } }},
  {v:'34.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
