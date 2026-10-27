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

if ($s.Contains("  {v:'35.12',what:")) { throw "check 35.12 is in the fixture already" }

SubRx @'
  {v:'35.11',what:
'@ @'
  {v:'35.12',what:'UNDERCROFT FIXES: the wheel zooms the floor, M opens the lift, the stash row is the hotbar, no pips in the shop, better Wirt pulls, no gun label or ghosts pre-raid, data core hover, the pack list keeps its place',
   run:function(){
     var bad=[], a, b, i, w, tot=0, good=0, ev, mz0, sm, lab, rp0=rarityPips, pips=0, u1, u2, html, cb, ls, ls2, sty=null, src='', sc;
     try{
       __topClear(); __runPrep(); __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // (1) the floor scale follows the zoom
       HZT=1; HZC=1; a=hubScale(); HZC=1.5; b=hubScale(); HZC=1;
       if(Math.abs(b/a-1.5)>0.01) bad.push('floor scale does not follow the zoom ('+a+' then '+b+')');
       // (2) the wheel on the bare floor zooms it and leaves the menu size alone
       __hubEnter();
       if(state!=='hub'||!HB) bad.push('staging: not on the floor');
       else {
         [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });
         if(typeof hubWinOn==='function'&&hubWinOn()) bad.push('staging: a hub window is up');
         mz0=P.menuZoom; HZT=1; HZC=1;
         ev=new WheelEvent('wheel',{deltaY:-120,deltaMode:0,bubbles:true,cancelable:true,clientX:960,clientY:540});
         document.body.dispatchEvent(ev);
         if(!(HZT>1.05)) bad.push('the wheel on the floor left the floor zoom at '+HZT);
         if(P.menuZoom!==mz0) bad.push('the wheel on the floor changed the menu size to '+P.menuZoom);
         HZT=1; HZC=1;
         // (3) M on the floor opens the lift map
         var K0=__keys(); for(var q0 in K0) delete K0[q0];
         window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyM',key:'m',bubbles:true}));
         window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyM',key:'m',bubbles:true}));
         sm=document.getElementById('sectormodal');
         if(!sm||!sm.classList.contains('on')) bad.push('M on the floor did not open the lift map');
         if(sm) sm.classList.remove('on');
       }
       // (4) the stash row is called the hotbar
       lab=document.getElementById('quickn'); lab=lab&&lab.parentNode&&lab.parentNode.parentNode;
       if(!lab||!/^\s*hotbar/i.test(lab.textContent)) bad.push('stash row reads '+(lab?JSON.stringify(lab.textContent.slice(0,24)):'nothing'));
       P.hotAssign=P.hotAssign||{}; P.hotAssign[5]='medkit';
       if(hotPlanHTML().indexOf('width:40px')<0) bad.push('stash hotbar icons are still small');
       delete P.hotAssign[5];
       // (5) shop and craft icons have no pips
       rarityPips=function(){ pips++; };
       delete _iconURL['optic|17|np']; delete _iconURL['optic|19'];
       u1=itemIconURL('optic',17,1); var p1=pips; u2=itemIconURL('optic',19); var p2=pips-p1;
       rarityPips=rp0;
       if(p1>0) bad.push('the shop icon still paints rarity pips');
       if(p2<1) bad.push('control: the plain icon no longer paints pips');
       if(String(renderShopGrid).indexOf('shopEntryIcon(o),64,1)')<0||String(renderCraftGrid).indexOf('(icon,64,1)')<0) bad.push('shop or craft grid still asks for pips');
       // (6) Wirt: guns and valuables are at least 40 percent of the pulls, and a pull is still worth less than its price
       var ev2=0;
       for(i=0;i<GAMBLE_POOL.length;i++){ w=GAMBLE_POOL[i][1]; tot+=w; if(GAMBLE_POOL[i][0]!=='KEY'&&ITEMS[GAMBLE_POOL[i][0]]){ if((ITEMS[GAMBLE_POOL[i][0]].val||0)>=900) good+=w; ev2+=w*(ITEMS[GAMBLE_POOL[i][0]].val||0); } }
       if(!(good/tot>=0.4)) bad.push('only '+Math.round(100*good/tot)+'% of Wirt pulls are a gun or a valuable');
       if(!(ev2/tot<GAMBLE_PRICE)) bad.push('a Wirt pull is worth more than its price ($'+Math.round(ev2/tot)+')');
       // (7) the lift screen: no GUNS label or gun ghosts on the belt, the data core row has a hover line, the pack list keeps its scroll
       P.kitPick='mine';
       P.stash.push('medkit','medkit','bandage','smoke','frag','frag','plate','decoy','stim','ammobox','gun_smg','gun_rifle','gun_carbine','gun_shotgun','core');
       saveProfile(); renderSector(); openModal('sectormodal');
       html=hotPlanHTML('sector');
       if(/>\s*GUNS\s*</i.test(html)) bad.push('pre-raid belt still says GUNS');
       if(html.indexOf('opacity:.7')>=0) bad.push('pre-raid belt still shows a dimmed gun');
       cb=document.querySelector('#sectorpack .srcore');
       if(!cb) bad.push('staging: no data core row');
       else if(!/data core/i.test(cb.getAttribute('title')||'')) bad.push('data core row has no hover line');
       sty=document.createElement('style'); sty.textContent='#sectormodal .srplist{max-height:90px!important;flex:0 0 90px!important}'; document.head.appendChild(sty);
       syncSectorKit();
       ls=document.querySelector('#sectormodal .srplist');
       if(!ls) bad.push('staging: no pack list');
       else if(ls.scrollHeight-ls.clientHeight<60) bad.push('staging: the pack list does not scroll ('+ls.scrollHeight+'/'+ls.clientHeight+')');
       else {
         ls.scrollTop=50; var s0=ls.scrollTop;
         packSet('medkit',1); syncSectorKit(); try{ refreshInv(); }catch(_ri){}
         ls2=document.querySelector('#sectormodal .srplist');
         if(!ls2) bad.push('pack list gone after packing');
         else if(Math.abs(ls2.scrollTop-s0)>2) bad.push('pack list jumped from '+s0+' to '+ls2.scrollTop+' after packing');
         if(packedCount('medkit')!==1) bad.push('control: packing a medkit packed '+packedCount('medkit'));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ rarityPips=rp0; }catch(_rp){}
       try{ HZT=1; HZC=1; }catch(_hz){}
       try{ if(sty&&sty.parentNode) sty.parentNode.removeChild(sty); }catch(_st){}
       try{ var sm2=document.getElementById('sectormodal'); if(sm2) sm2.classList.remove('on'); }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
