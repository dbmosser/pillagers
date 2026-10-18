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

if ($s.Contains("  {v:'29.89',what:")) { throw "check 29.89 is in the fixture already" }

SubRx @'
  {v:'29.88',what:
'@ @'
  {v:'29.89',what:'the abandon question names itself, Keep playing is the one amber primary and the card is 320px, not 556 (critic: two identical red buttons, title says Raid paused, dead space; screen 59)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: cannot deploy here';
     if(typeof togglePauseBox!=='function'||typeof disarmAbandon!=='function') return 'SKIP: no pause box in this build';
     var ab=document.getElementById('abandonbtn'), cb=document.getElementById('confirmabandon'), pb=document.getElementById('pausebox');
     if(!ab||!cb||!pb||typeof ab.onclick!=='function') return 'SKIP: no abandon button or confirm in this build';
     var bad=[], g=null, h, t0, ch, bgA, bgC, rA, rC;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       togglePauseBox(true);
       if(!pb.classList.contains('on')) return 'SKIP: the pause box did not open here';
       h=pb.querySelector('h3'); t0=h.textContent;
       ab.onclick.call(ab);
       if(cb.style.display==='none') return 'SKIP: the press did not arm the confirm here';
       if(!/abandon/i.test(h.textContent)||/paused/i.test(h.textContent)) bad.push('armed, the title reads "'+h.textContent+'"');
       if(ab.textContent.trim()!=='Keep playing') bad.push('the way back reads "'+ab.textContent+'"');
       ab.style.transition='none'; cb.style.transition='none'; void ab.offsetWidth;   // a colour fade would read as transparent
       bgA=getComputedStyle(ab).backgroundColor; bgC=getComputedStyle(cb).backgroundColor;
       if(bgA!=='rgb(245, 183, 59)') bad.push('Keep playing is '+bgA+', not the amber primary');
       if(bgC===bgA||bgC==='rgb(245, 183, 59)') bad.push('the YES button is also '+bgC);
       rA=ab.getBoundingClientRect(); rC=cb.getBoundingClientRect();
       if(rA.top>=rC.top) bad.push('Keep playing is not above the YES button');
       ch=parseFloat(getComputedStyle(pb,'::before').height);
       if(!(ch>0&&ch<=340)) bad.push('the card is '+ch+'px tall, not about 320');
       disarmAbandon();
       if(h.textContent!==t0) bad.push('disarming left the title "'+h.textContent+'", it was "'+t0+'"');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ disarmAbandon(); }catch(_d){}
       try{ if(pb.classList.contains('on')) togglePauseBox(false); }catch(_t){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
  {v:'29.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
