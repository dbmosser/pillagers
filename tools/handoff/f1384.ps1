$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'13.83',what:
'@ @'
  {v:'13.84',what:'one swing clock for bare hands and no punch with a live grenade: F pressed in the same instant as a left-click swing is refused, F with a pin pulled is refused, and F on its own still swings (combat and player state audit 2026-09-14, finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof meleeStrike!=='function'||typeof updatePlayer!=='function') return 'SKIP: no melee in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.containers.length=0;
       var K=__keysRef(); for(var k0 in K) K[k0]=false;
       function arm(){
         p.wep=WEAPONS.fists; p.ammo=0; p.wepIssued=true; p.downed=false; p.dying=false; p.roll=0;
         p.cooking=0; p.cookT=0; p.reloading=0; p.jam=0; p.trigYield=false; p.fired=false;
         p.lastShot=-999999; p.meleeAt=undefined; g.searching=null; g.trade=null;
         mouse.down=false;
       }
       // CONTROL FIRST: F on its own swings.
       arm();
       if(!meleeStrike()) return 'SKIP: F on its own did not swing, so nothing here can be measured';
       // THE FINDING: a left-click swing, then F in the same instant.
       g.t+=5; arm();
       try{ g.hot=gunCell(); }catch(_gc){}
       mouse.down=true; updatePlayer(0.016); mouse.down=false;
       if(!(p.lastShot>-999999)) return 'SKIP: the left click did not swing bare hands';
       if(meleeStrike()) bad.push('F swung in the same instant as a left-click swing, two punches on two clocks');
       // AND: F with a pin pulled.
       g.t+=5; arm(); p.cooking=1; p.cookKind='frag';
       if(meleeStrike()) bad.push('F punched with a live grenade in the hand');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; }catch(_m){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.cooking=0; g2.player.cookKind=null; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
