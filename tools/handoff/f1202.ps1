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

# v11.94 CHECK, inserted before the v11.93 entry. The real bench: the
# Component Kit recipe selected, its cream detail button pressed three ways.
SubRx @'
  {v:'11.93',what:'taking the freebie kit keeps what was packed aside and USE MY OWN GEAR puts the packing and the belt plan back, minus anything sold in between (2026-09-06 menu audit)',
'@ @'
  {v:'11.94',what:'the bench detail button crafts on a synthetic click (a pad press) and on a hold, spends nothing on a real mouse click, and a hold dies when the trader window is hidden (2026-09-06 review of v11.75)',
   run:function(){
     if(typeof openTrader!=='function'||typeof renderCraftDetail!=='function'||typeof craftHoldStep!=='function'||!window.__P||!window.__hubEnter) return 'SKIP: this fixture cannot reach the bench';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], P=__P(), md=document.getElementById('tradermodal'), keepStash=(P.stash||[]).slice();
     function stock(){ P.stash=['scrap','scrap','scrap','wire','wire']; }
     function select(){
       renderWork();
       var rows=[].slice.call(document.querySelectorAll('#worklist .row')), ix=-1;
       for(var i=0;i<rows.length;i++) if(rows[i].getAttribute('data-w')==='recipe:0') ix=i;
       if(ix<0) return null;
       P._craftSel=ix; renderCraftDetail(rows);
       return document.querySelector('#craftdetail .vbuy');
     }
     function crafted(){ return P.stash.indexOf('comp')>=0; }
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       stock(); openTrader('craft');
       var b=select(); if(!b) return 'SKIP: the bench drew no detail button for the Component Kit';
       if(b.disabled) bad.push('control: with the parts in the stash the detail button is disabled');
       // ONE: a synthetic click (what the pad and Enter send) crafts.
       b.click();
       if(!crafted()) bad.push('a synthetic click on the detail button crafted nothing (a pad or Enter cannot craft)');
       // TWO: a real mouse click spends nothing.
       stock(); b=select();
       if(b){ b.dispatchEvent(new MouseEvent('click',{detail:1,bubbles:true})); if(crafted()) bad.push('a real mouse click crafted; the hold is meant to be the only mouse way'); }
       // THREE: the hold still crafts.
       stock(); b=select();
       if(b&&b.onmousedown){ b.onmousedown({button:0}); craftHoldStep(0.6); if(crafted()) bad.push('control: the hold crafted before it was full'); craftHoldStep(0.6); if(!crafted()) bad.push('control: a full hold crafted nothing'); }
       else bad.push('control: the detail button has no hold to drive');
       // FOUR: a hold dies when the window is hidden.
       stock(); b=select();
       if(b&&b.onmousedown&&md){ b.onmousedown({button:0}); craftHoldStep(0.3); md.style.display='none'; craftHoldStep(1.2); md.style.display=''; if(crafted()) bad.push('a hold outlived the trader window being hidden and spent the parts'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(md) md.style.display=''; craftHoldCancel(); try{ openTrader('buy'); }catch(_ob){} var ms=document.querySelectorAll('.modal.on'); for(var j=0;j<ms.length;j++) ms[j].classList.remove('on'); P.stash=keepStash; saveProfile(); }catch(_c){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.93',what:'taking the freebie kit keeps what was packed aside and USE MY OWN GEAR puts the packing and the belt plan back, minus anything sold in between (2026-09-06 menu audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
