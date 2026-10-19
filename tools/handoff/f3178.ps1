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

if ($s.Contains("  {v:'31.78',what:")) { throw "check 31.78 is in the fixture already" }

SubRx @'
  {v:'31.77',what:
'@ @'
  {v:'31.78',what:'an end card chip is a flat name with no box, the contract line has a tick, the armed abandon confirm keeps its X and puts its cost on its own line (the critic on 38, 59, 60)',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__state&&window.__P)) return 'SKIP: this build cannot end a raid';
     var bad=[], P2=__P(), keepAE=P2.autoExport, oc=document.getElementById('outcome'), man, c1, c2, cs, pb, abtn, cb, px, sm, wasShown;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.autoExport=false;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __state().bag.push('core','scrap');
       __endRaid('extract');
       if(!oc.classList.contains('on')) return 'the extracted card did not open';
       man=document.getElementById('oc_manifest');
       c1=document.createElement('span'); c1.className='ocach'; c1.textContent='first out';
       c2=document.createElement('span'); c2.className='ocach ocok'; c2.textContent='untouched';
       man.appendChild(c1); man.appendChild(c2);
       cs=getComputedStyle(c1);
       if(parseFloat(cs.borderTopWidth)>0||parseFloat(cs.borderLeftWidth)>0) bad.push('a chip still has a '+cs.borderTopWidth+' box');
       if(cs.backgroundColor!=='rgba(0, 0, 0, 0)'&&cs.backgroundColor!=='transparent') bad.push('a chip still has a fill '+cs.backgroundColor);
       if(String(getComputedStyle(c2,'::before').content).indexOf('\u2713')<0) bad.push('the contract chip has no tick');
       man.removeChild(c1); man.removeChild(c2);
       oc.classList.remove('on');
       abtn=document.getElementById('abandonbtn'); cb=document.getElementById('confirmabandon'); pb=document.getElementById('pausebox'); px=document.getElementById('pausex');
       if(!abtn||!cb||!pb||!px) return 'the pause box has no abandon, confirm or X';
       wasShown=cb.style.display;
       if(cb.style.display!=='none') abtn.click();
       abtn.click();
       if(!pb.classList.contains('asking')) bad.push('the confirm did not arm');
       if(getComputedStyle(px).display==='none') bad.push('the armed confirm has no X');
       if(/\(/.test(cb.textContent)) bad.push('the confirm still has a bracket: '+cb.textContent.trim());
       sm=cb.querySelector('small');
       if(!sm) bad.push('the confirm has no cost line'); else if(!/xp|free/i.test(sm.textContent)) bad.push('the cost line reads '+sm.textContent);
       if(!/^YES, ABANDON THIS RUN/i.test(cb.textContent.trim())) bad.push('the confirm reads '+cb.textContent.trim());
       abtn.click(); cb.style.display=wasShown||'none';
       return bad.length?bad.join('; '):null;
     } finally {
       P2.autoExport=keepAE;
       try{ oc.classList.remove('on'); }catch(_e){}
       __topClear(); try{ __cleanProfile(); }catch(_e2){}
     } }},
  {v:'31.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
