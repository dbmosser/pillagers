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

if ($s.Contains("  {v:'20.58',what:")) { throw "check 20.58 is in the fixture already" }

SubRx @'
  {v:'20.57',what:
'@ @'
  {v:'20.58',what:'a controller reaches the FASHION racks, slot rows and saved looks and the run tags: A on a rack tile wears it, A on a slot row opens it, the three looks are in reach, A on a run tag picks it, and the end-of-raid card still opens on Log run and return',
   run:function(){
     if(typeof padMenu!=='function'||typeof padFocusables!=='function'||typeof padSetFocus!=='function'||typeof padOpenModal!=='function'||typeof renderAvatar!=='function'||typeof buildTags!=='function'||typeof cosWorn!=='function'||typeof COSKEY==='undefined'||typeof PAD==='undefined'||!PAD) return 'SKIP: no pad menu, FASHION or run tags here';
     var ap=document.getElementById('appearmodal'), pk=document.getElementById('appavatarpicker'), av=document.getElementById('appavatar'), lb=document.getElementById('applooks'), oc=document.getElementById('outcome'), ob=document.getElementById('oc_btn');
     if(!ap||!pk||!av||!lb||!oc||!ob) return 'SKIP: no FASHION window or end-of-raid card in the page';
     if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running';
     var bad=[], k=COSKEY.hat||'cosHat', h0=P[k], ow0=cosOwned, hadSl=('_avSlot' in P), sl0=P._avSlot, apOn=ap.classList.contains('on'), st0=selTags.slice(),
         kp={prev:PAD.prev,ax:PAD.ax,focusIx:PAD.focusIx,focusMd:PAD.focusMd,aSpent:PAD.aSpent,mrep:PAD.mrep,yMenuWas:PAD.yMenuWas},
         L=[], i, tiles, tl=null, id=null, wn, sb, bt, tt, tg, ns, na;
     function idle(){ return false; }
     function aDown(n){ return n===0; }
     function cnt(sel){ var c=0, j; for(j=0;j<L.length;j++) if(L[j].matches(sel)) c++; return c; }
     // The highlight is put on el and one idle poll runs (a control the pad cannot reach is moved off at once); only when it
     // stayed is A pressed and let go, so nothing else is ever clicked.
     function press(el){ PAD.prev=[]; PAD.ax=[0,0,0,0]; PAD.yMenuWas=false; padSetFocus(el); padMenu(idle); if(PAD.focus!==el) return false; padMenu(aDown); padMenu(idle); return true; }
     try{
       __topClear();
       cosOwned=function(c){ return true; };
       P._avSlot=null; ap.classList.add('on');
       renderAvatar('appavatar','appavatarpicker');
       if(padOpenModal()!==ap) return 'SKIP: FASHION is not the panel on top here';
       sb=document.getElementById('looksurprise');
       L=padFocusables(ap);
       if(!sb||L.indexOf(sb)<0) return 'SKIP: SURPRISE ME is not in reach of the pad here, so FASHION is not laid out';
       if(!cnt('.costile')) bad.push('none of the '+pk.querySelectorAll('.costile').length+' rack tiles is in reach of the pad');
       ns=av.querySelectorAll('.avslot[data-av]').length;
       if(!ns||cnt('.avslot[data-av]')!==ns) bad.push(cnt('.avslot[data-av]')+' of the '+ns+' slot rows are in reach of the pad');
       if(cnt('.avslot[data-lookwear]')!==3) bad.push(cnt('.avslot[data-lookwear]')+' of the 3 saved looks are in reach of the pad');
       wn=String(cosWorn('hat'));
       tiles=[].slice.call(pk.querySelectorAll('.costile[data-kind="hat"]'));
       for(i=0;i<tiles.length;i++) if(tiles[i].getAttribute('data-id')!==wn){ tl=tiles[i]; id=tl.getAttribute('data-id'); break; }
       if(!tl) return bad.length?bad.join('; '):'SKIP: no other hat on the rack';
       if(!press(tl)) bad.push('the pad highlight put on the '+id+' hat tile does not stay there');
       else if(String(P[k])!==id) bad.push('A on the '+id+' hat tile left '+P[k]+' worn');
       bt=av.querySelector('.avslot[data-av="boots"]');
       if(!bt) bad.push('FASHION drew no BOOTS slot row');
       else if(!press(bt)) bad.push('the pad highlight put on the BOOTS slot row does not stay there');
       else if(P._avSlot!=='boots') bad.push('A on the BOOTS slot row opened '+P._avSlot+', not the boots rack');
       ap.classList.remove('on');
       // The end-of-raid card, as it comes up: the run tags in reach, A on one picks it, and the card opens on Log run and return.
       selTags=[]; buildTags(); oc.classList.add('on');
       if(padOpenModal()!==oc) return bad.length?bad.join('; '):'SKIP: the end-of-raid card is not the panel on top here';
       L=padFocusables(oc);
       if(L.indexOf(ob)<0) return bad.length?bad.join('; '):'SKIP: Log run and return is not in reach of the pad on the card here';
       tt=[].slice.call(document.querySelectorAll('#tagwrap .tag'));
       na=cnt('.tag');
       if(!tt.length||na!==tt.length) bad.push(na+' of the '+tt.length+' run tags are in reach of the pad');
       tg=tt[2]||tt[0];
       if(tg){
         if(!press(tg)) bad.push('the pad highlight put on the '+tg.textContent+' tag does not stay there');
         else if(selTags.indexOf(tg.textContent)<0) bad.push('A on the '+tg.textContent+' tag did not pick it');
       }
       padSetFocus(null); PAD.focus=null; PAD.prev=[];
       padMenu(idle);
       if(PAD.focus!==ob) bad.push('the card opens with the pad on '+(PAD.focus?('"'+String(PAD.focus.textContent||PAD.focus.id||'a control').slice(0,30)+'"'):'nothing')+', not Log run and return');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       cosOwned=ow0;
       if(h0===undefined) delete P[k]; else P[k]=h0;
       if(hadSl) P._avSlot=sl0; else delete P._avSlot;
       try{ saveProfile(); }catch(_s){}
       try{ padSetFocus(null); }catch(_f){}
       PAD.focus=null; PAD.prev=kp.prev; PAD.ax=kp.ax; PAD.focusIx=kp.focusIx; PAD.focusMd=kp.focusMd; PAD.aSpent=kp.aSpent; PAD.mrep=kp.mrep; PAD.yMenuWas=kp.yMenuWas;
       selTags=st0;
       if(!apOn) ap.classList.remove('on'); else { try{ renderAvatar('appavatar','appavatarpicker'); }catch(_r){} }
       oc.classList.remove('on');
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
