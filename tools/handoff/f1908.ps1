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

if ($s.Contains("  {v:'19.08',what:")) { throw "check 19.08 is in the fixture already" }

SubRx @'
  {v:'19.07',what:
'@ @'
  {v:'19.08',what:'the scope zoom follows a deliberate aim only: a controller steadying its aim after a trigger pull does not zoom, a held LT does',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof WEAPONS==='undefined'||!WEAPONS.sniper||typeof PAD==='undefined') return 'SKIP: no scoped guns or pad here';
     var bad=[], g, p, oW, z0, r, keep={adsing:PAD.adsing,adsAim:PAD.adsAim};
     function run(n){ for(var j=0;j<n;j++) __frame(0.05); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false; oW=p.wep;
       p.wep=WEAPONS.sniper; p.ads=false; PAD.adsing=0; PAD.adsAim=false; run(30); z0=ZOOM();
       p.ads=true; PAD.adsing=1; PAD.adsAim=false; run(30); r=ZOOM()/z0;
       if(r>1.02) bad.push('the steadying after a trigger pull zoomed the camera '+r.toFixed(3)+' times');
       PAD.adsAim=true; run(30); r=ZOOM()/z0;
       if(r<1.4) bad.push('control: a held LT with the Longshot zoomed only '+r.toFixed(3)+' times');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ PAD.adsing=keep.adsing; PAD.adsAim=keep.adsAim; try{ if(p){ p.wep=oW; p.ads=false; } if(g) g.adsZ=1; }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
