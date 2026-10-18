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

if ($s.Contains("  {v:'29.87',what:")) { throw "check 29.87 is in the fixture already" }

SubRx @'
  {v:'29.86',what:
'@ @'
  {v:'29.87',what:'while an attract page is up the tab slide ghost (a copy of the old page) floats over the card and does not push the card or the button (screens 46 56 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function'||typeof UIM==='undefined'||typeof UIM.tabOut!=='function') return 'SKIP: no arcade attract here';
     var d, pg, wasDisp, s, y0, y1, gh, res=null;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       pg=arcadeAttEl('arcpage'); pg.textContent=''; pg.style.display='block'; pg.style.translate='none'; pg.style.opacity='1';
       try{ d.querySelectorAll('.uimghost').forEach(function(g){ g.remove(); }); }catch(_g){}
       s=document.createElement('div'); s.className='aph'; s.textContent='Tonights best'; pg.appendChild(s);
       s=document.createElement('div'); s.className='apr'; s.textContent='1. ABC'; pg.appendChild(s);
       y0=d.querySelector('.attpress').getBoundingClientRect().top;
       UIM.tabOut(pg,1);
       gh=d.querySelector('.uimghost');
       if(!gh) return 'SKIP: the tab slide made no ghost';
       y1=d.querySelector('.attpress').getBoundingClientRect().top;
       if(Math.abs(y1-y0)>2) res='the ghost of the old page moved Press any button from '+Math.round(y0)+' to '+Math.round(y1);
       else if(getComputedStyle(gh).position!=='absolute') res='the ghost page is '+getComputedStyle(gh).position+', not absolute';
       return res;
     } finally {
       try{ d.querySelectorAll('.uimghost').forEach(function(g){ g.remove(); }); pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
