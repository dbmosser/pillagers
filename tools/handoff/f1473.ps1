$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.72',what:
'@ @'
  {v:'14.73',what:'the shop does not ask for money for a gun you own: short of the price, a gun not owned says how short, and a gun you own does not (stash and trader audit finding 1)',
   run:function(){
     if(typeof renderShop!=='function'||typeof SHOP==='undefined'||!document.getElementById('shopdetail')) return 'SKIP: no shop detail in this build';
     var own=-1, other=-1;
     for(var i=0;i<SHOP.length;i++){ if(SHOP[i].kind!=='wep') continue; if(own<0) own=i; else if(other<0) other=i; }
     if(own<0||other<0) return 'SKIP: fewer than two guns in the shop';
     var bad=[], prof=null, keep=null;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       keep={w:(prof.weapons||[]).slice(),c:prof.credits,s:prof._shopSel,q:prof._shopQty};
       prof.weapons=[SHOP[own].k]; prof.credits=Math.floor(Math.min(SHOP[own].price,SHOP[other].price)/2); prof._shopQty=1;
       // CONTROL: a gun not owned, short of its price, says how short.
       prof._shopSel=other; renderShop();
       var bo=document.querySelector('#shopdetail .vbuy');
       if(!bo) return 'SKIP: the shop drew no buy button';
       if(String(bo.textContent).toUpperCase().indexOf('NEED')<0) return 'SKIP: a gun not owned and short of its price read '+bo.textContent+' here';
       prof._shopSel=own; renderShop();
       var bw=document.querySelector('#shopdetail .vbuy'), tw=bw?String(bw.textContent):'';
       if(tw.toUpperCase().indexOf('NEED')>=0) bad.push('the shop asks for money for the '+SHOP[own].k+' you already own: '+tw);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof&&keep){ prof.weapons=keep.w; prof.credits=keep.c; prof._shopSel=keep.s; prof._shopQty=keep.q; } }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
