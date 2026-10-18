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

if ($s.Contains("  {v:'29.97',what:")) { throw "check 29.97 is in the fixture already" }

SubRx @'
  {v:'29.96',what:
'@ @'
  {v:'29.97',what:'while an attract page or the run over card is up, Press any button sits inside the card in its bottom right corner, the wordmark is the logo on the top left margin (the run over card hides it), the run over card is 720px x scale wide, and the backdrop blurs the world behind it (critic on v29.94: 46 = 2, 55 = 3, 56 = 2; screens 46 52 55 56 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, pg, oc, wasDisp, z, res=null, s, ap, ar, cr, nm, nr, bf;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       z=parseFloat(d.style.getPropertyValue('--attz'))||1;
       bf=String(getComputedStyle(d).backdropFilter||getComputedStyle(d).webkitBackdropFilter);
       if(bf.indexOf('blur')<0) return 'the attract backdrop does not blur the world behind it';
       pg=arcadeAttEl('arcpage'); pg.textContent=''; pg.style.display='block'; pg.style.translate='none'; pg.style.opacity='1'; try{ d.querySelectorAll('.uimghost').forEach(function(g){ g.remove(); }); }catch(_g){}
       s=document.createElement('div'); s.className='aph'; s.textContent='Tonights best'; pg.appendChild(s);
       s=document.createElement('div'); s.className='apr'; s.textContent='1. ABC'; pg.appendChild(s);
       ap=d.querySelector('.attpress'); nm=d.querySelector('.attname');
       ar=ap.getBoundingClientRect(); cr=pg.getBoundingClientRect(); nr=nm.getBoundingClientRect();
       if(ar.left<cr.left||ar.right>cr.right||ar.top<cr.top||ar.bottom>cr.bottom) res='Press any button is not inside the card ('+Math.round(ar.left)+','+Math.round(ar.top)+','+Math.round(ar.right)+','+Math.round(ar.bottom)+' in '+Math.round(cr.left)+','+Math.round(cr.top)+','+Math.round(cr.right)+','+Math.round(cr.bottom)+')';
       else if(cr.right-ar.right>48*z||cr.bottom-ar.bottom>40*z) res='Press any button is not in the bottom right corner of the card';
       else if(getComputedStyle(nm).position!=='absolute'||nr.left>=cr.left||nr.top>80*z) res='the wordmark is not the logo on the top left margin';
       pg.textContent=''; pg.style.display='none';
       if(res) return res;
       oc=arcadeAttEl('arcover'); oc.textContent=''; oc.style.display='block';
       s=document.createElement('div'); s.className='aos'; s.textContent='Score 1 SP'; oc.appendChild(s);
       cr=oc.getBoundingClientRect(); ar=ap.getBoundingClientRect();
       if(Math.abs(cr.width-720*z)>3) res='the run over card is '+Math.round(cr.width)+'px wide, not 720 x '+z;
       else if(ar.left<cr.left||ar.right>cr.right||ar.bottom>cr.bottom) res='Press any button is not inside the run over card';
       return res;
     } finally {
       try{ if(pg){ pg.textContent=''; pg.style.display='none'; } }catch(_a){}
       try{ if(oc){ oc.textContent=''; oc.style.display='none'; } d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
