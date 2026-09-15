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

SubRx @'
  {v:'15.02',what:
'@ @'
  {v:'15.03',what:'the Limited Time Offer card keeps time while the panel is open: drawing it with the panel up arms a redraw for just past the moment its minute turns, that redraw turns 2 minutes into 1 minute and a bought card into the next item with its Buy button, and with the panel closed the redraw leaves the card alone and arms nothing more (wirt audit finding)',
   run:function(){
     if(typeof renderGamble!=='function'||typeof renderWirtLot!=='function'||typeof openModal!=='function'||typeof wirtLotHour!=='function'||typeof wirtLotKey!=='function'||typeof WIRT_LOT_MS!=='number'||!window.__P) return 'SKIP: no Wirt lot in this build';
     var gm=document.getElementById('gamblemodal'), wl=document.getElementById('wirtlot');
     if(!gm||!wl) return 'SKIP: the Wirt panel or its lot card is not in this page';
     var bad=[], q=__P(), realNow=Date.now, realST=window.setTimeout, keepB=q.wirtLotBought, hadV=('vline' in q), keepV=q.vline?JSON.parse(JSON.stringify(q.vline)):q.vline;
     var W=WIRT_LOT_MS, fake=0;
     function card(){ return String(wl.textContent||'').replace(/\s+/g,' '); }
     // Run fn with setTimeout recorded and not armed: what the card arms is the redraw a real timer would run.
     function rec(fn){ var got=[]; window.setTimeout=function(f,ms){ got.push({fn:f,ms:+ms||0}); return 0; }; try{ fn(); }finally{ window.setTimeout=realST; } return got; }
     function fits(a,due){ return !!(a&&typeof a.fn==='function'&&a.ms>=due&&a.ms<=due+1000); }
     try{
       __topClear();
       // The clock sits 60.5 seconds before the current window turns, where the card reads 2 minutes.
       var edge=(Math.floor(realNow()/W)+1)*W;
       fake=edge-60500;
       Date.now=function(){ return fake; };
       q.wirtLotBought=-1;
       renderGamble(); openModal('gamblemodal');
       var armed=rec(renderWirtLot);
       // CONTROL: the panel is up and the stubbed clock reached the card.
       if(!gm.classList.contains('on')) return 'SKIP: the Wirt panel did not open here';
       var t0=card();
       if(!(/(^|[^0-9])2 minutes/).test(t0)) return 'SKIP: with the clock 60.5 seconds before the window turns the card read: '+t0.slice(0,100);
       if(!armed.length) return 'with the panel open, drawing the Limited Time Offer card arms nothing to redraw it, so it reads 2 minutes until the panel is opened again and a bought card never shows the next item';
       // The minute turns in 500 ms: the redraw must be due then, up to a second late.
       var a=armed[armed.length-1];
       if(!fits(a,500)) return 'with the minute turning in 500 ms the card arms its redraw for '+a.ms+' ms, not just past the turn';
       fake+=a.ms;
       var again=rec(a.fn);
       var t1=card();
       if(!(/(^|[^0-9])1 minute(?!s)/).test(t1)) bad.push('with the panel open, the redraw after the minute turned leaves the card reading '+t1.slice(0,80)+' where it should read 1 minute');
       if(!again.length) bad.push('the redraw at 1 minute arms no further redraw, so the window turn never draws the next item');
       // A BOUGHT CARD half a second before the window turns has no Buy button.
       fake=edge-500;
       q.wirtLotBought=wirtLotHour();
       var ab=rec(renderWirtLot);
       if(wl.querySelector('#wirtlotbtn')||!(/Bought/).test(card())) return 'SKIP: the lot marked bought did not draw as bought here: '+card().slice(0,80);
       var nxt=wirtLotKey(edge+500);
       if(!nxt||!nxt.length||!ITEMS[nxt[0]]) return 'SKIP: the next window holds no item to show';
       var b=ab[ab.length-1];
       if(!fits(b,500)){ bad.push('with the window turning in 500 ms a bought card arms '+(b?('its redraw for '+b.ms+' ms'):'no redraw')+', so the next item and its Buy button do not draw when it turns'); return bad.join('; '); }
       fake+=b.ms;
       var nx=rec(b.fn);
       if(!wl.querySelector('#wirtlotbtn')||(/Bought/).test(card())) bad.push('with the panel open, after the window turned a bought card still reads '+card().slice(0,80)+' with no Buy button for the next item');
       // A CLOSED PANEL: the next armed redraw leaves the card as it was and arms nothing more.
       var c=nx[nx.length-1];
       if(!(c&&typeof c.fn==='function')) bad.push('the redraw after the window turned arms no further redraw, so the new card stops keeping time');
       else{
         var t3=card();
         gm.classList.remove('on');
         fake+=c.ms;
         var more=rec(c.fn);
         if(card()!==t3) bad.push('with the panel closed the armed redraw still redrew the card');
         if(more.length) bad.push('with the panel closed the armed redraw armed another, so its timer keeps running with nothing on screen');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       Date.now=realNow; window.setTimeout=realST;
       try{ q.wirtLotBought=keepB; if(hadV) q.vline=keepV; else delete q.vline; }catch(_r){}
       try{ gm.classList.remove('on'); if(typeof wirtLotTick==='function') wirtLotTick(); }catch(_t){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
