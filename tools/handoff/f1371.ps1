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
  {v:'13.70',what:
'@ @'
  {v:'13.71',what:'the stall does not buy issued Bandages: selling a backpack with the two issued Bandages and one plain item keeps both Bandages and pays for the plain item alone, while a Bandage he found is still sold (hire and peddler audit 2026-09-14, finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pedSellAll!=='function'||typeof pedBuyRate!=='function'||!ITEMS.bandage) return 'SKIP: no stall in this build';
     var bad=[], X=null, k;
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&k!=='medkit'&&k!=='bandage'&&it.use!=='key'&&it.use!=='gun'&&it.use!=='heal'&&it.use!=='throw'&&ival(k)>=40){ X=k; break; } }
     if(!X) return 'SKIP: nothing plain to sell beside the Bandages';
     function bands(b){ var c=0; for(var i=0;i<b.length;i++) if(b[i]==='bandage') c++; return c; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), rate=pedBuyRate();
       g.ents.length=0; g.hotAssign={}; g.hotAuto={};
       // THE FINDING: the two issued Bandages and one plain item.
       g.trade={kind:'peddler',hp:100,x:g.player.x,y:g.player.y}; g.pedCarry=0; g.pedSold=0;
       g.bag=['bandage','bandage',X]; g.issuedBandages=2;
       pedSellAll();
       var want=Math.round(ival(X)*rate);
       if(bands(g.bag)!==2) bad.push('SELL BACKPACK sold '+(2-bands(g.bag))+' of the 2 issued Bandages (carried now '+g.pedCarry+', the plain item alone is '+want+')');
       else if(g.pedCarry!==want) bad.push('the stall paid '+g.pedCarry+' where the plain item alone is worth '+want);
       // CONTROL: a Bandage he found (none issued) is sold.
       g.trade={kind:'peddler',hp:100,x:g.player.x,y:g.player.y}; g.pedCarry=0;
       g.bag=['bandage',X]; g.issuedBandages=0;
       pedSellAll();
       if(bands(g.bag)!==0||!(g.pedCarry>want)) bad.push('control: a found Bandage was not sold (carried '+g.pedCarry+'), so this check cannot see a Bandage sale');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.trade=null; g2.pedCarry=0; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
