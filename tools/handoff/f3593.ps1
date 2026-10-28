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

if ($s.Contains("  {v:'35.93',what:")) { throw "check 35.93 is in the fixture already" }

SubRx @'
  {v:'35.92',what:
'@ @'
  {v:'35.93',what:'menus master polish 2026-10-28: Wirt: THE GAMBLE panel shows a mystery tile the size of the offer picture and the odds of each rarity read from GAMBLE_POOL (it was an empty box over its button); the stash hotbar sits on the same 12px inset as the backpack grid above it (its slots ran to the panel edge)',
   run:function(){
     if(typeof renderGamble!=='function'||typeof GAMBLE_POOL==='undefined'||typeof RCOL!=='object') return 'SKIP: no gambler here';
     var bad=[], g0=P.gambleLog, el, rows, i, by={}, tot=0, k, r, pc, sum=0, want=0, sc, hp, kc, row1;
     try{
       P.gambleLog=[];
       renderGamble();
       el=document.getElementById('gambleodds');
       if(!el) return 'the gamble panel has no odds block';
       if(!el.querySelector('.gbtile')) bad.push('the gamble panel has no mystery tile');
       for(i=0;i<GAMBLE_POOL.length;i++){ k=GAMBLE_POOL[i][0]; r=(k==='KEY')?'rare':((typeof dispR==='function'&&dispR(k))||(ITEMS[k]&&ITEMS[k].r)||'common'); by[r]=(by[r]||0)+(+GAMBLE_POOL[i][1]||0); tot+=(+GAMBLE_POOL[i][1]||0); }
       for(k in by) want++;
       rows=el.querySelectorAll('.gbrow');
       if(rows.length!==want) bad.push('the odds list '+rows.length+' rarities, not '+want);
       for(i=0;i<rows.length;i++){
         r=(rows[i].querySelector('span')||{}).textContent; pc=parseInt((rows[i].querySelector('em')||{}).textContent,10); sum+=pc;
         if(!(r in by)) bad.push('an odds row names '+r+', not a rarity in the pool');
         else if(Math.abs(pc-Math.round(by[r]*100/tot))>0) bad.push(r+' reads '+pc+'%, not '+Math.round(by[r]*100/tot)+'%');
         if(RCOL[r]&&rows[i].style.getPropertyValue('--rc').trim()!==RCOL[r]) bad.push(r+' is not drawn in its rarity colour');
       }
       if(Math.abs(sum-100)>2) bad.push('the odds add to '+sum+'%');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ P.gambleLog=g0; try{ renderGamble(); }catch(_r){} }
     // the stash hotbar inset
     if(window.__hubEnter&&window.__station){
       try{
         __topClear(); __runPrep(); __pinDPR(1); __resetCfg(); __pinDefaults(0); __cleanProfile();
         __hubEnter(); __station('term','KeyE'); renderHub();
         kc=document.querySelectorAll('#kitgrid .cell'); hp=document.querySelectorAll('#hotplanwrap [data-plan]');
         if(kc.length<2||hp.length<2) bad.push('staging: '+kc.length+' backpack cells and '+hp.length+' hotbar slots on the stash screen');
         else {
           sc=kc[0].getBoundingClientRect(); row1=kc[0]; for(i=1;i<kc.length;i++) if(Math.abs(kc[i].getBoundingClientRect().top-sc.top)<2) row1=kc[i];
           if(Math.abs(hp[0].getBoundingClientRect().left-sc.left)>1.5) bad.push('the first hotbar slot starts at x '+Math.round(hp[0].getBoundingClientRect().left)+', the backpack at '+Math.round(sc.left));
           if(Math.abs(hp[hp.length-1].getBoundingClientRect().right-row1.getBoundingClientRect().right)>1.5) bad.push('the last hotbar slot ends at x '+Math.round(hp[hp.length-1].getBoundingClientRect().right)+', the backpack row at '+Math.round(row1.getBoundingClientRect().right));
         }
       }catch(x2){ bad.push('threw on the stash: '+(x2&&x2.message||x2)); }
       finally{ __topClear(); }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
