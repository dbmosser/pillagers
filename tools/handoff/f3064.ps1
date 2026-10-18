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

if ($s.Contains("  {v:'30.64',what:")) { throw "check 30.64 is in the fixture already" }

SubRx @'
  {v:'30.63',what:
'@ @'
  {v:'30.64',what:'a Support MG round kicks the camera 2.0, down from 2.2, and a held full 60 round magazine stays under 1.5 px (his Q5 gun feel)',
   run:function(){
     if(typeof gunShake!=='function'||typeof gfxTrauma!=='function') return 'SKIP: no gunShake';
     var g=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       var w=WEAPONS.lmg, mx=0, i, nx=0, t=0, dt=1/60, n=0, one=-1;
       CFG.shake=1; CFG.fxInt=1; GFX.shG=null; G.shake=0; gfxTrauma(dt);
       for(i=0;i<540;i++){
         t+=dt;
         if(t>=nx&&n<w.mag){ G.shake=0; fireWeapon(g.player,w,g.player.x+200,g.player.y,true); if(n===0) one=G.shake; nx+=w.rof/1000; n++; }
         gfxTrauma(dt); if(GFX.shA>mx) mx=GFX.shA;
         if(G.shake>0) G.shake=Math.max(0,G.shake-dt*26);
       }
       if(Math.abs(one-2.0)>0.01) return 'a Support MG round sets a kick of '+one+', not 2.0';
       if(!(mx>0.2)) return 'a held Support MG magazine shakes the camera only '+mx.toFixed(2)+' px, under 0.2';
       if(!(mx<1.5)) return 'a held Support MG magazine shakes the camera '+mx.toFixed(2)+' px, over 1.5';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
