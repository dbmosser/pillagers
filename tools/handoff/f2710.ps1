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

if ($s.Contains("  {v:'27.10',what:")) { throw "check 27.10 is in the fixture already" }

SubRx @'
  {v:'27.09',what:
'@ @'
  {v:'27.10',what:'his answer 42: guns in hand even bigger: the flash, the brass and the tracer follow the drawn muzzle and port, the real round still spawns 17 units out',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof fireWeapon!=='function'||typeof GFXMUZ==='undefined') return 'SKIP: this fixture cannot fire a shot';
     var bad=[], g=null, p=null, w, b, m, s, d, by0=GFX.bypass;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.face=0; keys={}; GFX.bypass=0; GFXMUZ.length=0; g.bullets.length=0;
       w=(typeof WEAPONS!=='undefined')?WEAPONS.rifle:null; if(!w) return 'SKIP: staging: no rifle';
       if(typeof GUNK==='undefined'||!(GUNK>=1.2)) bad.push('the held gun has no size scale of 1.2 or more (GUNK)');
       fireWeapon(p,w,p.x+300,p.y,true);
       b=g.bullets[g.bullets.length-1]; m=GFXMUZ[GFXMUZ.length-1]; s=g.shells[g.shells.length-1];
       if(!b) return 'SKIP: staging: no round was fired';
       d=Math.hypot(b.x-p.x,b.y-p.y);
       if(Math.abs(d-17)>0.01) bad.push('the real round spawns '+d.toFixed(2)+' units from the shooter, not 17');
       if(!m) bad.push('the shot left no muzzle flash event'); else if(!(m.x-p.x>=36)) bad.push('the flash is '+(m.x-p.x).toFixed(1)+' units out, not at the drawn muzzle of a rifle (36 or more)');
       if(!s||!s.brass) bad.push('the shot left no brass'); else if(!(s.x-p.x>=8)) bad.push('the brass starts '+(s.x-p.x).toFixed(1)+' units out, not at the ejection port (8 or more)');
       if(!(b.mzd>=15)) bad.push('the round carries no tracer start past the drawn muzzle (mzd '+b.mzd+')');
       GFXMUZ.length=0; g.bullets.length=0;
       fireWeapon(p,w,p.x-300,p.y,true);
       m=GFXMUZ[GFXMUZ.length-1];
       if(!m||!(m.x-p.x<=-36)) bad.push('shooting left, the flash is not 36 or more to the left ('+(m?(m.x-p.x).toFixed(1):'none')+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       GFX.bypass=by0; keys={}; try{ GFXMUZ.length=0; }catch(_m){}
       try{ var g2=__state(); if(g2&&!g2.over&&g2.player){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
