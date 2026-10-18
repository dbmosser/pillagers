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

if ($s.Contains("  {v:'30.40',what:")) { throw "check 30.40 is in the fixture already" }

SubRx @'
  {v:'30.39',what:
'@ @'
  {v:'30.40',what:'a full held magazine of the Compact SMG shakes the camera between 0.8 and 2.5 px at its worst, down from 4.65 (the 2.2 kick climbed with every round, his Q5 gun feel)',
   run:function(){
     if(typeof gunShake!=='function'||typeof gfxTrauma!=='function') return 'SKIP: no gunShake';
     var g=null, out=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       var held=function(){
         var w=WEAPONS.smg, mx=0, i, k, nx=0, t=0, dt=1/60; CFG.shake=1; CFG.fxInt=1; GFX.shG=null; G.shake=0;
         for(i=0;i<w.mag*8;i++){
           t+=dt;
           if(t>=nx){ fireWeapon(g.player,w,g.player.x+200,g.player.y,true); nx+=w.rof/1000; }
           gfxTrauma(dt); if(GFX.shA>mx) mx=GFX.shA;
           if(G.shake>0) G.shake=Math.max(0,G.shake-dt*26);
         }
         return mx;
       };
       var cur=held();
       if(!(cur<2.5)) return 'a held Compact SMG magazine shakes the camera up to '+cur.toFixed(1)+' px, over 2.5';
       if(!(cur>0.8)) return 'the held SMG shakes nothing ('+cur.toFixed(2)+' px)';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
