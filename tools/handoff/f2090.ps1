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

if ($s.Contains("  {v:'20.90',what:")) { throw "check 20.90 is in the fixture already" }

SubRx @'
  {v:'20.89',what:
'@ @'
  {v:'20.90',what:'the shop, bench and hire tiles fill their frame: on BUY, CRAFT and HIRE the last tile of a full row ends within a quarter of a tile of the right edge of the frame, with no empty strip beside the tiles',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function'||typeof openTrader!=='function') return 'SKIP: no shop here';
     var bad=[], t, tabs=['buy','craft','hire'], ids=['shopgrid','craftgrid','mercgrid'], i, j, g, cells, R, s, cs, inner, r0, q, maxR, two, left, n=0;
     function shut(){ var a=document.querySelectorAll('.modal.on'), k; for(k=0;k<a.length;k++) a[k].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('trader','KeyE');
       for(i=0;i<tabs.length;i++){
         openTrader(tabs[i]);
         g=document.getElementById(ids[i]); if(!g||!g.offsetWidth) continue;
         cells=g.querySelectorAll('.vcell'); if(cells.length<2) continue;
         R=g.getBoundingClientRect(); s=R.width/g.offsetWidth; cs=getComputedStyle(g);
         inner=R.left+(g.clientLeft+g.clientWidth-parseFloat(cs.paddingRight))*s;
         r0=cells[0].getBoundingClientRect(); maxR=-1e9; two=false;
         for(j=0;j<cells.length;j++){ q=cells[j].getBoundingClientRect(); if(Math.abs(q.top-r0.top)<2) maxR=Math.max(maxR,q.right); else if(q.top>r0.top+2) two=true; }
         if(!two||!(r0.width>10)) continue;   // one row is not a full row: nothing to measure
         n++; left=inner-maxR;
         if(left>r0.width*0.25) bad.push('on '+tabs[i].toUpperCase()+' an empty strip '+Math.round(left/s)+' wide sits beside tiles '+Math.round(r0.width/s)+' wide');
       }
       if(!n) return 'SKIP: no tab had two rows of tiles';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ shut(); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
