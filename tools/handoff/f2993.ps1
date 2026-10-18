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

if ($s.Contains("  {v:'29.93',what:")) { throw "check 29.93 is in the fixture already" }

SubRx @'
  {v:'29.92',what:
'@ @'
  {v:'29.93',what:'the how to play page shows keys as key caps with the teal ring as a glyph, names in the light colour and 56px (x scale) rows; an empty board shows five ghost rows; the attract backdrop lets the world through (critic on v29.92: 46 = 3, 56 = 2; screens 46 56 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof arcadeAttHow!=='function'||typeof arcadeAttBoard!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, pg, wasDisp, z, res=null, trs, probe, want, got, caps, oldT, bg;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       z=parseFloat(d.style.getPropertyValue('--attz'))||1;
       pg=arcadeAttEl('arcpage'); pg.textContent=''; arcadeAttHow(pg); pg.style.display='block'; pg.style.translate='none'; pg.style.opacity='1';
       caps=pg.querySelectorAll('td .apkc'); trs=pg.querySelectorAll('tr');
       probe=document.createElement('i'); probe.style.color='var(--tx-1)'; document.body.appendChild(probe); want=getComputedStyle(probe).color; probe.remove();
       got=getComputedStyle(pg.querySelector('td.apk')).color;
       if(caps.length<14) res='the keys are not key caps ('+caps.length+' caps)';
       else if(/teal ring/i.test(pg.textContent)||!pg.querySelector('.aprg')) res='the teal ring is still a sentence, not a glyph';
       else if(got!==want) res='the action names are '+got+', not the light text colour '+want;
       else if(trs.length<2||trs[1].getBoundingClientRect().height<56*z-2) res='a table row is '+Math.round(trs.length>1?trs[1].getBoundingClientRect().height:0)+'px high, not 56 x '+z;
       if(res) return res;
       oldT=window.arcadeBoardTonight; window.arcadeBoardTonight=function(){ return []; };
       pg.textContent=''; arcadeAttBoard(pg);
       if(pg.querySelectorAll('.apg').length<5) res='an empty board shows '+pg.querySelectorAll('.apg').length+' ghost rows, not 5';
       else if(!pg.querySelector('.apn')) res='the empty line left the board';
       if(res) return res;
       bg=getComputedStyle(d).backgroundImage;
       if(!/\/ 0?\.\d|rgba\(|color-mix/.test(bg)) res='the attract backdrop is opaque: '+bg.slice(0,120);
       return res;
     } finally {
       try{ if(oldT) window.arcadeBoardTonight=oldT; }catch(_o){}
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
