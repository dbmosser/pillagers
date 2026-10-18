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

if ($s.Contains("  {v:'30.71',what:")) { throw "check 30.71 is in the fixture already" }

SubRx @'
  {v:'30.70',what:
'@ @'
  {v:'30.71',what:'a Longshot shot kicks the camera 7.0, up from 4.5 (about 4 px), and five shots at full rate never stack past 5 px (his Q5 gun feel)',
   run:function(){
     if(typeof gunShake!=='function'||typeof gfxTrauma!=='function') return 'SKIP: no gunShake';
     var g=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       var w=WEAPONS.sniper, mx=0, i, nx=0, t=0, dt=1/60, n=0, one=-1;
       CFG.shake=1; CFG.fxInt=1; GFX.shG=null; G.shake=0; gfxTrauma(dt);
       for(i=0;i<600;i++){
         t+=dt;
         if(t>=nx&&n<5){ G.shake=0; fireWeapon(g.player,w,g.player.x+200,g.player.y,true); if(n===0) one=G.shake; nx+=w.rof/1000; n++; }
         gfxTrauma(dt); if(GFX.shA>mx) mx=GFX.shA;
         if(G.shake>0) G.shake=Math.max(0,G.shake-dt*26);
       }
       if(Math.abs(one-7.0)>0.01) return 'a Longshot shot sets a kick of '+one+', not 7.0';
       if(!(mx>3.4)) return 'five Longshot shots shake the camera only '+mx.toFixed(2)+' px, under 3.4';
       if(!(mx<5.0)) return 'five Longshot shots shake the camera '+mx.toFixed(2)+' px, over 5.0';
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
