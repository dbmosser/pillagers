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

if ($s.Contains("  {v:'27.03',what:")) { throw "check 27.03 is in the fixture already" }

SubRx @'
  {v:'27.02',what:
'@ @'
  {v:'27.03',what:'career6, his yes to the shop stock that re-rolls each raid (35): the basics are always on the counter, two of the four extras are in stock, the two change with the raid count and are the same for the same count, the roll leaves the main random stream alone, and a sold-out extra is greyed in the grid, cannot be bought and is not offered on the ascent check',
   run:function(){
     if(!(window.__P&&window.__applyLoaded)) return 'SKIP: this fixture has no profile';
     if(typeof shopStockSet!=='function'||typeof SHOP==='undefined') return 'there is no shop re-roll in this build';
     if(typeof renderShop!=='function'||!document.getElementById('shop')) return 'SKIP: no counter in this build';
     var bad=[], snap=null, q, n, k, S, T, seen={}, kinds=0, core=['bandage','medkit','ammobox','plate','pistol','smg'], extras=[], i, j, same, r0, r1, rows, ex, b, out, txt, c0, cells, sold, st;
     function keyOf(s){ return Object.keys(s).sort().join(','); }
     function rowFor(name){ var kids=document.getElementById('shop').children, m; for(m=0;m<kids.length;m++) if(String(kids[m].textContent||'').indexOf(name)>=0) return kids[m]; return null; }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P();
       for(i=0;i<SHOP.length;i++) if(SHOP[i].kind!=='pack'&&core.indexOf(SHOP[i].k)<0) extras.push(SHOP[i].k);
       if(extras.length!==4) bad.push('ONE: '+extras.length+' extras on the counter, not 4 ('+extras.join(',')+')');
       // ONE: the basics are always there, two extras at a time, and the roll moves
       for(n=0;n<40;n++){
         q.runs=n; SHOP_MEMO.n=-1; S=shopStockSet();
         for(i=0;i<core.length;i++) if(!shopStocked({k:core[i],kind:'item'})) bad.push('ONE: the basic '+core[i]+' was out at roll '+n);
         k=0; for(i=0;i<extras.length;i++) if(shopStocked({k:extras[i],kind:'item'})) k++;
         if(k!==2) bad.push('ONE: '+k+' extras in stock at roll '+n+', not 2');
         seen[keyOf(S)]=1;
         if(bad.length>5) break;
       }
       kinds=Object.keys(seen).length;
       if(kinds<4) bad.push('ONE: 40 rolls gave only '+kinds+' different counters');
       // TWO: the same roll is the same counter, and the next raid can change it
       q.runs=7; SHOP_MEMO.n=-1; S=keyOf(shopStockSet()); SHOP_MEMO.n=-1; T=keyOf(shopStockSet());
       if(S!==T) bad.push('TWO: roll 7 gave two different counters');
       same=0; for(n=0;n<12;n++){ q.runs=n; SHOP_MEMO.n=-1; S=keyOf(shopStockSet()); q.runs=n+1; SHOP_MEMO.n=-1; T=keyOf(shopStockSet()); if(S===T) same++; }
       if(same>=12) bad.push('TWO: the counter never changed from one raid to the next');
       // THREE: the roll leaves the main random stream alone
       q.runs=9; SHOP_MEMO.n=-1; r0=RNGS; shopStockSet(); r1=RNGS;
       if(r0!==r1) bad.push('THREE: the roll moved the main random stream');
       // FOUR: the counter shows it
       q.credits=999999; q.xp=999999; q.stash=[]; q.runs=3; SHOP_MEMO.n=-1; S=shopStockSet();
       c0=null; for(i=0;i<extras.length;i++) if(!S[extras[i]]){ c0=extras[i]; break; }
       ex=null; for(i=0;i<extras.length;i++) if(S[extras[i]]){ ex=extras[i]; break; }
       if(!c0||!ex) return 'SKIP: no sold-out extra to look at';
       renderShop();
       rows=rowFor(ITEMS[c0].name); b=rows?rows.querySelector('button'):null;
       if(!b) bad.push('FOUR: no row for '+c0);
       else {
         if(!b.disabled) bad.push('FOUR: the sold-out '+c0+' can be bought');
         if(String(b.textContent).toLowerCase().indexOf('sold out')<0) bad.push('FOUR: the sold-out row reads "'+b.textContent+'"');
         n=q.stash.length; b.click(); if(q.stash.length!==n) bad.push('FOUR: a click on a sold-out row bought it');
       }
       rows=rowFor(ITEMS[ex].name); b=rows?rows.querySelector('button'):null;
       if(!b||b.disabled) bad.push('FOUR: the in-stock '+ex+' cannot be bought');
       cells=document.querySelectorAll('#shopgrid .vcell'); sold=document.querySelectorAll('#shopgrid .vcell.sold');
       if(cells.length!==SHOP.length) bad.push('FOUR: '+cells.length+' cells for '+SHOP.length+' items');
       if(sold.length!==2) bad.push('FOUR: '+sold.length+' sold-out cells, not 2');
       for(i=0;i<sold.length;i++) if(sold[i].textContent.indexOf('SOLD OUT')<0){ bad.push('FOUR: a sold-out cell does not say SOLD OUT'); break; }
       // FIVE: the ascent check does not offer it
       if(typeof renderStage==='function'&&document.getElementById('stagebuy')){
         try{ renderStage(); txt=document.getElementById('stagebuy').textContent||''; }catch(ex2){ txt=null; }
         if(txt!==null){
           if(txt.indexOf(ITEMS[c0].name)>=0) bad.push('FIVE: the ascent check offers the sold-out '+c0);
           if(txt.indexOf(ITEMS[ex].name)<0) bad.push('FIVE: the ascent check lost the in-stock '+ex);
         }
       }
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ SHOP_MEMO.n=-1; SHOP_MEMO.set=null; }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
