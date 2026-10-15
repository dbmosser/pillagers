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

if ($s.Contains("  {v:'28.29',what:")) { throw "check 28.29 is in the fixture already" }

SubRx @'
  {v:'28.28',what:
'@ @'
  {v:'28.29',what:'the appearance screen: five tabs over the racks, every rack on exactly one tab, a rarity bar and the three colours on the tiles, a bigger turning picture of your operator',
   run:function(){
     if(typeof COSTABS==='undefined'||typeof cosRarity!=='function'||typeof avTurnStep!=='function') return 'there is no tabbed appearance screen in this build';
     var bad=[], md=document.getElementById('appearmodal'), pk=document.getElementById('appavatarpicker'), av=document.getElementById('appavatar');
     if(!md||!pk||!av) return 'SKIP: no appearance window here';
     var wasOn=md.classList.contains('on'), keepTab=AVTAB, keepSlot=P._avSlot, keepAng=AVANG, keepAll=P.cosAll, i, j, t, tabs, tiles, el, kinds={}, seen;
     try{
       md.classList.add('on'); P.cosAll=false;
       // every rack is on exactly one tab
       COSMETICS.forEach(function(c){ kinds[c.kind]=1; }); kinds.set=1;
       for(var k in kinds){ var n=0; COSTABS.forEach(function(tb){ if(tb[2].indexOf(k)>=0) n++; }); if(n!==1) bad.push('the '+k+' rack is on '+n+' tabs'); }
       if(COSTABS.map(function(tb){ return tb[1]; }).join()!=='HEAD,BODY,PACK,COLOURS,SETS') bad.push('the tabs are '+COSTABS.map(function(tb){ return tb[1]; }).join());
       // the window
       P._avSlot=null; AVTAB='head'; renderAvatar('appavatar','appavatarpicker');
       tabs=md.querySelectorAll('#apptabs .invtab');
       if(tabs.length!==5) bad.push('the tab row has '+tabs.length+' tabs');
       if(md.querySelectorAll('#apptabs .invtab.on').length!==1) bad.push('the tab row does not show one open tab');
       var cv=document.getElementById('avcv'); if(!cv||cv.width<340||cv.height<430) bad.push('the big picture is '+(cv?cv.width+'x'+cv.height:'missing'));
       // each tab shows its own racks and nothing else
       for(i=0;i<COSTABS.length;i++){
         t=COSTABS[i]; AVTAB=t[0]; P._avSlot=null; renderAvatar('appavatar','appavatarpicker');
         tiles=pk.querySelectorAll('.costile'); seen={};
         if(!tiles.length) bad.push('the '+t[1]+' tab shows no tiles');
         Array.prototype.forEach.call(tiles,function(e2){ seen[e2.getAttribute('data-kind')]=1; if(t[2].indexOf(e2.getAttribute('data-kind'))<0) bad.push('the '+t[1]+' tab shows a '+e2.getAttribute('data-kind')+' tile'); });
         t[2].forEach(function(kd){ if(!seen[kd]&&(kd!=='set')) bad.push('the '+t[1]+' tab has no '+kd+' tiles'); });
       }
       // a tab click opens it
       el=md.querySelector('#apptabs .invtab[data-tab="colours"]'); if(el) el.click(); else bad.push('no COLOURS tab');
       if(AVTAB!=='colours') bad.push('clicking COLOURS opens '+AVTAB);
       el=md.querySelector('#appavatarpicker .costile[data-kind="scheme"] .cosdots'); if(!el) bad.push('a scheme tile does not show its three colours'); else if(el.querySelectorAll('i').length!==3) bad.push('a scheme tile has '+el.querySelectorAll('i').length+' colour bars');
       // a slot on the left jumps to its tab
       AVTAB='head'; P._avSlot=null; renderAvatar('appavatar','appavatarpicker');
       el=av.querySelector('.avslot[data-av="pack"]'); if(el) el.click(); else bad.push('no BACKPACK slot');
       if(AVTAB!=='pack') bad.push('the BACKPACK slot opens the '+AVTAB+' tab');
       el=av.querySelector('.avslot[data-av="scheme"]'); if(el) el.click(); else bad.push('no COLOURS slot');
       if(AVTAB!=='colours') bad.push('the COLOURS slot opens the '+AVTAB+' tab');
       // the rarity bar
       P._avSlot=null; AVTAB='head'; renderAvatar('appavatar','appavatarpicker');
       tiles=pk.querySelectorAll('.costile');
       Array.prototype.forEach.call(tiles,function(e2){ if(COSRAR.indexOf(e2.getAttribute('data-rar'))<0) bad.push('a tile has rarity '+e2.getAttribute('data-rar')); });
       if(cosRarity(cosFind('none'))!=='common') bad.push('a piece owned from the start is '+cosRarity(cosFind('none')));
       if(cosRarity(cosFind('crown'))!=='gold') bad.push('the crown is '+cosRarity(cosFind('crown')));
       if(cosRarity(cosFind('ghostmask'))!=='gold') bad.push('the ghost mask is '+cosRarity(cosFind('ghostmask')));
       if(COSRAR.indexOf(cosRarity(cosFind('band')))<=0) bad.push('the sweat band, earned in raids, is common');
       el=pk.querySelector('.costile.lock .cosreq'); if(!el||!/[A-Za-z0-9]/.test(el.textContent)) bad.push('a locked tile does not say how to earn it');
       // the turntable: a step turns the figure and the picture changes
       var c2=document.getElementById('avcv'), x2=c2.getContext('2d'), a0, a1, d=0, n2, p0, p1;
       AVANG=0.45; drawAvatarCanvas(); a0=x2.getImageData(0,0,c2.width,c2.height).data;
       avTurnStep(1.5); a1=x2.getImageData(0,0,c2.width,c2.height).data;
       for(n2=0;n2<a0.length;n2+=4) if(a0[n2]!==a1[n2]||a0[n2+1]!==a1[n2+1]||a0[n2+2]!==a1[n2+2]) d++;
       if(d<400) bad.push('a turn of 1.5 seconds changes the picture by only '+d+' pixels');
       if(!(AVANG>0.45)) bad.push('the turntable angle did not move');
       var any=false; for(n2=3;n2<a1.length;n2+=4) if(a1[n2]>200){ any=true; break; } if(!any) bad.push('the turned picture is empty');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       AVTAB=keepTab; P._avSlot=keepSlot; AVANG=keepAng; if(keepAll===undefined) delete P.cosAll; else P.cosAll=keepAll;
       if(!wasOn) md.classList.remove('on'); else { try{ renderAvatar('appavatar','appavatarpicker'); }catch(_r){} }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
