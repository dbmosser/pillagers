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

if ($s.Contains("  {v:'21.47',what:")) { throw "check 21.47 is in the fixture already" }

SubRx @'
  {v:'21.46',what:
'@ @'
  {v:'21.47',what:'on the hire tab a fee you cannot pay reads grey, as in the shop',
   run:function(){
     if(!(window.__hubEnter&&window.__station)||typeof renderMercGrid!=='function'||typeof mercCost!=='function'||typeof IDENTITIES==='undefined') return 'SKIP: no hire tab here';
     var bad=[], c0=P.credits, m0=P.merc, g, cells, i, k=-1, cost;
     try{
       __topClear(); __hubEnter(); __wnseen(1); __station('trader','KeyF');
       for(i=0;i<IDENTITIES.length;i++){ cost=mercCost(IDENTITIES[i].id); if(cost!==null&&cost>0){ k=i; break; } }
       if(k<0) return 'SKIP: staging: no hire with a fee';
       P.merc=null; P.credits=0; renderMercGrid();
       g=document.getElementById('mercgrid')||document.querySelector('#merclist')&&document.querySelector('.vgrid');
       cells=document.querySelectorAll('.vcell');
       var cell=null; for(i=0;i<cells.length;i++) if(cells[i].title===IDENTITIES[k].tag){ cell=cells[i]; break; }
       if(!cell) return 'SKIP: staging: the hire tile was not found';
       if(!cell.classList.contains('poor')) bad.push('a hire fee he cannot pay is not marked');
       P.credits=999999; renderMercGrid();
       cells=document.querySelectorAll('.vcell'); cell=null; for(i=0;i<cells.length;i++) if(cells[i].title===IDENTITIES[k].tag){ cell=cells[i]; break; }
       if(cell&&cell.classList.contains('poor')) bad.push('a hire fee he can pay is marked');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.credits=c0; P.merc=m0; try{ __hubEnter(); }catch(_r){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
