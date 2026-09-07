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

# v12.31 CHECK, inserted before the v12.30 entry. Staged the way check 12.17
# stages the bench (recipe:0 is the Component Kit, parts scrap x3 and wire x2,
# and a craft puts comp in the stash). It reads the button label, sends a REAL
# mouse click and requires a spoken line with nothing spent, starts a hold and
# releases it early through the real window mouseup and requires a spoken line,
# and keeps the two paths that must still work: a synthetic click crafts (the
# pad rule, v12.17) and a full hold crafts.
SubRx @'
  {v:'12.30',what:'the trigger never dies on a blanked belt cell 1: with the gun in hand bound to key 5 a click on the blank cell selects the gun cell and yields, the next click fires, and the empty-throwable yield lands on the gun cell rather than the blank (2026-09-07 audit P1)',
'@ @'
  {v:'12.31',what:'the bench button says to hold it, a real mouse click on it says so and spends nothing, letting go early says so, and a synthetic click and a full hold still craft (his note of 2026-09-07: the crafting bar does not work and nothing can be crafted)',
   run:function(){
     if(typeof openTrader!=='function'||typeof renderCraftDetail!=='function'||typeof renderWork!=='function'||typeof craftHoldStep!=='function'||typeof craftHoldCancel!=='function'||!window.__P||!window.__hubEnter||!window.__showScreen) return 'SKIP: this fixture cannot reach the bench';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], P=__P(), md=document.getElementById('tradermodal'), keepStash=(P.stash||[]).slice(), keepSay=(typeof HUBSAY!=='undefined')?HUBSAY:null;
     function stock(){ P.stash=['scrap','scrap','scrap','wire','wire']; }
     function crafted(){ return P.stash.indexOf('comp')>=0; }
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
       stock(); openTrader('craft');
       var b=select();
       if(!b) return 'SKIP: the bench drew no detail button for the Component Kit';
       if(b.disabled) return 'SKIP: with the parts in the stash the detail button is still disabled';
       // ONE, THE LABEL: it has to say what to do with it.
       var lab=(b.textContent||'').toUpperCase();
       if(lab.indexOf('HOLD')<0) bad.push('the bench button reads "'+(b.textContent||'')+'", which does not say it has to be held');
       // TWO, THE REAL CLICK: spends nothing, his v11.75 rule, and now says why.
       HUBSAY=''; b.dispatchEvent(new MouseEvent('click',{detail:1,bubbles:true}));
       if(crafted()) bad.push('control: a real mouse click crafted, which his v11.75 order forbids');
       if(!/[Hh]old/.test(String(HUBSAY||''))) bad.push('a real mouse click on the bench button said "'+String(HUBSAY||'')+'", which does not tell him to hold it');
       // THREE, LETTING GO EARLY: through the real window mouseup, which is what his hand does.
       stock(); b=select();
       if(b&&b.onmousedown){
         HUBSAY=''; b.onmousedown({button:0}); craftHoldStep(0.4);
         window.dispatchEvent(new MouseEvent('mouseup',{bubbles:true}));
         if(crafted()) bad.push('control: letting go at 0.4 s crafted anyway');
         if(!/[Ss]oon|[Hh]old/.test(String(HUBSAY||''))) bad.push('letting go before the second was up said "'+String(HUBSAY||'')+'", so an early release is still silent');
       } else bad.push('control: the bench button has no hold to drive');
       // FOUR, THE TWO PATHS THAT MUST STILL WORK.
       stock(); b=select();
       if(b){ b.click(); if(!crafted()) bad.push('control: a synthetic click (the pad and Enter) no longer crafts'); }
       stock(); b=select();
       if(b&&b.onmousedown){ b.onmousedown({button:0}); craftHoldStep(0.6); if(crafted()) bad.push('control: the hold crafted before it was full'); craftHoldStep(0.6); if(!crafted()) bad.push('control: a full hold crafted nothing'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ craftHoldCancel(); }catch(_cc){}
       try{ if(md) md.style.display=''; }catch(_md){}
       try{ var ms=document.querySelectorAll('.modal.on'); for(var j=0;j<ms.length;j++) ms[j].classList.remove('on'); }catch(_mm){}
       P.stash=keepStash; if(keepSay!==null){ try{ HUBSAY=keepSay; }catch(_hs){} }
       try{ saveProfile(); }catch(_sp){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.30',what:'the trigger never dies on a blanked belt cell 1: with the gun in hand bound to key 5 a click on the blank cell selects the gun cell and yields, the next click fires, and the empty-throwable yield lands on the gun cell rather than the blank (2026-09-07 audit P1)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
