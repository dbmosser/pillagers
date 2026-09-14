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
  {v:'13.74',what:
'@ @'
  {v:'13.75',what:'a drink keeps wearing off while you are down: two seconds of real frames on the floor take two seconds off a running drink, as two seconds standing do (downed and extraction audit 2026-09-14, finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof tickBuzz!=='function'||typeof updatePlayer!=='function'||typeof damagePlayer!=='function') return 'SKIP: no drinks or damage in this build';
     var bad=[], P2=__P(), keepBuzz=JSON.stringify(P2.buzz||[]);
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p||g.sim) return 'SKIP: no live raid';
       g.ents.length=0;
       var K=__keysRef(); for(var k0 in K) K[k0]=false;
       function drink(){ P2.buzz=[{id:'probe_ale',tag:'drunk',t:600,dur:600}]; return P2.buzz[0]; }
       // THE FINDING: down, with a drink running.
       var B=drink();
       p.iv=0; p.armor=0; p.hp=20; p.downed=false; p.downT=0; p.revived=false;
       damagePlayer(999,'sentry','PROBE UNIT NINE',p.x-2,p.y);
       if(!p.downed) return 'SKIP: the staged hit did not put him on the floor';
       p.downT=Math.max(p.downT||0,40);
       var t0=B.t;
       for(var f=0;f<20;f++){ updatePlayer(0.1); if(!p.downed||g.over) break; }
       if(!(t0-B.t>=1.9)) bad.push('two seconds downed took '+(Math.round((t0-B.t)*100)/100)+' s off a running drink');
       // CONTROL: standing, the same two seconds come off.
       p.downed=false; p.downT=0; p.hp=100; p.iv=99;
       B=drink(); t0=B.t;
       for(var f2=0;f2<20;f2++) updatePlayer(0.1);
       if(!(t0-B.t>=1.9)) bad.push('control: two seconds standing took '+(Math.round((t0-B.t)*100)/100)+' s off the drink, so this check cannot see the clock');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.buzz=JSON.parse(keepBuzz); saveProfile(); }catch(_b){}
       try{ var g3=__state(); if(g3&&g3.player){ g3.player.iv=0; g3.player.downed=false; g3.player.hp=100; } if(g3&&!g3.over) __endRaid('abandon'); }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
