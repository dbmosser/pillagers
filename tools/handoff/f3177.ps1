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

if ($s.Contains("  {v:'31.77',what:")) { throw "check 31.77 is in the fixture already" }

SubRx @'
  {v:'31.76',what:
'@ @'
  {v:'31.77',what:'the run over card: the score word is a 16px label over the 56px figure, a zero score is dimmed, the penalty is warn amber, and the footer rule is inset to the card padding (critic on 55: score 3 of 5)',
   run:function(){
     if(typeof arcadeOverSync!=='function'||typeof ARCADE!=='object'||typeof arcadeEnter!=='function'||typeof arcadeAttStart!=='function') return 'SKIP: no RUN OVER card in this build';
     var res=null, sv=null, src0, tried0, c, a, lb, cs, cw, pd, bs, w0, zr, wr, hs;
     function q(cl){ return ATT.el?ATT.el.querySelector('.'+cl):null; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair};
       NET.bc={postMessage:function(){},close:function(){}}; NET.same='host'; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true;
       if(!arcadeEnter('host')) return 'SKIP: arcadeEnter(host) failed';
       arcadeAttStart();
       ARCADE.solo=true;
       ARCADE.over={at:Date.now()-5000,why:'menu',team:0,p1:{s:0,k:0,x:0,d:0},p2:null};
       arcadeAttShow(); c=q('arcover');
       if(!c||c.style.display==='none') return 'SKIP: the RUN OVER card did not come up';
       a=q('aos'); lb=a?a.querySelector('.aolb'):null;
       if(!lb) return 'the score word is not a label span over the figure ('+(a?a.textContent:'no hero')+')';
       if(!/SCORE/.test(a.textContent)) res='the hero lost its score word ('+a.textContent+')';
       else if(getComputedStyle(lb).display!=='block') res='the score label is '+getComputedStyle(lb).display+', not a block over the figure';
       else if(parseFloat(getComputedStyle(a).fontSize)<3*parseFloat(getComputedStyle(lb).fontSize)-0.5) res='the label is '+getComputedStyle(lb).fontSize+' under a '+getComputedStyle(a).fontSize+' figure';
       else if(!a.classList.contains('aoz')) res='a zero score is not dimmed';
       zr=getComputedStyle(a).color; wr=getComputedStyle(q('aost')?q('aost'):a).color;
       if(!res){ var aw=c.querySelector('.aoh .aow'); if(!aw||aw.textContent!=='-50%') res='the -50% penalty is not its own span'; else if(getComputedStyle(aw).color==='rgb(245, 183, 59)'?false:true) res='the penalty is '+getComputedStyle(aw).color+', not warn amber'; }
       if(!res){ cs=getComputedStyle(c); bs=/calc\(100% - ([\d.]+)px\)/.exec(cs.backgroundSize); pd=parseFloat(cs.paddingLeft);
         if(!bs||Math.abs(parseFloat(bs[1])-2*pd)>1.5) res='the footer rule is '+cs.backgroundSize+' wide, not inset by the card padding '+(2*pd); }
       if(!res){ ARCADE.over.team=4321; ARCADE.over.p1.s=4321; ARCADE.over.at=Date.now()-5000; c.removeAttribute('data-at'); arcadeAttShow(); a=q('aos');
         if(a.classList.contains('aoz')) res='a real score is dimmed'; else if(!/4,321/.test(a.textContent)) res='the score reads '+a.textContent; }
       return res;
     } finally {
       try{ ARCADE.over=null; }catch(_o){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ NET.bc=sv.bc; NET.same=sv.same; NET.pair=sv.pair; ATT.src=src0; ATT.tried=tried0; } }catch(_n){}
       __topClear();
     }
   }},
  {v:'31.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
