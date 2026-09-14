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
  {v:'13.72',what:
'@ @'
  {v:'13.73',what:'going down shuts the stall: shot to the floor with the stall open, the stall is shut and a number key buys nothing and keeps the Credits, while the same key standing still buys (downed and extraction audit 2026-09-14, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkPeddler!=='function'||typeof pedBuy!=='function'||typeof damagePlayer!=='function'||typeof raidKey!=='function') return 'SKIP: no Peddler or damage in this build';
     var bad=[], P2=__P(), keepCr=P2.credits;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.bag=[];
       var pd=mkPeddler(p.x+40,p.y,g.map);
       if(g.ents.indexOf(pd)<0) g.ents.push(pd);
       function stock(){ pd.stock=[{k:'bandage',price:20,sold:false},{k:'bandage',price:20,sold:false}]; }
       // THE FINDING: shot to the floor with the stall open.
       stock(); g.trade=pd; P2.credits=5000;
       p.iv=0; p.armor=0; p.hp=20; p.downed=false; p.downT=0; p.revived=false;
       damagePlayer(999,'sentry','PROBE UNIT NINE',p.x-2,p.y);
       if(!p.downed) return 'SKIP: the staged hit did not put him on the floor';
       if(g.trade) bad.push('going down left the stall open over the DOWN screen');
       g.trade=pd;
       raidKey('Digit2',false,null);
       if(P2.credits!==5000||pd.stock[0].sold) bad.push('downed, the number key still bought from the stall (Credits 5000 to '+P2.credits+')');
       // CONTROL: standing, the same key buys.
       p.downed=false; p.downT=0; p.hp=100; p.iv=99;
       stock(); g.trade=pd; P2.credits=5000; g.bag=[];
       raidKey('Digit2',false,null);
       if(!(P2.credits<5000)) bad.push('control: standing at the open stall, 2 did not buy, so this check cannot see a purchase');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g3=__state(); if(g3){ g3.trade=null; if(g3.player){ g3.player.iv=0; g3.player.downed=false; g3.player.hp=100; } if(!g3.over) __endRaid('abandon'); } }catch(_e){}
       try{ P2.credits=keepCr; }catch(_c0){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
