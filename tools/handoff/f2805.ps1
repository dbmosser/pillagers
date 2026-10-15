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

if ($s.Contains("  {v:'28.05',what:")) { throw "check 28.05 is in the fixture already" }

SubRx @'
  {v:'28.04',what:
'@ @'
  {v:'28.05',what:'his order 2026-10-15 (career leaderboard): a CAREER extraction or death ends its run card on a LEADERBOARD step in the same card, the continue control opens it and then logs the run, ESC closes from the first step, an abandon has no step, and any other card is as it was',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof ocLbNext!=='function'||typeof careerBoardView!=='function') return 'the run card has no LEADERBOARD step (cboard3)';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, snap=null, oc=document.getElementById('outcome'), ob=document.getElementById('oc_btn'), bd=document.getElementById('oc_board'), man=document.getElementById('oc_manifest'), ws, n0, i;
     function raid(bag,on){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=on;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return false;
       g.player.iv=99; g.player.hp=100; g.player.downed=false;
       g.bag=bag.slice();
       return true;
     }
     function key(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true})); }
     function on(){ return oc.classList.contains('on'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       if(!oc||!ob||!bd||!man) return 'SKIP: no run card pieces in this page';
       // an extraction
       if(!raid(['scrap','board','optic','servo','core','medkit'],1)) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       P.careerBoard=[]; delete P.careerRuns; delete P.careerAll;
       g.cs.s=750; g.cs.k=4; g.cs.b={kill:750};
       __endRaid('extract');
       if(!on()) bad.push('the card is not up');
       if(ob.textContent.toLowerCase()!=='leaderboard') bad.push('the continue control reads "'+ob.textContent+'" on the first step, not LEADERBOARD');
       if(oc.classList.contains('lbs')) bad.push('the card opens on the board');
       key('Enter'); if(oc.classList.contains('lbs')) bad.push('the first ENTER (it lands the tally and the reveal) opened the board');
       key('Enter');
       if(!oc.classList.contains('lbs')) bad.push('ENTER after the reveal did not open the LEADERBOARD step');
       if(ob.textContent!=='Log run and return') bad.push('the continue control reads "'+ob.textContent+'" on the board');
       if(getComputedStyle(man).display!=='none') bad.push('the summary is still on screen under the board');
       if(getComputedStyle(bd).display==='none'||!bd.querySelector('.lbp')) bad.push('no board on the card');
       if(!bd.querySelector('.lbp .hl')||!bd.querySelector('.lbp .lbmove')) bad.push('this run is not the teal climbing row');
       if(bd.textContent.indexOf('RANK #1 OF 1')<0) bad.push('the readout is not RANK #1 OF 1 ('+bd.textContent.slice(0,60)+')');
       if(bd.textContent.indexOf('NEW PERSONAL BEST')<0) bad.push('a number one has no NEW PERSONAL BEST plate');
       if(bd.querySelectorAll('.lbp .apr').length!==2) bad.push('the board draws '+bd.querySelectorAll('.lbp .apr').length+' lines, not a header and one run');
       ob.click();
       if(on()) bad.push('the continue control on the board did not leave the card');
       if(oc.classList.contains('lbs')||ob.textContent!=='Log run and return'||bd.textContent!=='') bad.push('the card did not reset when it closed');
       // a death, closed with ESC from the first step
       if(!raid(['scrap','board','optic'],1)) return bad.concat(['SKIP: no second raid']).join('; ');
       P.careerBoard=[]; delete P.careerRuns; delete P.careerAll;
       g.cs.s=300; g.cs.k=1; g.cs.b={kill:300};
       __endRaid('dead');
       if(ob.textContent.toLowerCase()!=='leaderboard') bad.push('the KIA card continue control reads "'+ob.textContent+'"');
       key('Escape');
       if(on()){ key('Escape'); }
       if(on()) bad.push('ESC did not close the card from the first step');
       if(oc.classList.contains('lbs')||ob.textContent!=='Log run and return') bad.push('ESC left the board state on the card');
       if(!g.careerLb||g.careerLb.how!=='dead'||P.careerRuns!==1) bad.push('the death is not the one run on the board ('+P.careerRuns+')');
       // an abandon is not a run
       if(!raid(['scrap'],1)) return bad.concat(['SKIP: no third raid']).join('; ');
       g.tel.shots=3; g.cs.s=100;
       P.careerBoard=[]; delete P.careerRuns; delete P.careerAll;
       __endRaid('abandon');
       if(g.careerLb||P.careerRuns!==undefined||P.careerBoard.length) bad.push('an abandon counted as a board run');
       if(ob.textContent!=='Log run and return'||oc.classList.contains('lbs')) bad.push('an abandon card has a LEADERBOARD step');
       if(ocLbNext()) bad.push('an abandon card opened a board');
       // another card is as it was
       if(!raid(['scrap','board','optic'],0)) return bad.concat(['SKIP: no fourth raid']).join('; ');
       __endRaid('extract');
       if(ob.textContent!=='Log run and return') bad.push('a non-CAREER card continue control reads "'+ob.textContent+'"');
       if(ocLbNext()) bad.push('a non-CAREER card opened a board');
       // the hooks, by their source (needles are assembled)
       ws=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       if(ws.indexOf('PAD.focus.id==='+"'oc_btn'"+'&&ocLb'+'Next()')<0) bad.push('the pad A does not open the board');
       if(ws.indexOf('md.id==='+"'outcome'"+'&&document.getElementById('+"'oc_btn'"+')) document.getElementById('+"'oc_btn'"+').click()')<0) bad.push('the pad B does not press the continue control');
       if(ws.indexOf('ev.isTrusted'+'||!OC'+'LB')<0) bad.push('a real click on the continue control does not open the board');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ CAREER_ON=c0; }catch(_r){}
       try{ ocLbEnd(); }catch(_e0){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ oc.classList.remove('on'); }catch(_c){}
       try{ if(snap) __applyLoaded(snap); }catch(_s){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
