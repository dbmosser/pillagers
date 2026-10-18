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

if ($s.Contains("  {v:'30.01',what:")) { throw "check 30.01 is in the fixture already" }

SubRx @'
  {v:'30.00',what:
'@ @'
  {v:'30.01',what:'while an attract page or the run over card is up, Press any button is a footer hint (a button glyph and accent words, no fill, pulsing), the wordmark is the 32px (x scale) logo on the 5 percent margin, the empty board line is light, and the ring on how to play has two short words (critic on v29.97: 46 55 56 64 = 3 each; screens 46 52 55 56 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof arcadeAttHow!=='function'||typeof arcadeAttBoard!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, pg, wasDisp, z, res=null, ap, cs, nm, probe, want, oldT, ln, wd;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       z=parseFloat(d.style.getPropertyValue('--attz'))||1;
       pg=arcadeAttEl('arcpage'); pg.textContent=''; arcadeAttHow(pg); pg.style.display='block'; pg.style.translate='none'; pg.style.opacity='1'; try{ d.querySelectorAll('.uimghost').forEach(function(g){ g.remove(); }); }catch(_g){}
       ap=d.querySelector('.attpress'); cs=getComputedStyle(ap); nm=d.querySelector('.attname');
       probe=document.createElement('i'); probe.style.color='var(--acc)'; document.body.appendChild(probe); want=getComputedStyle(probe).color; probe.remove();
       wd=d.getBoundingClientRect().width;
       if(cs.backgroundColor!=='rgba(0, 0, 0, 0)') res='Press any button still has a fill: '+cs.backgroundColor;
       else if(cs.color!==want) res='Press any button is '+cs.color+', not the accent '+want;
       else if(getComputedStyle(ap,'::before').content!=='""') res='Press any button has no button glyph';
       else if(Math.abs(parseFloat(getComputedStyle(nm).fontSize)-32*z)>0.5) res='the wordmark is '+getComputedStyle(nm).fontSize+', not the 32px title size x '+z;
       else if(Math.abs(nm.getBoundingClientRect().left-wd*0.05)>3) res='the wordmark starts at '+Math.round(nm.getBoundingClientRect().left)+', not the 5 percent margin '+Math.round(wd*0.05);
       else if(!pg.querySelector('.aprt')||!/in the ring/i.test(pg.textContent)) res='the ring has no words';
       if(res) return res;
       oldT=window.arcadeBoardTonight; window.arcadeBoardTonight=function(){ return []; };
       pg.textContent=''; arcadeAttBoard(pg); ln=pg.querySelector('.apn');
       if(!ln) return 'the empty line left the board';
       probe=document.createElement('i'); probe.style.color='var(--tx-1)'; document.body.appendChild(probe); want=getComputedStyle(probe).color; probe.remove();
       if(getComputedStyle(ln).color!==want) res='the empty line is '+getComputedStyle(ln).color+', not the light text '+want;
       return res;
     } finally {
       try{ if(oldT) window.arcadeBoardTonight=oldT; }catch(_o){}
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'30.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
