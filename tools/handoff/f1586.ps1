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
  {v:'15.85',what:
'@ @'
  {v:'15.86',what:'a controller can choose a sector: on the sector page both sector cards are in the list of controls the pad can reach, beside DAY and NIGHT, and with a faked controller the highlight put on the second sector card stays there through an idle poll, A on it sets the ascent for that sector, that card alone then reads ASCENDING HERE and the highlight is back on it after the rebuild, while the same A on NIGHT sets the surface to night (sector audit finding)',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof padSetFocus!=='function'||typeof padFocusables!=='function'||typeof padOpenModal!=='function'||typeof padRelease!=='function'||typeof PAD==='undefined'||!PAD) return 'SKIP: no pad menu in this build';
     if(typeof renderSector!=='function'||typeof openModal!=='function'||typeof mapOffered!=='function'||typeof FIXED_MAPS==='undefined'||!window.__applyLoaded||!window.__P) return 'SKIP: no sector page, sector list or profile loader in this build';
     var sm=document.getElementById('sectormodal'), host=document.getElementById('sectorlist'), cn=document.getElementById('condnight');
     if(!sm||!host||!cn) return 'SKIP: no sector page with its sector list and NIGHT button in this document';
     if(FIXED_MAPS.length<2||!mapOffered(FIXED_MAPS[0])||!mapOffered(FIXED_MAPS[1])) return 'SKIP: fewer than two sectors are offered here, so there is no second card to pick';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running, and the sector is chosen in the Undercroft';
     if(typeof NET!=='undefined'&&NET&&NET.same) return 'SKIP: a same machine party is on, and its controller comes from the hand-over';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, snap=null, keepPad=null, wasOn=sm.classList.contains('on'), name1=String(FIXED_MAPS[1].name||'the second sector');
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // The words the chosen card shows and the other must not, assembled so the check never matches its own source.
     var AH=['ASCEND','ING HERE'].join('');
     function padWith(down){
       var bts=[],i;
       for(i=0;i<17;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     function cards(){ return host.querySelectorAll('.sectorpick'); }
     function isCard(el){ return !!(el&&el.classList&&el.classList.contains('sectorpick')); }
     function text(el){ return String((el&&el.textContent)||'').replace(/\s+/g,' '); }
     function label(){ return PAD.focus?('"'+(text(PAD.focus).trim().slice(0,40)||PAD.focus.id||'a control')+'"'):'nothing'; }
     function mapName(ix){ var M=FIXED_MAPS[ix|0]; return M?String(M.name):('sector '+ix); }
     // The highlight put on a control after one idle poll, one more idle poll so the pad settles, then A, let go, and one idle poll.
     function press(el){ padWith(-1); pollPad(); padSetFocus(el); pollPad(); var stayed=(PAD.focus===el); padWith(0); pollPad(); padWith(-1); pollPad(); return stayed; }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       keepPad={aSpent:PAD.aSpent,announced:PAD.announced,focusIx:PAD.focusIx,focusMd:PAD.focusMd};
       // The first sector set and daylight chosen, then the page laid out through its own renderer and opener.
       P.mapIx=0; P.cond='day';
       renderSector(); openModal('sectormodal');
       if(padOpenModal()!==sm) return 'SKIP: the sector page is not the panel on top here';
       var c0=cards();
       if(c0.length<2) return 'SKIP: the sector page laid out '+c0.length+' sector cards here, not two';
       padWith(-1); pollPad();
       if(!PAD.on) return 'SKIP: the faked controller did not register here';
       var L=padFocusables(sm);
       // CONTROL: the list is live and the page is laid out, because NIGHT, a button on the same page, is in it.
       if(L.indexOf(cn)<0) return 'SKIP: NIGHT is not in reach of the pad on the sector page here, so the list cannot be read';
       // CONTROL: the faked A reaches the highlighted control on this page: A on NIGHT sets the surface to night.
       if(!press(cn)) return 'SKIP: the highlight would not stay on NIGHT here';
       if(P.cond!=='night') return 'SKIP: A on NIGHT left the surface at '+P.cond+' here, so a pad press cannot be read';
       // THE FIX, ONE: every sector card is in the list beside the buttons.
       var inList=0, i;
       for(i=0;i<L.length;i++) if(isCard(L[i])) inList++;
       if(inList!==c0.length) bad.push('the sector page lays out '+c0.length+' sector cards and '+inList+' of them are in reach of the pad, while NIGHT on the same page is');
       // THE FIX, TWO: the highlight put on the second card stays there, and A picks that sector.
       var c1=cards()[1];
       if(!press(c1)) bad.push('the highlight put on the card for '+name1+' would not stay there: one idle poll moved it to '+label());
       if(P.mapIx!==1) bad.push('with the highlight put on the card for '+name1+', A left the ascent set for '+mapName(P.mapIx)+' (P.mapIx '+P.mapIx+')');
       else {
         var c2=cards();
         if(c2.length<2) return skip('the sector page has '+c2.length+' cards after the pick, so the chosen card cannot be read');
         if(text(c2[1]).indexOf(AH)<0) bad.push('after A on the card for '+name1+' that card does not read '+AH+': "'+text(c2[1]).trim().slice(0,60)+'"');
         if(text(c2[0]).indexOf(AH)>=0) bad.push('after A on the card for '+name1+' the first card still reads '+AH);
         // KEPT: the pick rebuilt the cards, and the v14.22 place keeping put the highlight back on the same card.
         if(!(isCard(PAD.focus)&&PAD.focus.getAttribute('data-map')==='1')) bad.push('after A rebuilt the cards the highlight is on '+label()+', not back on the card for '+name1);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.aSpent=keepPad.aSpent; PAD.announced=keepPad.announced; PAD.focusIx=keepPad.focusIx; PAD.focusMd=keepPad.focusMd; } }catch(_kp){}
       try{ if(!wasOn) sm.classList.remove('on'); }catch(_o){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ renderSector(); }catch(_m){}
       try{ if(typeof syncMapBtn==='function') syncMapBtn(); }catch(_sb){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
