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

if ($s.Contains("  {v:'25.70',what:")) { throw "check 25.70 is in the fixture already" }

SubRx @'
  {v:'25.69',what:
'@ @'
  {v:'25.70',what:'his orders (scopes 2x minimum, a minor zoom without a scope): no scope below 2x remains (no 1.25), the scopes are 2, 2.5, 3 and 4 in order, and aiming zooms the camera about 1.25 without a scope, 1.60 with the 2x, 2.30 with the 4x and not at all with bare hands',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof WEAPONS==='undefined'||!WEAPONS.sniper||!WEAPONS.rifle||!WEAPONS.pistol||!WEAPONS.fists) return 'SKIP: no guns here';
     var bad=[], k, g, p, oW, oA, z0, r, W_, vals=[];
     for(k in WEAPONS){ W_=WEAPONS[k]; if(W_&&W_.optic!==undefined){ vals.push(W_.optic); if(!(W_.optic>=2)) bad.push(k+' has a '+W_.optic+'x scope, under 2x'); } }
     if(vals.indexOf(1.25)>=0) bad.push('a 1.25x scope remains');
     if(!(WEAPONS.rifle.optic===2&&WEAPONS.lance&&WEAPONS.lance.optic===2.5&&WEAPONS.dmr.optic===3&&WEAPONS.sniper.optic===4)) bad.push('the scope table is not 2, 2.5, 3, 4 on the Auto Rifle, the Lance, the Marksman Rifle and the Longshot');
     function run(n){ for(var j=0;j<n;j++) __frame(0.05); }
     function aim(w){ p.wep=w; p.ads=false; run(30); z0=ZOOM(); p.ads=true; run(30); r=ZOOM()/z0; p.ads=false; return r; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false; oW=p.wep; oA=p.ads;
       r=aim(WEAPONS.pistol); if(Math.abs(r-1.25)>0.03) bad.push('aiming a gun with no scope zooms '+r.toFixed(3)+' times, not about 1.25');
       r=aim(WEAPONS.rifle); if(Math.abs(r-1.60)>0.03) bad.push('aiming the 2x Auto Rifle zooms '+r.toFixed(3)+' times, not about 1.60');
       r=aim(WEAPONS.sniper); if(Math.abs(r-2.30)>0.04) bad.push('aiming the 4x Longshot zooms '+r.toFixed(3)+' times, not about 2.30');
       r=aim(WEAPONS.fists); if(Math.abs(r-1)>0.01) bad.push('aiming bare hands zooms '+r.toFixed(3)+' times, not at all');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(p){ p.wep=oW; p.ads=false; } if(g) g.adsZ=1; }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
