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

if ($s.Contains("  {v:'24.28',what:")) { throw "check 24.28 is in the fixture already" }

SubRx @'
  {v:'24.27',what:
'@ @'
  {v:'24.28',what:'his answer 24 (2026-10-12): right-click a stack in the stash and choose SELL ALL: it sells the whole stack and pays every copy, only on the Stash screen',
   run:function(){
     var hub=document.getElementById('hub');
     if(!hub||typeof renderHub!=='function'||typeof itemMenuRows!=='function'||typeof ival!=='function') return 'SKIP: no stash screen here';
     var bad=[], was=hub.classList.contains('on'), st0=P.stash.slice(), kit0=(P.kit||[]).slice(), cr0=P.credits, xp0=P.xp, lv0=P.xpLevel, ha0=JSON.stringify(P.hotAssign||{}), key=null, other=null, ks=Object.keys(ITEMS), i, it, rows, row, n, m, v, c0, x0;
     function sellsAll(r){ return r&&typeof r.label==='string'&&r.label.indexOf('Sell all')===0; }
     for(i=0;i<ks.length;i++){ it=ITEMS[ks[i]]; if(it&&it.name&&!it.gk&&!/^gun_/.test(ks[i])&&ival(ks[i])>0){ if(!key) key=ks[i]; else if(!other){ other=ks[i]; break; } } }
     if(!key||!other) return 'SKIP: no sellable items here';
     try{
       __topClear();
       P.stash=[key,key,key,key,key,key,key,other]; P.kit=[];
       renderHub(); hub.classList.add('on');
       rows=itemMenuRows(key,'stash',7);
       row=rows.filter(sellsAll)[0];
       if(!row) bad.push('a stack of 7 on the Stash screen has no Sell all row on its right-click menu');
       else {
         if(row.label!=='Sell all 7') bad.push('the row reads '+JSON.stringify(row.label)+', not Sell all 7');
         v=ival(key); c0=P.credits; x0=P.xp||0; row.act();
         n=0; m=0; P.stash.forEach(function(q){ if(q===key) n++; if(q===other) m++; });
         if(n!==0) bad.push('Sell all left '+n+' of 7');
         if(m!==1) bad.push('Sell all touched another item ('+m+' left of 1)');
         if(P.credits!==c0+7*v) bad.push('Sell all paid '+(P.credits-c0)+', not '+(7*v));
         if((P.xp||0)!==x0+7*v) bad.push('Sell all paid '+((P.xp||0)-x0)+' XP, not '+(7*v));
       }
       P.stash=[key]; P.kit=[];
       if(itemMenuRows(key,'stash',1).some(sellsAll)) bad.push('a single item offers Sell all');
       P.stash=[key,key,key];
       if(itemMenuRows(key,'kit',3).some(sellsAll)) bad.push('a backpack cell offers Sell all');
       hub.classList.remove('on');
       if(itemMenuRows(key,'stash',3).some(sellsAll)) bad.push('Sell all is offered off the Stash screen');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       P.stash=st0; P.kit=kit0; P.credits=cr0; P.xp=xp0; P.xpLevel=lv0; P.hotAssign=JSON.parse(ha0);
       try{ if(was) hub.classList.add('on'); else hub.classList.remove('on'); }catch(_h){}
       try{ saveProfile(); }catch(_s){} __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
