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

if ($s.Contains("  {v:'31.18',what:")) { throw "check 31.18 is in the fixture already" }

SubRx @'
  {v:'31.17',what:
'@ @'
  {v:'31.18',what:'cw-snip2, the F8 snip panel reads at a glance: copy is the shared primary button (lime fill) and save the shared secondary beside it, both at least 48 px high and 128 px wide with 16 px between them, the size tag is 16 px and sits clear above the frame without leaving the screen, and the dim outside the frame is .6',
   run:function(){
     if(typeof DEV_LOCAL==='undefined'||!DEV_LOCAL) return 'SKIP: not a local build, the snip tool is never here';
     if(typeof SNIP!=='object'||!SNIP) return 'SKIP: no snip tool in this build';
     var bad=[], sn0=SNIP.dom, W=window.innerWidth, H=window.innerHeight, pn, btns, cr, sr, cs, ss, sz, szr, bxe, br, pr, cb, sb;
     function press(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function rel(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     function mev(type,x,y){ (document.getElementById('snipov')||document.body).dispatchEvent(new MouseEvent(type,{clientX:x,clientY:y,button:0,buttons:type==='mouseup'?0:1,bubbles:true,cancelable:true,view:window})); }
     function drag(x0,y0,x1,y1){ mev('mousedown',x0,y0); mev('mousemove',(x0+x1)>>1,(y0+y1)>>1); mev('mousemove',x1,y1); mev('mouseup',x1,y1); }
     function esc(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true})); }
     function clear(c){ return c==='transparent'||/^rgba\(\s*0,\s*0,\s*0,\s*0\s*\)$/.test(String(c)); }
     try{
       SNIP.dom=0;   // the page layer is a picture of the page, which a check cannot wait for
       try{ if(window.__topClear) __topClear(); }catch(_t){}
       keys={}; mouse.down=false;
       if(SNIP.on) snipEnd('esc');
       press('F8'); rel('F8');
       if(!SNIP.on) return 'SKIP: F8 did not start a snip ('+(document.getElementById('snipov')?'overlay':'no overlay')+')';
       drag(200,150,440,330);
       pn=document.getElementById('snippanel'); sz=document.getElementById('snipsz'); bxe=document.getElementById('snipbox');
       if(!pn||!sz||!bxe) return 'no panel, size tag or frame after a drag';
       btns=[].slice.call(pn.querySelectorAll('button'));
       if(btns.length!==2||btns[0].textContent!=='copy'||btns[1].textContent!=='save') return 'the panel buttons are ['+btns.map(function(x){ return x.textContent; }).join(',')+'], not copy and save';
       cr=btns[0].getBoundingClientRect(); sr=btns[1].getBoundingClientRect(); cs=getComputedStyle(btns[0]); ss=getComputedStyle(btns[1]);
       if(cr.height<47.5||sr.height<47.5) bad.push('ONE: the buttons are '+Math.round(cr.height)+' and '+Math.round(sr.height)+' px high, not 48');
       if(cr.width<127.5||sr.width<127.5) bad.push('ONE: the buttons are '+Math.round(cr.width)+' and '+Math.round(sr.width)+' px wide, not 128');
       if(sr.left-cr.right<15.5) bad.push('ONE: the gap between copy and save is '+Math.round(sr.left-cr.right)+' px, not 16');
       if(!/\bui-btn\b/.test(btns[0].className)||!/\bpri\b/.test(btns[0].className)) bad.push('TWO: copy is not the shared primary button ('+btns[0].className+')');
       if(!/\bui-btn\b/.test(btns[1].className)||/\bpri\b/.test(btns[1].className)) bad.push('TWO: save is not the shared secondary button ('+btns[1].className+')');
       cb=cs.backgroundColor; sb=ss.backgroundColor;
       if(clear(cb)) bad.push('TWO: copy has no fill ('+cb+'), so it is not the main button');
       if(!clear(sb)) bad.push('TWO: save has a fill ('+sb+'), so two buttons compete');
       if(cs.color===cb) bad.push('TWO: the copy words are the same colour as its fill');
       szr=sz.getBoundingClientRect(); br=bxe.getBoundingClientRect();
       if(parseFloat(getComputedStyle(sz).fontSize)<15.5) bad.push('THREE: the size tag is '+getComputedStyle(sz).fontSize+', not 16px');
       if(szr.bottom>br.top-5.5) bad.push('THREE: the size tag (bottom '+Math.round(szr.bottom)+') is not clear above the frame (top '+Math.round(br.top)+')');
       if(String(getComputedStyle(bxe).boxShadow).replace(/\s+/g,'').indexOf('rgba(0,0,0,0.6)')<0) bad.push('FOUR: the dim outside the frame is not .6 ('+getComputedStyle(bxe).boxShadow+')');
       esc();
       if(SNIP.on) bad.push('FIVE: ESC did not end the snip');
       // a frame against the right edge keeps its size tag on the screen, and one against the top keeps it off the top
       press('F8'); rel('F8'); drag(W-130,300,W-6,380);
       sz=document.getElementById('snipsz');
       if(sz){ szr=sz.getBoundingClientRect(); if(szr.right>W+0.5||szr.left<-0.5) bad.push('FIVE: the size tag runs off the screen at the right edge ('+Math.round(szr.left)+' to '+Math.round(szr.right)+' of '+W+')'); }
       else bad.push('FIVE: no size tag at the right edge');
       esc();
       press('F8'); rel('F8'); drag(300,10,420,90);
       sz=document.getElementById('snipsz');
       if(sz){ szr=sz.getBoundingClientRect(); if(szr.top<-0.5) bad.push('FIVE: the size tag runs off the top of the screen'); }
       esc();
       // a small frame in the bottom right corner still gets a whole panel
       press('F8'); rel('F8'); drag(W-40,H-40,W-12,H-12);
       pn=document.getElementById('snippanel');
       if(!pn) bad.push('FIVE: no panel for a small frame in the corner');
       else{ pr=pn.getBoundingClientRect(); if(pr.left<-0.5||pr.top<-0.5||pr.right>W+0.5||pr.bottom>H+0.5) bad.push('FIVE: the panel is partly off the screen for a frame in the corner'); }
       esc();
       if(SNIP.on) bad.push('FIVE: the snip is still up at the end');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(SNIP.on) snipEnd('esc'); }catch(_s){}
       try{ SNIP.dom=sn0; }catch(_n){}
       try{ keys={}; mouse.down=false; }catch(_k){}
       try{ __topClear(); }catch(_tc){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
