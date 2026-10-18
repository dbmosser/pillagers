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

if ($s.Contains("  {v:'29.83',what:")) { throw "check 29.83 is in the fixture already" }

SubRx @'
  {v:'29.82',what:
'@ @'
  {v:'29.83',what:'the Killed in action card shows what you lost as one tile row with a 56px loss figure, and the Lost sentences are hidden text (critic: five rows each repeating Lost, no hero; screen 35)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: cannot deploy and end a raid here';
     var man=document.getElementById('oc_manifest'), oc=document.getElementById('outcome');
     if(!man||!oc) return 'SKIP: no outcome card in the page';
     var bad=[], g, tiles, hero, sp, i, n=0, k;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.bag) return 'SKIP: no live raid bag';
       for(k=0;k<9;k++) g.bag.push('bandage');
       man.innerHTML='';
       __endRaid('dead');
       if(g.over!=='dead'||!oc.classList.contains('on')) return 'SKIP: the death card was not drawn here';
       if(man.querySelector('.lg')) return 'SKIP: a career ledger card, not this card';
       if(String(man.textContent||'').indexOf(' lost, ')<0) return 'SKIP: nothing was lost on this card';
       tiles=man.querySelectorAll('.octile');
       if(!tiles.length) return 'what you lost is not a tile row';
       if(tiles[0].offsetWidth!==64) bad.push('a tile is '+tiles[0].offsetWidth+'px, not 64');
       hero=man.querySelector('.ocloss b');
       if(!hero) bad.push('no loss figure');
       else if(Math.round(parseFloat(getComputedStyle(hero).fontSize))!==56) bad.push('the loss figure is '+getComputedStyle(hero).fontSize+', not 56px');
       sp=man.querySelectorAll('.ocsr');
       for(i=0;i<sp.length;i++) if(getComputedStyle(sp[i]).display!=='none') n++;
       if(n) bad.push(n+' old sentence lines still show');
       if(String(man.textContent||'').indexOf('LOST')<0&&String(man.textContent||'').toLowerCase().indexOf('lost')<0) bad.push('the old words left the card text');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_f){}
       try{ man.innerHTML=''; oc.classList.remove('on'); }catch(_g){}
     }
   }},
  {v:'29.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
