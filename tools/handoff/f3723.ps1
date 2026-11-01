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

if ($s.Contains("  {v:'37.23',what:")) { throw "check 37.23 is in the fixture already" }

SubRx @'
  {v:'37.22',what:
'@ @'
  {v:'37.23',what:'cw-m1rankui, critic on the Mainframe rank strip (P1 both screens: labels about 13px under the 16px floor, lime three times): every text in the strip is 16px or more, no text in it is lime, and lime is the bar fill only',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof openOps!=='function'||typeof renderRank!=='function'||typeof RANKS==='undefined') return 'SKIP: no rank strip here';
     var saved=P, oldStore=storeSet, oldSave=saveProfile, bad=[], el, all, i, e, cs, amb, tmp, own, n=0;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P=JSON.parse(JSON.stringify(saved)); storeSet=function(){}; saveProfile=function(){};
       P.lifeEarn=RANKS[1].need+5000; delete P.sellDay; P.rankPaid=[0,1]; P.mig1r=1;
       openOps('con');
       el=document.getElementById('rankstrip');
       if(!el||!(el.getBoundingClientRect().height>0)) return 'the Mainframe rank strip is not on screen';
       tmp=document.createElement('div'); tmp.style.color='var(--amber)'; el.appendChild(tmp); amb=getComputedStyle(tmp).color; el.removeChild(tmp);
       all=el.querySelectorAll('*');
       for(i=0;i<all.length;i++){
         e=all[i]; own=''; [].forEach.call(e.childNodes,function(c){ if(c.nodeType===3) own+=c.textContent; });
         if(!own.trim()) continue;
         n++; cs=getComputedStyle(e);
         need(parseFloat(cs.fontSize)>=16,'"'+own.trim()+'" is '+cs.fontSize+', under 16px');
         need(cs.color!==amb,'"'+own.trim()+'" is lime');
       }
       need(n>=6,'only '+n+' texts in the strip');
       e=document.getElementById('rankfill');
       need(e&&getComputedStyle(e).backgroundColor===amb,'the bar fill is not lime');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ P=saved; storeSet=oldStore; saveProfile=oldSave; try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'37.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
