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

if ($s.Contains("  {v:'36.77',what:")) { throw "check 36.77 is in the fixture already" }

SubRx @'
  {v:'36.76',what:
'@ @'
  {v:'36.77',what:'cw-xcountplate2: the ring name badge on the extraction countdown hugs its letter (an oval narrower than it is tall) on the inbound line and the landed line, so it never touches the letters beside it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function') return 'SKIP: no raid HUD here';
     var bad=[], g, p, z, CP=CanvasRenderingContext2D.prototype, oE=CP.ellipse, oA=CP.arc, el=[], ar=0, c0=(typeof CAREER_ON==='number')?CAREER_ON:0;
     function hud(){ el=[]; ar=0;
       CP.ellipse=function(x,y,rx,ry){ try{ el.push({rx:rx,ry:ry,y:y}); }catch(_e){} return oE.apply(this,arguments); };
       CP.arc=function(x,y,r){ try{ if(Math.abs(y-(H-170))<80) ar++; }catch(_e){} return oA.apply(this,arguments); };
       try{ drawHUD(); }catch(e){ bad.push('drawHUD threw '+(e&&e.message||e)); }
       CP.ellipse=oE; CP.arc=oA; }
     function badge(){ var n=0, k; for(k=0;k<el.length;k++) if(el[k].ry>8&&el[k].y>H*0.6&&el[k].y<H*0.95) n++; return n; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.mapFirst=false; g.bagOpen=false; g.paused=false; p.hp=100; p.downed=false; p.iv=999; g.timeLeft=300; g.waypoint=null;
       z=(g.zones||[])[0]; if(!z) return 'SKIP: staging: no ring';
       z.open=true; g.active=z; p.x=z.x; p.y=z.y;
       z.beaconT=9; z.hold=null; g.beaconT=9; g.shipHold=null; hud();
       if(badge()!==1) bad.push('inbound: the ring name badge draws '+badge()+' ovals (want 1) of '+el.length);
       else { var r0=el.filter(function(q){ return q.ry>8&&q.y>H*0.6&&q.y<H*0.95; })[0]; if(!(r0.rx<r0.ry)) bad.push('inbound: the badge is round or wider than tall ('+Math.round(r0.rx)+' by '+Math.round(r0.ry)+')'); }
       z.beaconT=0; z.hold=30; z.holdMax=30; g.beaconT=0; g.shipHold=30; hud();
       if(badge()!==1) bad.push('landed: the ring name badge draws '+badge()+' ovals (want 1) of '+el.length);
     }catch(e){ bad.push('threw: '+(e.message||e)); }
     finally{ CP.ellipse=oE; CP.arc=oA; CAREER_ON=c0; try{ __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
