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

if ($s.Contains("  {v:'29.57',what:")) { throw "check 29.57 is in the fixture already" }

SubRx @'
  {v:'29.56',what:
'@ @'
  {v:'29.57',what:'the pause card gives its title and its Esc hint 28px or more of air on a keyboard',
   run:function(){
     var bad=[], pb=document.getElementById('pausebox'), h3, r, cr, ch, sc, topGap, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||__state().over) return 'SKIP: no live raid';
       togglePauseBox(true); pauseFrameFit();
       h3=pb.querySelector('h3'); if(!h3) return 'no pause title';
       r=pb.getBoundingClientRect(); sc=pb.offsetHeight?r.height/pb.offsetHeight:1;
       ch=parseFloat(getComputedStyle(pb,'::before').height)*sc;
       cr=r.top+r.height/2-ch/2;
       topGap=h3.getBoundingClientRect().top-cr;
       if(topGap<28*sc) bad.push('the title is only '+Math.round(topGap/sc)+'px under the card top');
       var kids=pb.children, bo=-1e9, i; for(i=0;i<kids.length;i++){ if(kids[i].offsetHeight>0) bo=Math.max(bo,kids[i].getBoundingClientRect().bottom); }
       var below=(cr+ch)-bo;
       if(below<(32+16+8)*sc-4) bad.push('only '+Math.round(below/sc)+'px under the last button, no room for the Esc hint');
     } finally { try{ togglePauseBox(false); }catch(_t){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'29.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
