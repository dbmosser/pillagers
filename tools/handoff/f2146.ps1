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

if ($s.Contains("  {v:'21.46',what:")) { throw "check 21.46 is in the fixture already" }

SubRx @'
  {v:'21.45',what:
'@ @'
  {v:'21.46',what:'in the shop a price you cannot pay reads grey and one you can stays amber',
   run:function(){
     if(!(window.__hubEnter&&window.__station)||typeof renderShopGrid!=='function'||typeof SHOP==='undefined') return 'SKIP: no shop here';
     var bad=[], c0=P.credits, g, cells, i, lo=-1, hi=-1, cl, ch;
     try{
       __topClear(); __hubEnter(); __wnseen(1); __station('trader');
       for(i=0;i<SHOP.length;i++){ if(lo<0||SHOP[i].price<SHOP[lo].price) lo=i; if(hi<0||SHOP[i].price>SHOP[hi].price) hi=i; }
       if(lo<0||SHOP[hi].price<=SHOP[lo].price) return 'SKIP: staging: every price is the same';
       P.credits=SHOP[lo].price; renderShopGrid();
       g=document.getElementById('shopgrid'); cells=g?g.querySelectorAll('.vcell'):[];
       if(!cells[hi]||!cells[lo]) return 'SKIP: staging: the shop tiles are not one per entry';
       cl=getComputedStyle(cells[lo].querySelector('.vp')).color; ch=getComputedStyle(cells[hi].querySelector('.vp')).color;
       if(!cells[hi].classList.contains('poor')) bad.push('a price above what he holds is not marked');
       if(cells[lo].classList.contains('poor')) bad.push('a price he can pay is marked');
       if(cl===ch) bad.push('a price he cannot pay reads the same colour as one he can ('+ch+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.credits=c0; try{ renderShopGrid(); __hubEnter(); }catch(_r){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
