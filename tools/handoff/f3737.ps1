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

if ($s.Contains("  {v:'37.37',what:")) { throw "check 37.37 is in the fixture already" }

SubRx @'
  {v:'37.36',what:
'@ @'
  {v:'37.37',what:'cw-m2birth3: on the birth card a kit he cannot pay for is disabled at full opacity with its price in the danger colour and its other words not, and the picked heir card has a lime bar the others do not',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof birthOpen!=='function') return 'no birth card in this build';
     var saved=P, oldStore=storeSet, oldSave=saveProfile, bad=[], b, cs, L, red;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.credits=100; P.birthKit=null; BIRTH=null;
       pilEnd(P,{how:'dead'}); pilHeirs(P);
       showScreen('hub');
       need(document.getElementById('birthmodal').classList.contains('on'),'the card did not open');
       b=document.querySelector('#birthkits [data-bkit="basic"]');
       cs=getComputedStyle(b);
       need(b.disabled&&parseFloat(cs.opacity)===1,'the unaffordable row: disabled '+b.disabled+', opacity '+cs.opacity);
       L=b.querySelectorAll('b');
       red=document.createElement('i'); red.style.color='var(--danger)'; document.body.appendChild(red);
       need(getComputedStyle(L[L.length-1]).color===getComputedStyle(red).color,'the price is '+getComputedStyle(L[L.length-1]).color+', not the danger colour '+getComputedStyle(red).color);
       need(getComputedStyle(L[0]).color!==getComputedStyle(red).color,'the kit name is red too');
       red.remove();
       L=document.querySelectorAll('#birthheirs .bhcard');
       need(/rgb/.test(getComputedStyle(L[0]).boxShadow)&&getComputedStyle(L[1]).boxShadow==='none','the bar: picked '+getComputedStyle(L[0]).boxShadow+', other '+getComputedStyle(L[1]).boxShadow);
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ document.getElementById('birthmodal').classList.remove('on'); }catch(_m){}
       BIRTH=null;
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
