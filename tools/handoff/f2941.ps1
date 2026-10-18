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

if ($s.Contains("  {v:'29.41',what:")) { throw "check 29.41 is in the fixture already" }

SubRx @'
  {v:'29.40',what:
'@ @'
  {v:'29.41',what:'the attract board card is one menu width wide (not 44% of the screen) and its empty line is the 20px body size times the menu scale (critic 2 of 5 on screen 45)',
   run:function(){
     if(typeof attZ!=='function'||typeof arcadeAttEl!=='function'||typeof arcadeAttLine!=='function') return 'no attract page here';
     var pg=arcadeAttEl('arcpage'), d=attZ(attEl()), was=pg.style.display, was2=d.style.display, h, ln, z, w, fs;
     try{
       d.style.display='block'; pg.style.display='block';
       h=document.createElement('div'); h.className='aph'; h.textContent='x'; pg.appendChild(h);
       arcadeAttLine(pg,'apn','NO SCORES YET'); ln=pg.querySelector('.apn');
       if(!ln) return 'no empty line';
       z=parseFloat(d.style.getPropertyValue('--attz'))||1; w=pg.offsetWidth; fs=parseFloat(getComputedStyle(ln).fontSize);
       if(Math.abs(w-560*z)>4) return 'the board card is '+w+'px wide, not the 560 menu width times '+z;
       if(Math.abs(fs-20*z)>0.6) return 'the empty line is '+fs+'px, not 20 times '+z;
       return null;
     } finally { try{ h.remove(); }catch(_r){} try{ if(ln) ln.remove(); }catch(_r2){} pg.style.display=was; d.style.display=was2; }
   }},
  {v:'29.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
