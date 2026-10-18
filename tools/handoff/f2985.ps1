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

if ($s.Contains("  {v:'29.85',what:")) { throw "check 29.85 is in the fixture already" }

SubRx @'
  {v:'29.84',what:
'@ @'
  {v:'29.85',what:'the end card stat row is four equal 140px cells, the chips lose the amber bar and the Haul label is its own 20px line over the figure (critic: unequal cells, three amber accents, Haul as big as the number; screens 35 and 38)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: cannot deploy and end a raid here';
     var man=document.getElementById('oc_manifest'), oc=document.getElementById('outcome');
     if(!man||!oc) return 'SKIP: no outcome card in the page';
     var bad=[], g, cells, w, i, ach, el, lab, oldR, tmp;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.bag) return 'SKIP: no live raid bag';
       man.innerHTML='';
       __endRaid('dead');
       if(g.over!=='dead'||!oc.classList.contains('on')) return 'SKIP: the death card was not drawn here';
       if(man.querySelector('.lg')) return 'SKIP: a career ledger card, not this card';
       cells=man.querySelectorAll('.ocstat > div');
       if(cells.length!==4) bad.push(cells.length+' stat cells, not 4');
       else{
         w=cells[0].offsetWidth;
         for(i=1;i<4;i++) if(Math.abs(cells[i].offsetWidth-w)>1) bad.push('stat cell '+i+' is '+cells[i].offsetWidth+'px, cell 0 is '+w);
         if(w<130||w>175) bad.push('a stat cell is '+w+'px, not about 140');
       }
       tmp=document.createElement('span'); tmp.className='ocach'; man.appendChild(tmp);
       if(parseFloat(getComputedStyle(tmp).borderLeftWidth)>1.5) bad.push('a chip still has a '+getComputedStyle(tmp).borderLeftWidth+' left bar, not 1px');
       man.removeChild(tmp);
       if(typeof haulTotalLine==='function'&&typeof HAUL_REV!=='undefined'){
         oldR=HAUL_REV; el=document.createElement('div'); el.className='haultot'; el.id='haultot'; man.appendChild(el);
         HAUL_REV={sum:1770}; haulTotalLine();
         lab=el.querySelector('.htl');
         if(!lab) bad.push('the Haul label is not its own line');
         else if(Math.abs(parseFloat(getComputedStyle(lab).fontSize)-20)>1.5) bad.push('the Haul label is '+getComputedStyle(lab).fontSize+', not 20px');
         if(String(el.textContent).indexOf('1,770')<0) bad.push('the haul figure left the line');
         man.removeChild(el); HAUL_REV=oldR;
       }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_f){}
       try{ man.innerHTML=''; oc.classList.remove('on'); }catch(_g){}
     }
   }},
  {v:'29.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
