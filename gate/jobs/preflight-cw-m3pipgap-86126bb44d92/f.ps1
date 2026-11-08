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

if ($s.Contains("  {v:'37.62',what:")) { throw "check 37.62 is in the fixture already" }

SubRx @'
  {v:'37.61',what:
'@ @'
  {v:'37.62',what:'cw-m3pipgap: on the extract card the pip lines of the worn pieces sit in one block and the last one ends at least 16px above the stats row',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof wornPipGain!=='function'||typeof wornMake!=='function') return 'SKIP: no pips here';
     var saved=P, oldStore=storeSet, oldSave=saveProfile, bad=[], g, q, x, sp, st, last, i, man;
     function kindFor(s){ for(var k in WORN_KINDS) if(Object.prototype.hasOwnProperty.call(WORN_KINDS,k)&&WORN_KINDS[k].slots.indexOf(s)>=0) return k; return null; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.terms=[]; P.merc=''; P.worn={}; P.gear=[];
       q=['head','boots','gloves'];
       for(i=0;i<q.length;i++){ x=wornAdd(P,wornMake(kindFor(q[i]),i+1,10,51+i)); wornWear(P,x.id,q[i]); }
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       g.bag=['core']; g.carriedIn=0; g.carriedKit=[]; g.ents.length=0; g.player.iv=99; g.tel.shots=3;
       __endRaid('extract');
       man=document.getElementById('oc_manifest');
       sp=man?man.querySelectorAll('span'):[]; last=null;
       for(i=0;i<sp.length;i++) if(/ pip \d$/.test(sp[i].textContent)) last=sp[i];
       st=man?man.querySelector('.ocstat'):null;
       if(!last) bad.push('no pip line on the extract card');
       else if(!st) bad.push('control: no stats row on the extract card');
       else { var gap=st.getBoundingClientRect().top-last.getBoundingClientRect().bottom; if(!(gap>=16)) bad.push('the last pip line ends '+Math.round(gap)+'px above the stats row, not 16 or more'); }
       if(last&&!(last.parentNode&&last.parentNode.classList&&last.parentNode.classList.contains('ocpips'))) bad.push('the pip lines are not one block');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ g=__state(); if(g&&!g.over){ g.tel.shots=0; __endRaid('abandon'); } }catch(_e){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
