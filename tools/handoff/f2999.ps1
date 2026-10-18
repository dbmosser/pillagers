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

if ($s.Contains("  {v:'29.99',what:")) { throw "check 29.99 is in the fixture already" }

SubRx @'
  {v:'29.98',what:
'@ @'
  {v:'29.99',what:'the Abandoned card shows the loot left behind as one 56px figure with a label (critic: no hero line; screen 60), the old words kept hidden',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: cannot deploy and end a raid here';
     var man=document.getElementById('oc_manifest'), oc=document.getElementById('outcome');
     if(!man||!oc) return 'SKIP: no outcome card in the page';
     var bad=[], g, nt, hb, xs;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.bag) return 'SKIP: no live raid bag';
       g.t=60; try{ g.tel.shots=3; }catch(_s){}
       man.innerHTML='';
       __endRaid('abandon');
       if(g.over!=='abandon'||!oc.classList.contains('on')) return 'SKIP: the abandon card was not drawn here';
       hb=man.querySelector('.ocloss b');
       if(!hb) bad.push('the Abandoned card has no loss figure');
       else{
         if(Math.abs(parseFloat(getComputedStyle(hb).fontSize)-56)>1.5) bad.push('the loss figure is '+getComputedStyle(hb).fontSize+', not 56px');
         if(!hb.offsetParent||hb.offsetHeight<40) bad.push('the loss figure is not on screen');
       }
       nt=man.querySelector('.ocnote');
       if(!nt) bad.push('the old loot words are gone');
       else{
         if(getComputedStyle(nt).display!=='none') bad.push('the loot sentence still shows beside the figure');
         if(String(nt.textContent).indexOf('Run abandoned.')!==0||String(nt.textContent).indexOf('left behind.')<0) bad.push('the loot line words changed: '+nt.textContent);
       }
       xs=man.querySelector('span[style*="var(--amber)"]');
       if(xs&&parseFloat(getComputedStyle(xs).fontSize)<15.5) bad.push('the XP line is '+getComputedStyle(xs).fontSize+', under 16px');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_f){}
       try{ man.innerHTML=''; oc.classList.remove('on'); }catch(_g){}
     }
   }},
  {v:'29.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
