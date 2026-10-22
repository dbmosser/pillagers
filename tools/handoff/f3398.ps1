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

if ($s.Contains("  {v:'33.98',what:")) { throw "check 33.98 is in the fixture already" }

SubRx @'
  {v:'33.97',what:
'@ @'
  {v:'33.98',what:'gambler has a readable hero and compact primary; empty stats fold undefined metrics, restore real history and keep toasts above the card',
   run:function(){
     var oldP=null,nt=null,bad=[],md,sec,b,cs,sg,cards,i,vis,toast,ac;
     function fail(s){bad.push(s);}
     function visibleCards(){return Array.prototype.filter.call(document.querySelectorAll('#statgrid > .scard'),function(c){return getComputedStyle(c).display!=='none';});}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();oldP=JSON.stringify(P);
       nt=document.createElement('style');nt.textContent='#gamblemodal *,#opmodal *,#hubtoast{transition:none !important;}';document.head.appendChild(nt);
       __hubEnter();P.credits=900;P.gambleLog=[];P.wirtLotBought=-1;__station('gamble','KeyE');
       sec=document.getElementById('wirtsec_gamble');b=document.getElementById('gamblebtn');cs=getComputedStyle(sec.querySelector('div'));
       if(parseFloat(cs.fontSize)<60||parseFloat(getComputedStyle(sec).minHeight)<320)fail('gamble panel has no large readable hero');
       cs=getComputedStyle(b);if(parseFloat(cs.width)>321||parseFloat(cs.fontSize)<24||parseFloat(cs.minHeight)<64)fail('gamble action is still a long thin bar: '+cs.width+' wide, '+cs.minHeight+' high, '+cs.fontSize+' type, flex '+cs.flex);
       if(!b.disabled||!b.getAttribute('data-need'))fail('disabled gamble lost its shortfall');
       cs=getComputedStyle(b,'::after');if(cs.position!=='absolute'||parseFloat(cs.fontSize)<18)fail('shortfall is not readable below the primary');
       toast=document.getElementById('hubtoast');if(toast){toast.textContent='welcome pack in stash';toast.classList.add('on');if(toast.getBoundingClientRect().bottom>=mdTop())fail('toast covers the card: bottom '+toast.getBoundingClientRect().bottom+', card top '+mdTop());}
       function mdTop(){return innerHeight*.05;}
       __topClear();__hubEnter();P.log=[];openOps('rec');
       cards=visibleCards();if(cards.length!==3)fail('empty stats still show undefined run metrics: '+cards.length);
       var labels=document.querySelectorAll('#statgrid .sk,#statgrid .ss');for(i=0;i<labels.length;i++)if(parseFloat(getComputedStyle(labels[i]).fontSize)<20)fail('stats labels below zoom-adjusted size');
       ac=document.querySelector('#achlist > div:nth-child(2)');cs=getComputedStyle(ac);if(cs.flexDirection!=='column'||parseFloat(cs.fontSize)<20)fail('achievement name/goal are still loose cells');
       if(toast&&toast.getBoundingClientRect().bottom>=mdTop())fail('stats toast overlaps goals: bottom '+toast.getBoundingClientRect().bottom+', card top '+mdTop());
       P.log=[{n:1,outcome:'extract',haul:9000,dur:120,containers:3,kills:{raider:2},shots:10,hits:6,acc:60,downs:0,revives:0,mapName:'cold storage',dmg:{sentry:0,raider:0}}];
       openOps('rec');cards=visibleCards();if(cards.length<14||!document.querySelector('#loglist .runline'))fail('real logged run did not restore the full stats view');
       if(getComputedStyle(document.getElementById('loglist')).display==='none')fail('real run log was folded away');
       return bad.length?bad.join('; '):null;
     }finally{
       if(nt)nt.remove();if(toast)toast.classList.remove('on');try{__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();if(oldP)P=JSON.parse(oldP);
     }
   }},
  {v:'33.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
