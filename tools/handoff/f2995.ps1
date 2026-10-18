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

if ($s.Contains("  {v:'29.95',what:")) { throw "check 29.95 is in the fixture already" }

SubRx @'
  {v:'29.94',what:
'@ @'
  {v:'29.95',what:'the end cards lead with a 40px title, 72px loss tiles and the Abandoned loot line is its own 24px line (critic: title too small, tiles small, no focal line; screens 35 and 60)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: cannot deploy and end a raid here';
     var man=document.getElementById('oc_manifest'), oc=document.getElementById('outcome');
     if(!man||!oc) return 'SKIP: no outcome card in the page';
     var bad=[], g, h1, tmp, wrap, nt, fs;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.bag) return 'SKIP: no live raid bag';
       g.t=60; try{ g.tel.shots=3; }catch(_s){}
       man.innerHTML='';
       __endRaid('abandon');
       if(g.over!=='abandon'||!oc.classList.contains('on')) return 'SKIP: the abandon card was not drawn here';
       h1=document.getElementById('oc_title')||oc.querySelector('h1');
       if(h1&&Math.abs(parseFloat(getComputedStyle(h1).fontSize)-40)>1.5) bad.push('the card title is '+getComputedStyle(h1).fontSize+', not 40px');
       nt=man.querySelector('.ocnote');
       if(!nt) bad.push('the Abandoned loot line is not its own line');
       else{
         fs=parseFloat(getComputedStyle(nt).fontSize);
         if(Math.abs(fs-24)>1.5) bad.push('the loot line is '+fs+'px, not 24');
         if(String(nt.textContent).indexOf('Run abandoned.')!==0||String(nt.textContent).indexOf('left behind.')<0) bad.push('the loot line words changed: '+nt.textContent);
       }
       wrap=document.createElement('div'); wrap.className='octiles'; tmp=document.createElement('div'); tmp.className='octile'; wrap.appendChild(tmp); man.appendChild(wrap);
       if(Math.abs(tmp.offsetWidth-72)>1.5) bad.push('a loss tile is '+tmp.offsetWidth+'px, not 72');
       man.removeChild(wrap);
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_f){}
       try{ man.innerHTML=''; oc.classList.remove('on'); }catch(_g){}
     }
   }},
  {v:'29.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
