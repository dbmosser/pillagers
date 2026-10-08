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

if ($s.Contains("  {v:'19.23',what:")) { throw "check 19.23 is in the fixture already" }

SubRx @'
  {v:'19.22',what:
'@ @'
  {v:'19.23',what:'the shop panel shows what a heal does in numbers: with the Bandage chosen the cream panel names its heal, how long and up to 85, and a Medkit heals up to 100',
   run:function(){
     if(!window.__station||!window.__hubEnter) return 'SKIP: this fixture cannot open the shop';
     var bad=[], d, t, i, rows, sel0=P._shopSel, idx=-1, tx;
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('trader','KeyE');
       rows=document.getElementById('shop'); d=document.getElementById('shopdetail');
       if(!rows||!d||typeof renderShopGrid!=='function') return 'SKIP: no shop panel';
       for(i=0;i<rows.children.length;i++){ tx=String(rows.children[i].textContent||''); if(tx.indexOf(ITEMS.bandage.name)>=0){ idx=i; break; } }
       if(idx<0) return 'SKIP: no Bandage on the shelf';
       P._shopSel=idx; renderShopGrid();
       tx=String(d.textContent||'');
       if(tx.indexOf(ITEMS.bandage.name)<0) return 'SKIP: the panel does not show the Bandage';
       if(tx.indexOf('Heals up to')<0) bad.push('the Bandage panel shows no numbers: '+tx.slice(0,120));
       else{
         if(tx.indexOf('85 health')<0) bad.push('the Bandage panel does not say it heals up to 85');
         if(tx.indexOf(String(ITEMS.bandage.amt)+' health')<0) bad.push('the Bandage panel does not say how much it heals');
       }
       if(typeof itemStatsHTML==='function'){
         if(String(itemStatsHTML('medkit')).indexOf('100 health')<0) bad.push('a Medkit does not say it heals up to 100');
         if(String(itemStatsHTML('plate')).indexOf('Armour')<0) bad.push('a plate shows no armour');
         if(itemStatsHTML('scrap')) bad.push('salvage grew a stat block');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P._shopSel=sel0; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
