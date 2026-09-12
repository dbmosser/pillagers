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

# v12.98 CHECK, inserted before the v12.97 entry.
#
# IT ASSERTS NO PERCENTAGE OF ITS OWN. It reads what the payout function returns and
# requires every screen to show that and nothing else, so the dial can move without
# this row going stale, and a build that changed the rate in one place and not the
# others still fails.
#
# THE MIXED CASE IS THE FINDING: six of each. With one drink every basis agrees and
# nothing is measurable, which is why the old check was green over this for a year.
#
# CONTROLS. A single drink must still show its own dose count, or the rows have been
# gutted rather than corrected. And the payout itself must be untouched at five doses
# and at twelve, because no number moves in this build.
SubRx @'
  {v:'12.97',what:'a restore code carries net lifetime earnings
'@ @'
  {v:'12.98',what:'THE LAST POUR shows the one bonus it actually pays: six Liquor and six Blotter no longer print a share each that reads as a sum no raid honours, the gate stops selling at ten of anything rather than ten of each, and the payout itself is unchanged (audit finding 16, 2026-09-11)',
   run:function(){
     if(typeof renderBar!=='function'||typeof buzzXpMul!=='function'||typeof buzzDoses!=='function')
       return 'SKIP: this fixture has no bar to render';
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     var bad=[], P2=__P(), keepBuzz=(P2.buzz||[]).slice(), keepCr=P2.credits;
     function dose(tag,k){ for(var i=0;i<k;i++) P2.buzz.push({id:tag,tag:tag,t:180,dur:180}); }
     function barText(){
       try{ renderBar(); }catch(_r){}
       var a=document.getElementById('bar_line'), b=document.getElementById('barlist');
       return (((a&&a.textContent)||'')+' '+((b&&b.textContent)||''));
     }
     // Every percentage the screens are allowed to show, taken off the payout rather
     // than written down here.
     function pct(){ return Math.round((buzzXpMul()-1)*1000)/10; }
     try{
       __topClear(); __resetCfg(); __cleanProfile();
       P2.credits=1000000;
       // THE MIXED CASE. With one drink every basis agrees; this is the one that
       // separates a per-drink share from the bonus that is paid.
       P2.buzz=[]; dose('drunk',6); dose('lsd',6);
       var paid=pct(), txt=barText();
       if(txt.indexOf('+'+paid+'%')<0)
         bad.push('with six of each drink in him the bar never shows the bonus the raid will actually pay, which is +'+paid+'%');
       // Any OTHER percentage on those screens is a figure the game will not credit.
       var seen=String(txt).match(/\+\d+(\.\d+)?%/g)||[], si, wrong=[];
       for(si=0;si<seen.length;si++) if(seen[si]!=='+'+paid+'%') wrong.push(seen[si]);
       if(wrong.length)
         bad.push('the bar shows '+wrong.join(' and ')+' beside a raid that pays +'+paid+'%: each drink printed its own share of a bonus that counts both kinds together and stops at ten, so two rows read as a sum nothing honours');
       // THE GATE. Ten of anything, which is what the line above the rows says.
       var bl=document.getElementById('barlist');
       var btns=bl?bl.querySelectorAll('[data-bz]'):[];
       if(!btns.length) bad.push('control: the bar drew no drink buttons, so the gate cannot be read');
       else {
         P2.buzz=[]; dose('drunk',10);
         barText();
         var live=0, bq;
         btns=document.getElementById('barlist').querySelectorAll('[data-bz]');
         for(bq=0;bq<btns.length;bq++) if(!btns[bq].disabled) live++;
         if(live)
           bad.push('with ten doses already in him the bar will still sell '+live+' more kind'+(live===1?'':'s')+', because the limit is counted per drink while the line above the rows promises ten and the bonus counts them together: twenty doses sold under a cap of ten');
       }
       // CONTROL: a single drink still shows what is in him.
       P2.buzz=[]; dose('drunk',2);
       var t2=barText();
       if(t2.indexOf('\u00d72')<0&&t2.indexOf('x2')<0)
         bad.push('control: two doses of one drink no longer show as two in his blood, so the rows have been gutted rather than corrected');
       if(t2.indexOf('+'+pct()+'%')<0)
         bad.push('control: with two doses of one drink the bar shows no bonus at all');
       // CONTROL: NO NUMBER MOVES. Five doses and twelve, straight off the payout.
       P2.buzz=[]; dose('drunk',5);
       var m5=buzzXpMul();
       P2.buzz=[]; dose('drunk',7); dose('lsd',5);
       var m12=buzzXpMul();
       if(Math.abs(m5-(1+5*buzzXpPer()))>1e-9)
         bad.push('control: five doses no longer pay five doses worth, so a dial has moved in a build that moves none');
       if(Math.abs(m12-(1+10*buzzXpPer()))>1e-9)
         bad.push('control: twelve doses no longer stop at ten, so the cap itself has moved');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.buzz=keepBuzz; P2.credits=keepCr; saveProfile(); renderBar(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.97',what:'a restore code carries net lifetime earnings
'@

# v9.96's bar-text arm read the PER-DRINK percentage off the row, which v12.98 moves
# to the bar line as one figure for both drinks. The assertion is re-pointed rather
# than dropped: it still requires the bar to say what two doses are worth, and it is
# still two doses of one kind, where the old basis and the new one agree.
SubRx @'
     // The bar says so. Two doses of liquor: IN YOUR BLOOD x2, XP +10%.
     if(typeof renderBar==='function'){
       try{ renderBar(); }catch(e2){}
       var bl=document.getElementById('barlist'), bt=(bl&&bl.textContent)||'';
       if(bt.indexOf('XP +5%')<0) bad.push('the bar does not say XP +5% beside two doses of liquor');
     }
'@ @'
     // The bar says so. Two doses of liquor: IN YOUR BLOOD x2, and the bonus.
     // v12.98: the bonus counts both drinks together, so it is printed once on the
     // bar line rather than as a share on each row; with two doses of one kind the
     // figure is the same either way, which is why this arm still reads 5%.
     if(typeof renderBar==='function'){
       try{ renderBar(); }catch(e2){}
       var bl=document.getElementById('barlist'), bln=document.getElementById('bar_line');
       var bt=((bl&&bl.textContent)||'')+' '+((bln&&bln.textContent)||'');
       if(bt.indexOf('XP +5%')<0) bad.push('the bar does not say XP +5% beside two doses of liquor');
     }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
