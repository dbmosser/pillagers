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

if ($s.Contains("  {v:'29.37',what:")) { throw "check 29.37 is in the fixture already" }

SubRx @'
  {v:'29.36',what:
'@ @'
  {v:'29.37',what:'the attract board and how to play page (screens 45, 46) run on the shared look: the ui-shared block carries their rules, the page is a 1px panel at the 4px radius, the headline is the 32px title size, the name the 56px hero size and PRESS ANY KEY the 32px title size, all times the menu scale',
   run:function(){
     if(typeof attZ!=='function'||typeof attEl!=='function'||typeof arcadeAttEl!=='function') return 'no attZ: the attract is not on the shared look';
     var st=document.getElementById('ui-shared'), txt, d, pg, cs, z, tmp=[], i, h;
     if(!st) return 'no ui-shared block';
     txt=st.textContent;
     if(txt.indexOf('#attract .arcpage')<0||txt.indexOf('#attract .attname')<0||txt.indexOf('#attract .attpress')<0) return 'ui-shared has no attract rules';
     d=attZ(attEl()); pg=arcadeAttEl('arcpage'); z=menuScale();
     function px(el){ return parseFloat(getComputedStyle(el).fontSize); }
     try{
       if(Math.abs(parseFloat(d.style.getPropertyValue('--attz'))-z)>0.002) return 'the attract scale is '+d.style.getPropertyValue('--attz')+', not the menu scale '+z;
       h=document.createElement('div'); h.className='aph'; h.textContent='x'; pg.appendChild(h); tmp.push(h);
       if(Math.abs(px(h)-32*z)>0.2) return 'the page headline is '+px(h)+'px, not the 32px title size times '+z;
       if(Math.abs(px(d.querySelector('.attname'))-56*z)>0.2) return 'the name is '+px(d.querySelector('.attname'))+'px, not the 56px hero size times '+z;
       if(Math.abs(px(d.querySelector('.attpress'))-32*z)>0.2) return 'PRESS ANY KEY is '+px(d.querySelector('.attpress'))+'px, not the 32px title size times '+z;
       if(Math.abs(px(pg)-20*z)>0.2) return 'the page text is '+px(pg)+'px, not the 20px body size times '+z;
       cs=getComputedStyle(pg);
       if(cs.borderTopWidth!=='1px'||cs.borderTopLeftRadius!=='4px') return 'the page is '+cs.borderTopWidth+' border and '+cs.borderTopLeftRadius+' radius, not a 1px panel at 4px';
       return null;
     } finally { for(i=0;i<tmp.length;i++){ try{ tmp[i].remove(); }catch(_r){} } }
   }},
  {v:'29.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
