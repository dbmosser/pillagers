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

if ($s.Contains("  {v:'21.80',what:")) { throw "check 21.80 is in the fixture already" }

SubRx @'
  {v:'21.79',what:
'@ @'
  {v:'21.80',what:'the raid text module: the fixture runs the real say(), and say() carries a kind, a log and the kind of a waiting line',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__loop) return 'SKIP: no raid here';
     var bad=[], g, i, f, lg, hit;
     var hit2=function(){ var L2=__msgLog(); for(var j=0;j<L2.length;j++) if(L2[j].m==='zq q') return L2[j]; return null; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       // R00, the harness: the fixture wraps the game say() instead of copying its body.
       if(typeof window.__sayReal!=='function') bad.push('the fixture keeps no handle on the real say()');
       else if(say===window.__sayReal) bad.push('say() is not wrapped, so __lastSay never moves');
       if(String(say).indexOf('G.msg'+'T=3.2')>=0) bad.push('the fixture say() is still a copy of the old body');
       g.msgQ=[]; g.msgT=0;
       __say('zq'+'wrap');
       if(g.msg!=='zqwrap'||window.__lastSay!=='zqwrap') bad.push('__say did not reach the game (msg '+g.msg+', last '+window.__lastSay+')');
       // R01, the kinds.
       say('zq kind','warn',{sub:'zq detail.'});
       if(g.msgK!=='warn') bad.push('say(m,warn) leaves the kind as '+g.msgK);
       if(g.msg!=='zq kind'||g.msgT!==3.2) bad.push('say(m,warn) no longer shows the line for 3.2 s (msg '+g.msg+', T '+g.msgT+')');
       if(g.msgSub!=='zq detail.') bad.push('the detail is not kept in msgSub');
       lg=__msgLog(); hit=lg[lg.length-1];
       if(!hit||hit.m!=='zq kind'||hit.k!=='warn') bad.push('the log does not end with the warn line');
       say('zq plain');
       if(g.msgK!=='info') bad.push('a one-string say is kind '+g.msgK+', not info');
       say('zq odd','nonsense');
       if(g.msgK!=='info') bad.push('an unknown kind is not read as info');
       for(i=0;i<20;i++) say('zq ring '+i,'chat');
       if(__msgLog().length!==16) bad.push('the log is not a ring of 16 (it holds '+__msgLog().length+')');
       g.sim=true; say('zq sim','crit'); g.sim=false;
       if(g.msg==='zq sim'||__msgLog()[15].m==='zq sim') bad.push('say() acts while G.sim is set');
       // The queue: strings in msgQ, the kind beside it, and the kind survives the drain.
       g.msgQ=[]; say('zq showing'); sayWhenFree('zq q','obj');
       if(!(g.msgQ&&g.msgQ.length===1&&g.msgQ[0]==='zq q')) bad.push('the queue no longer holds the plain string ('+JSON.stringify(g.msgQ)+')');
       if(!(g.msgQM&&g.msgQM.length===1&&g.msgQM[0]&&g.msgQM[0].k==='obj')) bad.push('the waiting line lost its kind');
       g.msgT=0.01;
       for(f=0;f<6&&!hit2();f++) __loop(performance.now()+f*16.7);
       if(!hit2()) bad.push('the waiting line never showed');
       else if(hit2().k!=='obj') bad.push('the waiting line showed as kind '+hit2().k+', not obj');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ var g2=__state(); if(g2){ g2.sim=false; g2.msgQ=[]; g2.msgQM=[]; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
