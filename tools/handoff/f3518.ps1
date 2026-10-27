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

if ($s.Contains("  {v:'35.18',what:")) { throw "check 35.18 is in the fixture already" }

SubRx @'
  {v:'35.17',what:
'@ @'
  {v:'35.18',what:'UNDERCROFT FIXES: the pack list keeps its scroll, the floor zoom and camera behave, a floor belt drag cannot go stale, two guns trade keys, a dimmed gun stays in hand',
   run:function(){
     var bad=[], i, n, M, r, sty=null, said=[], s2=say2, keepT=null, tr=[];
     function fs(){ var g0=G, o; try{ G=hubBagState(); o=hotbarSlots(); } finally{ G=g0; } return o; }
     function onKeys(gk){ var s=fs(), o=[]; for(var q=0;q<s.length;q++) if(s[q]&&s[q].kind==='gun'&&!s[q].vacant&&(s[q].itemKey==='gun_'+gk||s[q].icon===gk)) o.push(q); return o; }
     function cell(ix){ var c=HUBBELT.cells||[]; for(var q=0;q<c.length;q++) if(c[q].i===ix) return c[q]; return null; }
     function at(C){ M.x=C.x+C.w/2; M.y=C.y+C.h/2; }
     function ev(t,o,b){ (o||cv).dispatchEvent(new MouseEvent(t,{button:(b===undefined?0:b),bubbles:true,cancelable:true,clientX:r.left+M.x,clientY:r.top+M.y})); }
     function press(ix){ var C=cell(ix); if(!C) return false; at(C); ev('mousemove'); ev('mousedown'); return true; }
     function away(){ M.x=r.width/2; M.y=r.height*0.3; ev('mousemove'); }
     function redraw(){ for(var q=0;q<2;q++){ try{ __hubStep(1/60); }catch(_hs){} } try{ drawHubBelt(); }catch(_db){} }
     function floor(){ __hubEnter(); [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); }); redraw(); M=__mouse(); r=cv.getBoundingClientRect(); }
     try{
       __topClear(); __runPrep(); __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
       say2=function(t){ said.push(String(t)); try{ return s2.apply(this,arguments); }catch(_s){} };
       // (1) the pack list keeps its scroll at the bottom when a row is packed
       P.kitPick='mine'; P.kit=[]; P.hotAssign={};
       var ks=Object.keys(ITEMS), added=0;
       for(i=0;i<ks.length&&added<40;i++){ var it=ITEMS[ks[i]]; if(!it||ks[i].indexOf('gun_')===0||!it.use) continue; P.stash.push(ks[i],ks[i]); added++; }
       saveProfile(); renderSector(); openModal('sectormodal'); syncSectorKit();
       var ls=document.querySelector('#sectormodal .srplist');
       if(!ls) bad.push('staging: no pack list');
       else if(ls.scrollHeight-ls.clientHeight<150) bad.push('staging: the pack list does not scroll far ('+ls.scrollHeight+'/'+ls.clientHeight+')');
       else if(!document.getElementById('sectorplan')) bad.push('staging: no belt strip under the pack list');
       else {
         ls.scrollTop=ls.scrollHeight; var s0=ls.scrollTop, rows=ls.querySelectorAll('.srprow[data-pk] [data-pd="1"]'), pb=null;
         for(i=rows.length-1;i>=0&&!pb;i--) if(!rows[i].classList.contains('dis')) pb=rows[i];
         if(!pb) bad.push('staging: no row to pack');
         else {
           pb.click();
           var ls2=document.querySelector('#sectormodal .srplist');
           if(!ls2) bad.push('the pack list is gone after packing');
           else if(Math.abs(ls2.scrollTop-s0)>2) bad.push('packing a row at the bottom moved the pack list from '+s0+' to '+ls2.scrollTop);
         }
       }
       try{ document.getElementById('sectormodal').classList.remove('on'); }catch(_sm){}
       P.kit=[]; P.hotAssign={}; saveProfile();
       // (2) the character screen over the floor eases the zoom back out
       floor();
       HZT=2.2; HZC=2.2;
       var tt=document.getElementById('title'); keepT=tt&&tt.classList.contains('on');
       if(tt){ tt.classList.add('on'); hubZoomEase(); if(HZT!==1) bad.push('the floor stays zoomed in under the character screen'); if(!keepT) tt.classList.remove('on'); }
       // (3) the zoomed floor camera sits on screen pixels and follows him to within half a pixel
       HZT=2.2; HZC=2.2; HB.player.x=350.37; HB.player.y=230.41;
       wc.translate=function(a,b){ tr.push([a,b]); return CanvasRenderingContext2D.prototype.translate.apply(this,arguments); };
       try{ drawHubWorld(0); }finally{ delete wc.translate; }
       var Sx=hubScale(), sd=Sx*(DPR||1), ex=hubCam(HB.player.x-(W/Sx)/2,W/Sx,HUBW), ox=null;
       for(i=0;i<tr.length;i++) if(Math.abs(-tr[i][0]-ex)<1.5){ ox=-tr[i][0]; break; }
       if(ox===null) bad.push('staging: the floor camera translate was not seen');
       else if(Math.abs(ox*sd-Math.round(ox*sd))>1e-6||Math.abs(ox-ex)>0.5/sd+1e-9) bad.push('the zoomed floor camera is off by '+(Math.abs(ox-ex)*sd).toFixed(2)+' screen px');
       HZT=1; HZC=1;
       // (4) a floor belt drag cannot go stale: let go with the keys, when the backpack opens, and not dropped by a right release
       P.kit=['medkit']; if(P.stash.indexOf('medkit')<0) P.stash.push('medkit'); P.hotAssign={4:'medkit'}; saveProfile();
       floor();
       if(!cell(4)) bad.push('staging: the floor belt drew no key 5');
       else {
         press(4);
         if(!(typeof HUBFD!=='undefined'&&HUBFD&&HUBFD.st&&HUBFD.st.drag)) bad.push('staging: pressing key 5 picked nothing up');
         else {
           releaseAllKeys(true);
           if(HUBFD) bad.push('the floor belt drag survived focus loss');
           away(); ev('mouseup',window);
           if((P.hotAssign||{})[4]!=='medkit') bad.push('a click after focus loss unbound key 5: '+JSON.stringify(P.hotAssign||{}));
           P.hotAssign={4:'medkit'}; saveProfile(); floor();
           press(4); hubBagOpenSet(true);
           if(HUBFD) bad.push('the floor belt drag survived the backpack opening');
           hubBagOpenSet(false); P.hotAssign={4:'medkit'}; saveProfile(); floor();
           press(4); away(); ev('mouseup',window,2);
           if((P.hotAssign||{})[4]!=='medkit') bad.push('a right release dropped the floor belt drag: '+JSON.stringify(P.hotAssign||{}));
           releaseAllKeys(true);
         }
       }
       // (5) two guns in his hands trade keys, and stay in his hands; one gun takes the empty second weapon key
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.kit=[]; P.hotAssign={}; saveProfile();
       floor();
       var ra=onKeys('rifle'), sa=onKeys('smg');
       if(ra.length!==1||sa.length!==1) bad.push('staging: the floor belt shows rifle on '+ra+' and smg on '+sa);
       else {
         press(ra[0]); at(cell(sa[0])); ev('mousemove'); ev('mouseup',window);
         if(P.equipped!=='rifle'||P.equippedSec!=='smg') bad.push('dragging the rifle onto the smg changed the guns in his hands to '+P.equipped+' and '+P.equippedSec);
         var ra2=onKeys('rifle'), sa2=onKeys('smg');
         if(!(ra2.length===1&&ra2[0]===sa[0]&&sa2.length===1&&sa2[0]===ra[0])) bad.push('dragging the rifle onto the smg did not trade their keys (rifle on '+ra2+', smg on '+sa2+')');
       }
       P.weapons=['rifle']; P.equipped='rifle'; P.equippedSec='none'; P.hotAssign={}; saveProfile();
       floor();
       var s1=fs(), gb=-1; ra=onKeys('rifle');
       for(i=0;i<s1.length;i++) if(s1[i]&&s1[i].k==='gunB') gb=i;
       if(gb<0||ra.length!==1) bad.push('staging: no empty second weapon key beside the rifle');
       else {
         said.length=0; press(ra[0]); at(cell(gb)); ev('mousemove'); ev('mouseup',window);
         ra=onKeys('rifle');
         if(ra.length!==1||ra[0]!==gb) bad.push('one gun dropped on the empty second weapon key did not move there (rifle on '+ra+')');
       }
       // (6) a dimmed gun from the stash belt dropped on the stash, the backpack or DROP HERE stays in his hands and says so
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={}; P.kit=[]; saveProfile();
       renderHub(); document.getElementById('hub').classList.add('on');
       var gc=document.querySelector('#hotplanwrap [data-ghost="gun_rifle"]');
       if(!gc) bad.push('staging: no dimmed rifle on the stash belt');
       else {
         var gix=+gc.getAttribute('data-plan'), zs=['stashgrid','kitcol','floordrop'];
         for(i=0;i<zs.length;i++){
           var z=document.getElementById(zs[i]);
           if(!z||typeof z.__grabDrop!=='function'){ bad.push('staging: no drop target '+zs[i]); continue; }
           said.length=0; z.__grabDrop('gun_rifle','plan:'+gix);
           if(P.equipped!=='rifle') bad.push('the dimmed rifle dropped on '+zs[i]+' left his hands');
           if(!said.some(function(t){ return /unequip/i.test(t); })) bad.push('the dimmed rifle dropped on '+zs[i]+' said '+(said.length?('"'+said.join(' / ')+'"'):'nothing'));
           renderHub();
         }
       }
       document.getElementById('hub').classList.remove('on');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ say2=s2; }catch(_a){}
       try{ delete wc.translate; }catch(_w){}
       try{ HZT=1; HZC=1; }catch(_hz){}
       try{ if(typeof HUBFD!=='undefined') HUBFD=null; if(hubBagOpen) hubBagOpenSet(false); }catch(_hf){}
       try{ var tt2=document.getElementById('title'); if(tt2&&keepT===false) tt2.classList.remove('on'); }catch(_t){}
       try{ var sm2=document.getElementById('sectormodal'); if(sm2) sm2.classList.remove('on'); }catch(_s){}
       try{ var hb2=document.getElementById('hub'); if(hb2) hb2.classList.remove('on'); }catch(_h){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
