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

if ($s.Contains("  {v:'35.13',what:")) { throw "check 35.13 is in the fixture already" }

SubRx @'
  {v:'35.12',what:
'@ @'
  {v:'35.13',what:'HOTBAR SWAP: the floor belt drags and swaps with the backpack shut, a gun moved to another key shows there only, a dimmed gun on the stash hotbar picks up, the stash hotbar icons are readable',
   run:function(){
     var bad=[], i, n, M, r, hb, cells, gh, img, sl;
     function fs(){ var g0=G, o; try{ G=hubBagState(); o=hotbarSlots(); } finally{ G=g0; } return o; }
     function onKeys(gk){ var s=fs(), o=[]; for(var q=0;q<s.length;q++) if(s[q]&&s[q].kind==='gun'&&!s[q].vacant&&(s[q].itemKey==='gun_'+gk||s[q].icon===gk)) o.push(q); return o; }
     function cell(ix){ var c=HUBBELT.cells||[]; for(var q=0;q<c.length;q++) if(c[q].i===ix) return c[q]; return null; }
     function drag(a,b){
       var A1=cell(a), B1=cell(b); if(!A1||!B1) return false;
       M.x=A1.x+A1.w/2; M.y=A1.y+A1.h/2;
       cv.dispatchEvent(new MouseEvent('mousemove',{bubbles:true,clientX:r.left+M.x,clientY:r.top+M.y}));
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true,clientX:r.left+M.x,clientY:r.top+M.y}));
       M.x=B1.x+B1.w/2; M.y=B1.y+B1.h/2;
       cv.dispatchEvent(new MouseEvent('mousemove',{bubbles:true,clientX:r.left+M.x,clientY:r.top+M.y}));
       window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,clientX:r.left+M.x,clientY:r.top+M.y}));
       return true;
     }
     try{
       __topClear(); __runPrep(); __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.equipped='smg'; P.equippedSec='none'; if((P.weapons||[]).indexOf('smg')<0) (P.weapons=P.weapons||[]).push('smg');
       P.kit=['medkit']; P.stash.push('medkit'); P.hotAssign={}; saveProfile();
       // (1) a gun put on key 7 shows on key 7 only
       P.hotAssign={6:'gun_smg'};
       n=onKeys('smg');
       if(n.length!==1||n[0]!==6) bad.push('smg bound to key 7 shows on keys '+n.map(function(x){ return slotKeyName(x); }).join(','));
       P.hotAssign={};
       // (2) the floor belt with the backpack shut: drag the smg to key 6, then a medkit onto it to swap
       __hubEnter(); [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });
       if(typeof hubBagOpen!=='undefined'&&hubBagOpen) bad.push('staging: the backpack is open');
       for(i=0;i<4;i++){ try{ __hubStep(1/60); }catch(_hs){} } try{ drawHubBelt(); }catch(_db){}   // the shim steps the floor; the belt is drawn by the real frame, so here by hand
       M=__mouse(); r=cv.getBoundingClientRect();
       if(!(HUBBELT.cells||[]).length) bad.push('staging: the floor belt drew no cells');
       else {
         n=onKeys('smg'); var from=n.length?n[0]:-1;
         if(from<0) bad.push('staging: the smg is not on the floor belt');
         else {
           var to=(from===5)?4:5;
           drag(from,to);
           if((P.hotAssign||{})[to]!=='gun_smg') bad.push('dragging the smg along the floor belt from key '+slotKeyName(from)+' to key '+slotKeyName(to)+' left '+JSON.stringify(P.hotAssign||{}));
           n=onKeys('smg'); if(n.length!==1||n[0]!==to) bad.push('after the drag the smg shows on keys '+n.map(function(x){ return slotKeyName(x); }).join(','));
           P.hotAssign[7]='medkit'; saveProfile();
           for(i=0;i<2;i++){ try{ __hubStep(1/60); }catch(_hs2){} } try{ drawHubBelt(); }catch(_db2){}
           drag(7,to);
           if((P.hotAssign||{})[to]!=='medkit'||(P.hotAssign||{})[7]!=='gun_smg') bad.push('dropping the medkit on the smg did not swap them: '+JSON.stringify(P.hotAssign||{}));
         }
       }
       if(typeof HUBFD!=='undefined'&&HUBFD) bad.push('the floor drag was left held after the release');
       // (3) the stash hotbar: the dimmed smg picks up and moves to key 8
       P.hotAssign={}; saveProfile();
       hb=document.getElementById('hub'); renderHub(); hb.classList.add('on');
       cells=document.querySelectorAll('#hotplanwrap [data-plan]'); gh=null;
       for(i=0;i<cells.length;i++) if(cells[i].getAttribute('data-ghost')==='gun_smg'){ gh=cells[i]; break; }
       if(!gh) bad.push('the dimmed smg on the stash hotbar has no pick up');
       else {
         if(gh.style.cursor!=='grab') bad.push('the dimmed smg on the stash hotbar does not pick up');
         var gix=+gh.getAttribute('data-plan');
         cells[7].__grabDrop('gun_smg','plan:'+gix);
         if((P.hotAssign||{})[7]!=='gun_smg') bad.push('moving the dimmed smg to key 8 left '+JSON.stringify(P.hotAssign||{}));
         n=onKeys('smg'); if(n.length!==1||n[0]!==7) bad.push('after the stash move the smg shows on keys '+n.map(function(x){ return slotKeyName(x); }).join(','));
       }
       // (4) the stash hotbar icons are readable
       renderHub(); var sl0=hb.getAttribute('data-slayout'); hb.setAttribute('data-slayout','1');   // a layout that held the icons at 30 px
       img=document.querySelector('#hotplanwrap [data-plan] .ic');
       if(!img) bad.push('staging: no icon on the stash hotbar');
       else if(!(parseFloat(getComputedStyle(img).width)>=46)) bad.push('stash hotbar icon is '+getComputedStyle(img).width+' wide');
       if(sl0===null) hb.removeAttribute('data-slayout'); else hb.setAttribute('data-slayout',sl0);
       if(String(hubFloorHints).indexOf("'MAP'")<0) bad.push('the floor key row does not name M');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(typeof HUBFD!=='undefined') HUBFD=null; }catch(_hf){}
       try{ var hb2=document.getElementById('hub'); if(hb2) hb2.classList.remove('on'); }catch(_h){}
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
