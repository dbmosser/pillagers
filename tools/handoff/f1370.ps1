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
  {v:'13.69',what:
'@ @'
  {v:'13.70',what:'SELL BACKPACK leaves the tactical belt alone: with a Medkit on a belt key and one other item in the backpack, the stall keeps the Medkit and pays only for the other item (hire and peddler audit 2026-09-14, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pedSellAll!=='function'||typeof pedBuyRate!=='function'||!ITEMS.medkit) return 'SKIP: no stall in this build';
     var bad=[], X=null, k;
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&k!=='medkit'&&k!=='bandage'&&it.use!=='key'&&it.use!=='gun'&&it.use!=='heal'&&it.use!=='throw'&&ival(k)>=40){ X=k; break; } }
     if(!X) return 'SKIP: nothing plain to sell beside the Medkit';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       g.ents.length=0; g.trade={kind:'peddler',hp:100,x:g.player.x,y:g.player.y}; g.pedCarry=0; g.pedSold=0; g.issuedBandages=0;
       g.bag=['medkit',X]; g.hotAssign={2:'medkit'}; g.hotAuto={};
       pedSellAll();
       var want=Math.round(ival(X)*pedBuyRate());
       if(g.bag.indexOf('medkit')<0) bad.push('SELL BACKPACK sold the Medkit on belt key 3 (carried now '+g.pedCarry+', the other item alone is '+want+')');
       // CONTROL: the item that is only in the backpack is sold and paid for.
       if(g.bag.indexOf(X)>=0||!(g.pedCarry>=want)) bad.push('control: the '+X+' in the backpack was not sold for '+want+', so this check cannot see a sale');
       else if(g.pedCarry!==want) bad.push('the stall paid '+g.pedCarry+' where the backpack alone is worth '+want);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.trade=null; g2.hotAssign={}; g2.pedCarry=0; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
