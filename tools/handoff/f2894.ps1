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

if ($s.Contains("  {v:'28.94',what:")) { throw "check 28.94 is in the fixture already" }

SubRx @'
  {v:'28.93',what:
'@ @'
  {v:'28.94',what:'the PRE-RAID page picks how much cash to take and the stall sells no more than that (his order: quickly pick how much cash and how many of each wheel item to take)',
   run:function(){
     if(typeof cashStep!=='function') return 'there is no cash pick on the PRE-RAID page (no cashStep)';
     var g, host, b, p, keepCr, bad=[], cr0=0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // A. the chip
       P.stash=['bandage']; P.kit=[]; P.freeKit=0; P.kitPick='mine'; P.intel=0; P.credits=1000; P.takeCash=null;
       renderSector();
       host=document.getElementById('sectorpack');
       b=host&&host.querySelector('[data-cash="-1"]');
       if(!b) return 'the pack row has no cash minus button';
       b.click();
       if(P.takeCash!==900) return 'one minus on 1000 credits left takeCash '+P.takeCash+', not 900';
       host=document.getElementById('sectorpack'); host.querySelector('[data-cash="1"]').click();
       if(P.takeCash!==null) return 'plus back up to the bank did not read ALL ('+P.takeCash+')';
       host=document.getElementById('sectorpack'); host.querySelector('[data-cash="-1"]').click(); host=document.getElementById('sectorpack'); host.querySelector('[data-cash="all"]').click();
       if(P.takeCash!==null) return 'MAX did not read ALL';
       // B. the stall
       P.credits=5000; P.takeCashRaid=300;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       if(g.cash!==300) return 'a raid that took 300 credits has cash '+g.cash;
       p=g.player; g.ents.length=0; p.downed=false; g.bag=[]; g.pick=[]; g.msgLog=[];
       g.trade={x:p.x,y:p.y,stock:[{k:'scrap',price:400,sold:false}]};
       pedBuy(0);
       if(g.trade.stock[0].sold||P.credits!==5000) return 'a 400 credit buy went through on 300 cash (credits '+P.credits+')';
       g.trade={x:p.x,y:p.y,stock:[{k:'scrap',price:250,sold:false}]};
       pedBuy(0);
       if(!g.trade.stock[0].sold||P.credits!==4750) return 'a 250 credit buy on 300 cash did not go through (credits '+P.credits+')';
       if(g.cash!==50) return 'cash on him after the 250 buy is '+g.cash+', not 50';
       // C. no pick, no cap
       P.takeCashRaid=null; P.credits=5000;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(g.cash!=null) return 'a raid with no cash pick has a cash cap '+g.cash;
       return null;
     } finally {
       try{ P.takeCash=null; P.takeCashRaid=null; }catch(_e0){}
       try{ __cleanProfile(); }catch(_e){}
       try{ __topClear(); }catch(_e2){}
     } }},
  {v:'28.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
