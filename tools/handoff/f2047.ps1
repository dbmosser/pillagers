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

if ($s.Contains("  {v:'20.47',what:")) { throw "check 20.47 is in the fixture already" }

SubRx @'
  {v:'20.46',what:
'@ @'
  {v:'20.47',what:'kit carried up and sold at the stall no longer counts against what the run found, and the lifetime earnings of the run still count everything that went up',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof pedSellAll!=='function'||typeof runEarnings!=='function'||typeof bagValue!=='function') return 'SKIP: no raid or stall here';
     var kk='key_cs_freezer';
     if(!ITEMS.codex||!ITEMS.ledger||!ITEMS.coil||!ITEMS.bandage||!ITEMS[kk]) return 'SKIP: the test items are gone';
     var bad=[], oSay=say, oBlip=blip, oPing=ping, g, ha0, tr0, c0, found, hl, ps, n0, rec, net,
         sv={credits:P.credits,stash:(P.stash||[]).slice(),netEarn:P.netEarn,best:P.best};
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!(ival('codex')>0&&ival(kk)>0)) return 'SKIP: items are worth nothing here';
       say=function(){}; blip=function(){}; ping=function(){};
       g.bag=['codex','ledger','bandage','bandage']; g.issuedBandages=2; g.bandSeen=2;
       g.carriedIn=bagValue(); g.carriedKit=g.bag.slice(); c0=g.carriedIn;
       g.bag.push('coil','bandage',kk); g.bandSeen=3; found=ival(kk);
       ha0=g.hotAssign; g.hotAssign={}; tr0=g.trade;
       g.trade={x:g.player.x,y:g.player.y,stock:[],traded:0};
       pedSellAll();
       g.trade=tr0; g.hotAssign=ha0;
       if(g.bag.join(',')!=='bandage,bandage,'+kk) bad.push('control: the stall left '+g.bag.join(',')+' in the backpack');
       net=bagValue()-g.carriedIn;
       if(net!==found) bad.push('after selling what he carried up, the backpack counts '+net+' over what the lift carried, not the '+found+' of the key he found');
       if(g.carriedKit.indexOf('codex')>=0||g.carriedKit.indexOf('ledger')>=0) bad.push('the sold Codex and Ledger are still listed as carried up');
       if(g.carriedKit.filter(function(q){ return q==='bandage'; }).length!==2) bad.push('the two issued Bandages he kept are not both listed as carried up');
       if(P.log&&P.log.length>40) P.log.splice(0,P.log.length-40);
       n0=(P.log||[]).length; hl=bagValue(); ps=g.pedSold||0;
       g.player.downed=false; __endRaid('extract');
       rec=(P.log&&P.log.length>n0)?P.log[P.log.length-1]:null;
       if(!rec) bad.push('control: the extraction banked no run');
       else {
         if((rec.haul||0)-(rec.carriedIn||0)!==found) bad.push('the banked run counts '+((rec.haul||0)-(rec.carriedIn||0))+' found, not '+found);
         if(runEarnings(rec)!==hl+ps-c0) bad.push('lifetime earnings for the run are '+runEarnings(rec)+', not the '+(hl+ps-c0)+' that came out less what went up');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; blip=oBlip; ping=oPing;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P.credits=sv.credits; P.stash=sv.stash; P.netEarn=sv.netEarn; P.best=sv.best;
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
