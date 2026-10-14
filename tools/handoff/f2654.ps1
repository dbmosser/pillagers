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

if ($s.Contains("  {v:'26.54',what:")) { throw "check 26.54 is in the fixture already" }

SubRx @'
  {v:'26.53',what:
'@ @'
  {v:'26.54',what:'settingsfix, his #50 (menus look AAA), from the 1080p shots of the new Settings: the jump bar sticks flush to the top of the list with no row text showing over it, the chip of the section in view lights, KID MODE is a head like the others, the notes in the Keys and Pad windows keep their height, and the Superhot key is named LEFT OF 1',
   run:function(){
     if(typeof renderSettings!=='function'||typeof setSecJump!=='function'||typeof keysOpen!=='function') return 'SKIP: no Settings here';
     if(typeof setSecSpy!=='function') return 'the jump bar does not light the section in view';
     var bad=[], md=document.getElementById('settingsmodal'), host=document.getElementById('setlist'), was=md&&md.classList.contains('on'), mh, ov, bar, cs, i, b, row, km=document.getElementById('keysmodal'), kmWas=km&&km.classList.contains('on'), kKP=(typeof KEYS==='object'&&KEYS)?KEYS.pad:undefined, chip, on, cur;
     if(!md||!host) return 'SKIP: no Settings window in this fixture';
     mh=host.style.maxHeight; ov=host.style.overflowY;
     try{
       md.classList.add('on'); renderSettings();
       host.style.maxHeight='300px'; host.style.overflowY='auto'; host.scrollTop=0;
       bar=host.querySelector('.setjump'); if(!bar) return 'there is no jump bar';
       cs=getComputedStyle(bar); if(cs.position!=='sticky'||cs.top!=='-3px') bad.push('ONE: the jump bar is '+cs.position+' at top '+cs.top+', not sticky flush to the top');
       if(host.getClientRects().length&&host.scrollHeight>host.clientHeight+500){
         host.scrollTop=400;
         if(Math.abs(bar.getBoundingClientRect().top-(host.getBoundingClientRect().top+host.clientTop))>1.6) bad.push('ONE: scrolled, the jump bar sits '+(bar.getBoundingClientRect().top-host.getBoundingClientRect().top-host.clientTop).toFixed(1)+'px below the top of the list, where row text shows over it');
         // TWO: the chip of the section in view
         cur=setSecSpy(host); if(!cur) bad.push('TWO: no section in view at 400');
         setSecJump(host,'CONTROLS'); cur=setSecSpy(host);
         if(cur!=='CONTROLS') bad.push('TWO: after a jump to CONTROLS the section in view is '+cur);
         chip=host.querySelector('.setjump button[data-sec="CONTROLS"]'); on=host.querySelectorAll('.setjump button.on');
         if(!chip||!chip.classList.contains('on')||on.length!==1) bad.push('TWO: the CONTROLS chip is not the one lit ('+on.length+' lit)');
         if(typeof host.onscroll!=='function') bad.push('TWO: scrolling the list does not move the lit chip');
       }
       // THREE: KID MODE is a head
       b=[].filter.call(host.querySelectorAll('.row b'),function(x){ return x.textContent==='KID MODE'; })[0];
       if(!b) bad.push('THREE: no KID MODE head');
       else { row=b.closest('.row'); if(!/opacity:\s*\.7/.test(row.getAttribute('style')||'')) bad.push('THREE: KID MODE is not drawn as a section head'); else if(host.getClientRects().length&&!(parseFloat(getComputedStyle(b).fontSize)>=19)) bad.push('THREE: the KID MODE head is '+getComputedStyle(b).fontSize); }
       // FOUR: the notes and the locked key
       keysOpen(); b=document.getElementById('keysnote');
       if(!b||getComputedStyle(b).flexShrink!=='0') bad.push('FOUR: the Keys note can be squeezed ('+(b?getComputedStyle(b).flexShrink:'none')+')');
       if(keysListBody().indexOf('LEFT OF 1')<0) bad.push('FOUR: the Superhot key is not named LEFT OF 1');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ host.style.maxHeight=mh||''; host.style.overflowY=ov||''; var k2=document.getElementById('keysmodal'); if(k2&&!kmWas) k2.classList.remove('on'); if(typeof KEYS==='object'&&KEYS) KEYS.pad=kKP; }catch(_h){}
       try{ renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
