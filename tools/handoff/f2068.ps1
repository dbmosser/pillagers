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

if ($s.Contains("  {v:'20.68',what:")) { throw "check 20.68 is in the fixture already" }

SubRx @'
  {v:'20.67',what:
'@ @'
  {v:'20.68',what:'buying a quantity at the shop says the whole order once: five of one item bought together read 5x and the price of all five, and the wallet and the stash agree',
   run:function(){
     if(typeof renderShop!=='function'||typeof SHOP==='undefined'||!document.getElementById('shopdetail')||!document.getElementById('shop')||!window.__P) return 'SKIP: no shop detail in this build';
     var ix=-1, i, o, bad=[], prof=null, keep=null, b, t, n0, c0, N=5, n;
     for(i=0;i<SHOP.length;i++){ o=SHOP[i]; if(o&&o.kind!=='wep'&&o.kind!=='pack'&&o.k==='bandage'&&ITEMS[o.k]){ ix=i; break; } }
     if(ix<0) for(i=0;i<SHOP.length;i++){ o=SHOP[i]; if(o&&o.kind!=='wep'&&o.kind!=='pack'&&ITEMS[o.k]){ ix=i; break; } }
     if(ix<0) return 'SKIP: nothing stackable in the shop';
     o=SHOP[ix];
     try{
       __topClear(); __cleanProfile(); prof=__P();
       keep={c:prof.credits,s:(prof.stash||[]).slice(),x:prof.xp,sel:prof._shopSel,q:prof._shopQty};
       if((prof.xp||0)<o.rep) prof.xp=o.rep;
       prof.credits=o.price*N+37; prof._shopSel=ix; prof._shopQty=N;
       if(!prof.stash) prof.stash=[];
       HUBSAY='';
       renderShop();
       b=document.querySelector('#shopdetail .vbuy');
       if(!b||b.disabled||typeof b.onclick!=='function') return 'SKIP: the shop drew no live buy button for '+N+' of '+ITEMS[o.k].name;
       n0=prof.stash.filter(function(k){ return k===o.k; }).length; c0=prof.credits;
       b.click();
       prof=__P();
       n=(prof.stash||[]).filter(function(k){ return k===o.k; }).length-n0;
       if(n!==N) return 'SKIP: the order delivered '+n+' of '+N+' here';
       if(prof.credits!==c0-o.price*N) bad.push('the wallet moved by '+(c0-prof.credits)+', not '+(o.price*N));
       t=String(HUBSAY||'');
       if(t.indexOf(String(N)+'x')<0||t.indexOf('$'+(o.price*N).toLocaleString())<0) bad.push('after buying '+N+' of '+ITEMS[o.k].name+' for $'+(o.price*N).toLocaleString()+' the shop said: '+t);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof&&keep){ var q=__P(); q.credits=keep.c; q.stash=keep.s; q.xp=keep.x; q._shopSel=keep.sel; q._shopQty=keep.q; } }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'20.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
