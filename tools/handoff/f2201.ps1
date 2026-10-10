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

if ($s.Contains("  {v:'22.01',what:")) { throw "check 22.01 is in the fixture already" }

SubRx @'
  {v:'22.00',what:
'@ @'
  {v:'22.01',what:'on a controller the Stash screen names the highlighted item and its price, and the Y item menu has a Sell one row that sells one and pays its price, only on the Stash screen',
   run:function(){
     var hub=document.getElementById('hub');
     if(!hub||typeof renderHub!=='function'||typeof itemMenuRows!=='function'||typeof padSetFocus!=='function'||typeof ival!=='function'||typeof PAD!=='object'||!PAD) return 'SKIP: no stash screen here';
     var bad=[], was=hub.classList.contains('on'), st0=P.stash.slice(), kit0=(P.kit||[]).slice(), cr0=P.credits, xp0=P.xp, tab0=P.stashTab, ha0=JSON.stringify(P.hotAssign||{}), jk0=JSON.stringify(P.junk||{}), key=null, ks=Object.keys(ITEMS), i, it, rows, row, cells, cell=null, det, tx, n, v, c0;
     function sells(r){ return r&&r.label==='Sell one'; }
     for(i=0;i<ks.length;i++){ it=ITEMS[ks[i]]; if(it&&it.name&&!it.gk&&!/^gun_/.test(ks[i])&&ival(ks[i])>0){ key=ks[i]; break; } }
     if(!key) return 'SKIP: no sellable item here';
     try{
       __topClear();
       P.stash=[key,key,key]; P.kit=[]; P.stashTab='all';
       renderHub(); hub.classList.add('on');
       rows=itemMenuRows(key,'stash',3);
       row=rows.filter(sells)[0];
       if(!row) bad.push('the item menu (Y on a controller) on the Stash screen has no Sell one row');
       else {
         v=ival(key); c0=P.credits; row.act();
         n=0; P.stash.forEach(function(q){ if(q===key) n++; });
         if(n!==2) bad.push('Sell one left '+n+' of 3');
         if(P.credits!==c0+v) bad.push('Sell one paid '+(P.credits-c0)+', not '+v);
       }
       if(itemMenuRows(key,'kit',1).some(sells)) bad.push('a backpack cell offers Sell one');
       hub.classList.remove('on');
       if(itemMenuRows(key,'stash',2).some(sells)) bad.push('Sell one is offered off the Stash screen');
       P.stash=[key,key,key]; P.kit=[];
       renderHub(); hub.classList.add('on');
       cells=document.querySelectorAll('#stashgrid .cell');
       for(i=0;i<cells.length;i++) if(String(cells[i].title||'').indexOf(ITEMS[key].name+'  x')===0){ cell=cells[i]; break; }
       if(!cell) bad.push('staging: the item has no cell on the Stash screen');
       else {
         padSetFocus(null); padSetFocus(cell);
         det=document.getElementById('stashdetail'); tx=det?String(det.textContent||''):'';
         if(tx.indexOf(ITEMS[key].name)<0) bad.push('the highlighted item is not named in the line above the grid ('+tx.slice(0,50)+')');
         if(tx.indexOf('$'+ival(key).toLocaleString())<0) bad.push('the price of the highlighted item is not shown');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       P.stash=st0; P.kit=kit0; P.credits=cr0; P.xp=xp0; P.stashTab=tab0;
       try{ P.hotAssign=JSON.parse(ha0); P.junk=JSON.parse(jk0); }catch(_j){}
       try{ syncXpLevel(); saveProfile(); }catch(_s){}
       try{ padSetFocus(null); PAD.focus=null; }catch(_f){}
       try{ closeItemMenu(); }catch(_c){}
       try{ if(was){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_h){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
