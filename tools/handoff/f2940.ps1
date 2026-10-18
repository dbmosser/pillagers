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

if ($s.Contains("  {v:'29.40',what:")) { throw "check 29.40 is in the fixture already" }

SubRx @'
  {v:'29.39',what:
'@ @'
  {v:'29.40',what:'the attract page is Panel P: 90% panel fill, a 3px accent tab on the top edge, the headline at the left edge and the how to play table filling the panel width (critic 2 of 5 on screens 45, 46)',
   run:function(){
     if(typeof attZ!=='function'||typeof arcadeAttEl!=='function') return 'no attract page here';
     var pg=arcadeAttEl('arcpage'), d=attZ(attEl()), cs, bf, tmp=[], was=pg.style.display, was2=d.style.display, h, t, tr, c, pcs, w, k, i;
     try{
       d.style.display='block'; pg.style.display='block';
       h=document.createElement('div'); h.className='aph'; h.textContent='x'; pg.appendChild(h); tmp.push(h);
       t=document.createElement('table'); tr=t.insertRow(); c=tr.insertCell(); c.className='apk'; c.textContent='Move'; tr.insertCell().textContent='WASD'; pg.appendChild(t); tmp.push(t);
       cs=getComputedStyle(pg); bf=getComputedStyle(pg,'::before');
       if(!/color\(srgb|rgba\(/.test(cs.backgroundColor)&&!/rgba?\(/.test(cs.backgroundColor)) return 'the page fill is '+cs.backgroundColor;
       if(/rgba\(\d+, \d+, \d+, 0\)/.test(cs.backgroundColor)||cs.backgroundColor==='rgba(0, 0, 0, 0.74)') return 'the page is not the 90% panel fill: '+cs.backgroundColor;
       if(bf.height!=='3px') return 'the page has no 3px accent tab ('+bf.height+')';
       k=getComputedStyle(document.documentElement).getPropertyValue('--acc').trim();
       if(!k||bf.backgroundColor==='rgba(0, 0, 0, 0)') return 'the accent tab has no color';
       if(getComputedStyle(h).textAlign!=='left'&&getComputedStyle(h).textAlign!=='start') return 'the headline is '+getComputedStyle(h).textAlign+', not left';
       w=pg.clientWidth-parseFloat(cs.paddingLeft)-parseFloat(cs.paddingRight);
       if(t.offsetWidth<w-2) return 'the table is '+t.offsetWidth+'px in a '+Math.round(w)+'px panel';
       return null;
     } finally { for(i=0;i<tmp.length;i++){ try{ tmp[i].remove(); }catch(_r){} } pg.style.display=was; d.style.display=was2; }
   }},
  {v:'29.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
