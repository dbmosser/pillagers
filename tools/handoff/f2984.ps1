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

if ($s.Contains("  {v:'29.84',what:")) { throw "check 29.84 is in the fixture already" }

SubRx @'
  {v:'29.83',what:
'@ @'
  {v:'29.84',what:'while an attract page (board, how to play) is up the screen is one column: the wordmark on the card left edge above it, Press any button a 56px (x scale) accent button flush right under the card, no more than 56px (x scale) below it (critic: prompt 150px detached; screens 46 56 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, pg, wasDisp, nm, ap, pr, z, res=null, s;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       pg=arcadeAttEl('arcpage'); pg.style.display='block';
       s=document.createElement('div'); s.className='aph'; s.textContent='Tonights best'; pg.appendChild(s);
       s=document.createElement('div'); s.className='apr'; s.textContent='1. ABC'; pg.appendChild(s);
       nm=d.querySelector('.attname').getBoundingClientRect(); ap=d.querySelector('.attpress').getBoundingClientRect(); pr=pg.getBoundingClientRect();
       z=parseFloat(d.style.getPropertyValue('--attz'))||1;
       if(Math.abs(ap.height-56*z)>3) res='Press any button is '+Math.round(ap.height)+'px high, not '+Math.round(56*z);
       else if(ap.top-pr.bottom>56*z) res='Press any button sits '+Math.round(ap.top-pr.bottom)+'px under the card';
       else if(ap.top<pr.bottom-1) res='Press any button is above the card bottom';
       else if(Math.abs(ap.right-pr.right)>3) res='Press any button ends at '+Math.round(ap.right)+', the card at '+Math.round(pr.right);
       else if(nm.bottom>pr.top+1) res='the wordmark ends at '+Math.round(nm.bottom)+', the card starts at '+Math.round(pr.top);
       else if(Math.abs(nm.left-pr.left)>3) res='the wordmark starts at '+Math.round(nm.left)+', the card at '+Math.round(pr.left);
       return res;
     } finally {
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
