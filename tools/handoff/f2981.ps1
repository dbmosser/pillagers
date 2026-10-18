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

if ($s.Contains("  {v:'29.81',what:")) { throw "check 29.81 is in the fixture already" }

SubRx @'
  {v:'29.80',what:
'@ @'
  {v:'29.81',what:'the Killed in action card shows its stats as a row of four cells (24px value over a 16px label) and the old stats sentence is hidden text, not read on screen (critic: a run-on dotted sentence at 14px; screens 35 38 60)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: cannot deploy and end a raid here';
     var man=document.getElementById('oc_manifest'), oc=document.getElementById('outcome');
     if(!man||!oc) return 'SKIP: no outcome card in the page';
     var bad=[], g, row, cells, b, sp, cs, i, n=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       man.innerHTML='';
       __endRaid('dead');
       if(g.over!=='dead'||!oc.classList.contains('on')) return 'SKIP: the death card was not drawn here';
       if(man.querySelector('.lg')) return 'SKIP: a career ledger card, not this card';
       row=man.querySelector('.ocstat');
       if(!row) return 'the stats are not a row of cells';
       cells=row.children;
       if(cells.length!==4) bad.push('the stats row has '+cells.length+' cells, not 4');
       else {
         b=cells[0].querySelector('b'); sp=cells[0].querySelector('span');
         if(Math.round(parseFloat(getComputedStyle(b).fontSize))!==24) bad.push('the value is '+getComputedStyle(b).fontSize+', not 24px');
         if(Math.round(parseFloat(getComputedStyle(sp).fontSize))!==16) bad.push('the label is '+getComputedStyle(sp).fontSize+', not 16px');
       }
       if(!(row.offsetHeight>40)) bad.push('the stats row is not on screen');
       sp=man.querySelectorAll('.ocsr');
       for(i=0;i<sp.length;i++) if(getComputedStyle(sp[i]).display!=='none') n++;
       if(n) bad.push(n+' old sentence lines still show');
       if(String(man.textContent||'').indexOf(' accuracy')<0) bad.push('the old stats words left the card text');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_f){}
       try{ man.innerHTML=''; oc.classList.remove('on'); }catch(_g){}
     }
   }},
  {v:'29.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
