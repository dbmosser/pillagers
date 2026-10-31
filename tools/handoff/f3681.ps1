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

if ($s.Contains("  {v:'36.81',what:")) { throw "check 36.81 is in the fixture already" }

SubRx @'
  {v:'36.80',what:
'@ @'
  {v:'36.81',what:'the row of number keys is the hotbar on every surface a player reads (his word in every 10-27 order): the backpack panel, the throwable hint, the pad legends, the feeling tag, the lift, the raid callouts and the stash words; none says belt',
   run:function(){
     var bad=[], src='', sc, i, j, k, cm, hint, sp, pj, padL, tt, tb, cut, lines, ln, RX, n=0, keepKit;
     var BW=['be','lt'].join('');
     function belt(s){ return new RegExp('\\b'+BW+'\\b','i').test(String(s||'')); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // ONE: the raid backpack panel
       cm=document.getElementById('carrymodal');
       if(!cm) bad.push('no raid backpack panel');
       else { if(belt(cm.textContent)) bad.push('the backpack panel still says '+BW); if(!/hotbar/i.test(cm.textContent)) bad.push('the backpack panel never says hotbar'); }
       // TWO: the throwable hint
       if(typeof itemUseHint==='function'){ hint=itemUseHint(ITEMS.frag||{use:'throw'}); if(belt(hint)||!/hotbar/i.test(hint)) bad.push('the throwable hint reads '+JSON.stringify(hint)); }
       // THREE: the controller legends
       if(window.__pad&&__pad.legend){ padL=__pad.legend(); tt=[]; for(j=0;j<padL.length;j++) for(k=0;k<padL[j][1].length;k++) tt.push(padL[j][1][k][1]); pj=tt.join(' | '); if(belt(pj)) bad.push('the controller legend still says '+BW); if(!/hotbar/i.test(pj)) bad.push('the controller legend never says hotbar'); }
       tb={LEGEND:(typeof LEGEND!=='undefined')?LEGEND:null,LEGEND_PAD:(typeof LEGEND_PAD!=='undefined')?LEGEND_PAD:null,GEARRULES:(typeof GEARRULES!=='undefined')?GEARRULES:null};
       for(k in tb) if(tb[k]&&belt(JSON.stringify(tb[k]))) bad.push(k+' still says '+BW);
       // FOUR: the feeling tag, and an old saved one still reads right
       if(typeof TAGS!=='undefined'){ for(i=0;i<TAGS.length;i++) if(belt(TAGS[i])) bad.push('the tag "'+TAGS[i]+'" says '+BW); if(TAGS.indexOf('Hotbar worked well')<0) bad.push('no feeling tag reads Hotbar worked well'); }
       if(typeof tagText==='function'&&tagText(['Tactical ','belt worked well'].join(''))!=='Hotbar worked well') bad.push('a tag saved with the old word does not read hotbar');
       // FIVE: the lift panel
       P.kitPick='mine'; saveProfile(); renderSector(); openModal('sectormodal');
       sp=document.getElementById('sectorplan');
       if(!sp) bad.push('no lift hotbar panel'); else { if(belt(sp.textContent)) bad.push('the lift panel still says '+BW); if(!/hotbar/i.test(sp.textContent)) bad.push('the lift panel never says hotbar'); }
       // SIX: the words drawn on canvas and said in callouts live in the script. Read every code line (comments, the news list and tag lists left out).
       sc=document.scripts; for(i=0;i<sc.length;i++) src+=sc[i].textContent;
       cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
       if(src.length<100000) bad.push('the build cannot read its own script');
       else {
         src=src.replace(/\/\*[\s\S]*?\*\//g,'').replace(/<!--[\s\S]*?-->/g,'');
         RX=[new RegExp(['tactical ','belt'].join(''),'i'),new RegExp(['NO HEAL ON ','BELT'].join('')),new RegExp(["'ON ","BELT'"].join('')),new RegExp(["BELT '","\\+"].join('')),new RegExp(['<b>',BW,'<\\/b>'].join('')),new RegExp(["'",BW," [-+]'"].join('')),new RegExp(['minimap and ',BW].join(''))];
         lines=src.split('\n');
         for(i=0;i<lines.length&&n<6;i++){
           ln=lines[i].replace(/^\s+/,''); if(ln.charAt(0)==="'"||ln.indexOf('//')===0||ln.indexOf('var TAGFWD')===0) continue;
           ln=ln.replace(/\s\/\/\s.*$/,'');
           for(j=0;j<RX.length;j++) if(RX[j].test(ln)){ bad.push('code still says '+BW+': '+ln.slice(Math.max(0,ln.search(RX[j])-30),ln.search(RX[j])+50)); n++; break; }
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'36.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
