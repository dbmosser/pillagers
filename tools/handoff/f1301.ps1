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

# v13.01 CHECK, inserted before the v13.00 entry.
#
# IT RENDERS THE SCREEN AND READS WHAT IS ON IT. A source search cannot answer this:
# most of these lines are built at run time out of pieces, so the finished sentence
# only exists once a panel has been drawn, and the lookup that applies his wording is
# an exact match on that finished sentence.
#
# THE KEY IS NOT WRITTEN INTO THIS CHECK. It is taken from his own baked map, so if he
# edits that line again the check follows him rather than pinning last week's wording.
#
# THE CONTROL IS THE NUMBER. v12.98 put a live total on that screen and it must still
# be there and still be right: restoring his sentence must not cost the reading that
# build added, or this is a revert wearing a fix's clothes.
SubRx @'
  {v:'13.00',what:'the text rewriter reads what is on screen
'@ @'
  {v:'13.01',what:'the bar blurb he rewrote still shows his words: the sentence is matched whole, so nothing may be added to it or joined onto it, and the live dose total lives on its own line where changing it cannot cost him a sentence (my own defect from v12.98, found 2026-09-12)',
   run:function(){
     if(typeof renderBar!=='function') return 'SKIP: this fixture has no bar to render';
     if(!(window.__tx&&window.__tx.ship)) return 'SKIP: this fixture cannot read his baked edits';
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     var M=null; try{ M=__tx.ship(); }catch(_m){}
     if(!M) return 'SKIP: his baked edits are not readable here';
     // HIS OWN KEY, not one written down here: the entry whose text names this line.
     var key=null, k;
     for(k in M) if(k.indexOf('No tab, no credit')===0){ key=k; break; }
     if(!key) return 'SKIP: he has no baked edit for the bar line, so there is nothing of his to lose';
     var want=String(M[key]||'');
     if(!want.replace(/\s+/g,'').length) return 'SKIP: his edit for that line is blank, so nothing visible is expected';
     var bad=[], P2=__P(), keepBuzz=(P2.buzz||[]).slice(), keepCr=P2.credits, keepTxt=P2.txt;
     try{
       __topClear(); __resetCfg(); __cleanProfile();
       // His edits apply through the profile switch that turns them on.
       P2.credits=1000000; P2.buzz=[];
       try{ renderBar(); }catch(_r){}
       var bl=document.getElementById('bar_line'), got=((bl&&bl.textContent)||'');
       if(got.indexOf(want)<0)
         bad.push('the bar line does not say what he wrote for it. He edited that sentence and the replacement is matched on the WHOLE line, so a word added to it or a number joined onto the end of it takes his wording off the screen without a sound. It reads ['+got.slice(0,120)+'] where he wrote ['+want.slice(0,60)+']');
       // CONTROL: THE LIVE READING v12.98 ADDED IS STILL THERE AND STILL RIGHT, so
       // giving him his sentence back has not quietly reverted that build.
       for(var d=0;d<3;d++) P2.buzz.push({id:'drunk',tag:'drunk',t:180,dur:180});
       try{ renderBar(); }catch(_r2){}
       var nowEl=document.getElementById('bar_now');
       var all=((bl&&bl.textContent)||'')+' '+((nowEl&&nowEl.textContent)||'');
       var paid=Math.round((buzzXpMul()-1)*1000)/10;
       if(all.indexOf('+'+paid+'%')<0)
         bad.push('control: with three doses in him the bar no longer shows the bonus the raid will pay, so his sentence was given back by taking away the reading v12.98 added');
       if(all.indexOf('3 dose')<0)
         bad.push('control: with three doses in him the bar no longer says how many are in his blood');
       // AND HIS SENTENCE SURVIVES THE NUMBER APPEARING, which is the whole point:
       // the number is a separate string, so it cannot break the match.
       if(((bl&&bl.textContent)||'').indexOf(want)<0)
         bad.push('his wording disappears again as soon as the live total is on screen, so the number is still being joined onto the line he edited');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.buzz=keepBuzz; P2.credits=keepCr; P2.txt=keepTxt; renderBar(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.00',what:'the text rewriter reads what is on screen
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
