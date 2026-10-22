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

if ($s.Contains("  {v:'33.97',what:")) { throw "check 33.97 is in the fixture already" }

SubRx @'
  {v:'33.96',what:
'@ @'
  {v:'33.97',what:'gambler and bar use aligned header rows, readable primary actions, and stats fill a four-column grid with a level hero',
   run:function(){
     var oldP=null,bad=[],md,h,sec,offer,b,cs,rows,sg,hero,first,second,nt=null;
     function fail(t){bad.push(t);}
     function lime(s){return String(s).replace(/\s/g,'')==='rgb(230,255,61)';}
     function header(id){
       md=document.getElementById(id);h=md.querySelector('h3');cs=getComputedStyle(h);
       if(parseFloat(cs.fontSize)<32||cs.textAlign!=='left')fail(id+' title is not 32px left aligned');
       if(h.getBoundingClientRect().top>innerHeight*.16)fail(id+' title still floats at mid-screen');
       if(getComputedStyle(md).justifyContent!=='flex-start')fail(id+' body still vertically centred');
     }
     try{
       // v28.xx (cw-cx-ucfinish): measure settled colours, not the inherited button/row transition immediately after an affordability or pad-focus change.
       nt=document.createElement('style');nt.textContent='#gamblemodal *,#barmodal *{transition:none !important;}';document.head.appendChild(nt);
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();oldP=JSON.stringify(P);
       __hubEnter();P.credits=900;P.gambleLog=[];P.wirtLotBought=-1;__station('gamble','KeyE');
       header('gamblemodal');
       if(getComputedStyle(document.getElementById('wallet_gamble')).display!=='none'||getComputedStyle(document.getElementById('gamble_line')).display!=='none')fail('gambler repeats wallet or vendor explanation');
       sec=document.getElementById('wirtsec_gamble');offer=document.getElementById('wirtsec_offer');
       var r1=sec.getBoundingClientRect(),r2=offer.getBoundingClientRect();
       if(Math.abs(r1.width-r2.width)>1||Math.abs(r1.left-r2.left)>1||r1.width<innerWidth*.5)fail('gambler counters lost their shared wide column');
       b=document.getElementById('gamblebtn');cs=getComputedStyle(b);
       if(!b.disabled||!b.getAttribute('data-need')||parseFloat(cs.fontSize)<20||parseFloat(cs.minHeight)<56)fail('unaffordable gamble is missing readable cost/shortfall');
       if(cs.color==='rgb(122, 118, 110)')fail('disabled gamble is faint');
       cs=getComputedStyle(b,'::after');if(parseFloat(cs.fontSize)<16||parseFloat(cs.borderTopWidth)>0)fail('shortfall is still a small boxed chip');
       P.credits=50000;renderGamble();b=document.getElementById('gamblebtn');if(b.disabled||!lime(getComputedStyle(b).backgroundColor))fail('affordable gamble lacks lime fill: '+getComputedStyle(b).backgroundColor);
       __topClear();__hubEnter();P.credits=50000;P.buzz=[];__station('bar','KeyE');header('barmodal');
       rows=document.querySelectorAll('#barlist .row');first=rows[0].querySelector('button');second=rows[1].querySelector('button');
       padSetFocus(first);cs=getComputedStyle(first);if(!lime(cs.backgroundColor)||parseFloat(cs.minHeight)<56||parseFloat(cs.fontSize)<20)fail('bar focused primary is not filled and readable');
       padSetFocus(second);if(!lime(getComputedStyle(second).backgroundColor)||lime(getComputedStyle(first).backgroundColor))fail('bar has no single moving primary focus: first '+getComputedStyle(first).backgroundColor+', second '+getComputedStyle(second).backgroundColor);
       if(getComputedStyle(rows[1]).borderLeftColor!==__ACC())fail('focused bar row lacks accent edge: '+getComputedStyle(rows[1]).borderLeftColor);
       padSetFocus(null);__topClear();__hubEnter();__station('mf','KeyT');
       sg=document.getElementById('statgrid');cs=getComputedStyle(sg);
       if(cs.gridTemplateColumns.split(/\s+/).length!==4)fail('stats do not fill four equal columns');
       hero=sg.querySelector('.scard:nth-child(7) .sv');cs=getComputedStyle(hero);if(parseFloat(cs.fontSize)<56||!lime(cs.color))fail('experience lacks its 56px hero');
       var labels=sg.querySelectorAll('.sk,.ss'),i;for(i=0;i<labels.length;i++)if(getComputedStyle(labels[i]).display!=='none'&&parseFloat(getComputedStyle(labels[i]).fontSize)<16)fail('stats text below 16px');
       var ac=document.querySelector('#achlist > div:nth-child(2)');if(!ac||parseFloat(getComputedStyle(ac).fontSize)<16)fail('achievement goals below 16px');
       return bad.length?bad.join('; '):null;
     }finally{
       if(nt)nt.remove();
       try{padSetFocus(null);__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();if(oldP)P=JSON.parse(oldP);
     }
   }},
  {v:'33.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
