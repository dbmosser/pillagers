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

if ($s.Contains("  {v:'29.51',what:")) { throw "check 29.51 is in the fixture already" }

SubRx @'
  {v:'29.50',what:
'@ @'
  {v:'29.51',what:'the craft hold has a clear bar (dark track, solid fill, back to normal when it ends) and the bench crafts x5, x10 or Max in one 1-second hold, never more than the stash allows (his order 2026-10-15)',
   run:function(){
     if(typeof openTrader!=='function'||typeof renderCraftDetail!=='function'||typeof renderWork!=='function'||typeof craftHoldStep!=='function'||typeof craftHoldCancel!=='function'||!window.__P||!window.__hubEnter||!window.__showScreen) return 'SKIP: this fixture cannot reach the bench';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], P=__P(), md=document.getElementById('tradermodal'), keepStash=(P.stash||[]).slice(), keepQ=P._craftQty;
     function comps(){ var n=0; P.stash.forEach(function(k){ if(k==='comp') n++; }); return n; }
     function stock(){ P.stash=['scrap','scrap','scrap','scrap','scrap','scrap','scrap','scrap','scrap','wire','wire','wire','wire','wire','wire']; }
     function select(){
       renderWork();
       var rows=[].slice.call(document.querySelectorAll('#worklist .row')), ix=-1, i;
       for(i=0;i<rows.length;i++) if(rows[i].getAttribute('data-w')==='recipe:0') ix=i;
       if(ix<0) return null;
       P._craftSel=ix; renderCraftDetail(rows);
       return document.querySelector('#craftdetail .vbuy');
     }
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       P._craftQty=undefined; stock(); openTrader('craft');
       var b=select();
       if(!b) return 'SKIP: the bench drew no detail button for the Component Kit';
       if(b.disabled) return 'SKIP: with the parts in the stash the detail button is still disabled';
       // THE BAR: a dark track under a fill, readable text, all gone when it ends.
       b.onmousedown({button:0}); craftHoldStep(CRAFT_HOLD*0.5);
       var bg=String(b.style.backgroundImage||''), bc=String(b.style.backgroundColor||'');
       if(bg.indexOf('50%')<0) bad.push('at half the hold the fill is not 50% ("'+bg.slice(0,70)+'")');
       if(!bc||bg.indexOf('255, 192, 74')<0&&bg.indexOf('#ffc04a')<0) bad.push('the fill is not a solid amber over a dark track (colour "'+bc+'", image "'+bg.slice(0,70)+'")');
       if(bg.indexOf('0.55')>=0) bad.push('the fill is still the faint 55% amber');
       craftHoldCancel();
       if(b.style.backgroundImage||b.style.backgroundColor||b.style.boxShadow) bad.push('a cancelled hold left the bar look on the button');
       // THE CHIPS: x5 with parts for three kits asks for three, one hold, three kits.
       var chips=[].slice.call(document.querySelectorAll('#craftdetail .cqty button'));
       if(chips.length!==4) bad.push('the bench shows '+chips.length+' quantity chips with parts for three kits (want x1 x5 x10 Max)');
       else {
         chips[1].click(); b=document.querySelector('#craftdetail .vbuy');
         if(!/x3/.test(String(b&&b.textContent))) bad.push('x5 with parts for three reads "'+(b&&b.textContent)+'" (want x3)');
         var c0=comps(); b.onmousedown({button:0}); craftHoldStep(CRAFT_HOLD*0.6);
         if(comps()!==c0) bad.push('control: the multi hold crafted before it was full');
         craftHoldStep(CRAFT_HOLD*0.6);
         if(comps()-c0!==3) bad.push('one hold at x5 with three sets made '+(comps()-c0)+' (want 3)');
       }
       // THE PLAIN HOLD STILL MAKES ONE.
       P._craftQty=undefined; stock(); b=select();
       if(b){ var c1=comps(); b.onmousedown({button:0}); craftHoldStep(CRAFT_HOLD*1.1); if(comps()-c1!==1) bad.push('control: the x1 hold made '+(comps()-c1)); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ craftHoldCancel(); }catch(_cc){}
       try{ if(md) md.style.display=''; }catch(_md){}
       try{ var ms=document.querySelectorAll('.modal.on'); for(var j=0;j<ms.length;j++) ms[j].classList.remove('on'); }catch(_mm){}
       P.stash=keepStash; P._craftQty=keepQ;
       try{ saveProfile(); }catch(_sp){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'29.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
