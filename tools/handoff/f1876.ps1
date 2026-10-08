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

if ($s.Contains("  {v:'18.76',what:")) { throw "check 18.76 is in the fixture already" }

SubRx @'
  {v:'18.75',what:
'@ @'
  {v:'18.76',what:'a scoped gun zooms in a little on ADS: the Longshot aimed pulls the zoom to about 1.49 times, the Auto Rifle about 1.09, letting go returns to 1, and the baked sprite scale never moves',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof WEAPONS==='undefined'||!WEAPONS.sniper||!WEAPONS.rifle) return 'SKIP: no scoped guns here';
     var bad=[], g, p, oW, oA, z0, z1, s0, s1, i, r;
     function run(n){ for(var j=0;j<n;j++) __frame(0.05); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false; oW=p.wep; oA=p.ads;
       p.wep=WEAPONS.sniper; p.ads=false; run(30); z0=ZOOM(); s0=wallSpriteScale();
       p.ads=true; run(30); z1=ZOOM(); s1=wallSpriteScale();
       r=z1/z0; if(Math.abs(r-1.49)>0.03) bad.push('the Longshot aimed zooms '+r.toFixed(3)+' times, not about 1.49');
       if(s1!==s0) bad.push('aiming moved the baked sprite scale from '+s0+' to '+s1);
       p.wep=WEAPONS.rifle; run(30); r=ZOOM()/z0; if(Math.abs(r-1.0875)>0.02) bad.push('the Auto Rifle aimed zooms '+r.toFixed(3)+' times, not about 1.09');
       p.ads=false; run(30); r=ZOOM()/z0; if(Math.abs(r-1)>0.005) bad.push('letting go left the zoom at '+r.toFixed(3));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(p){ p.wep=oW; p.ads=!!oA; p.ads=false; } if(g) g.adsZ=1; }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
