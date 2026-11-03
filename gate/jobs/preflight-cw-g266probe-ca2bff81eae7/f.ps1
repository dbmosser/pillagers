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

if ($s.Contains("  {v:'37.41',what:")) { throw "check 37.41 is in the fixture already" }

SubRx @'
  {v:'37.40',what:
'@ @'
  {v:'37.41',what:'PROBE ONLY (never shipped, job 266): which window covers the Undercroft after a check ends the pillager',
   run:function(){
     if(window.__p266!==undefined){ var tail=window.__p266; window.__p266=undefined; return tail||'-'; }
     var out=[], t00=performance.now(), Q={}, i, oTC=window.__topClear;
     for(i=0;i<__REGRESS.length;i++) Q[__REGRESS[i].v]=i;
     function mods(){ return [].map.call(document.querySelectorAll('.modal.on'),function(m){ return m.id.replace('modal',''); }).join('+')||'none'; }
     function life(){ return (P&&P.pil)?'L':'D'; }
     function rr(t){ var r; __topClear(); __ctxHeal(); try{ r=t.run(); }catch(e){ r='threw '+e; } return r; }
     function one(v){ var t=__REGRESS[Q[v]], r; if(!t) return v+'=nochk'; r=rr(t); return v+'='+(r?String(r).slice(0,9):'ok')+life(); }
     function enter(){ __topClear(); __hubEnter(); return 'hub['+mods()+' need'+(birthNeed()?1:0)+']'; }
     function prev(v,n){ var k=Q[v], j, s=life(), a=[]; for(j=k-n;j<k;j++){ rr(__REGRESS[j]); if(life()!==s){ s=life(); a.push(__REGRESS[j].v+'>'+s); } } return a.join(',')||'nochange'; }
     // ONE: the slice as it runs: 8.64 ends him (dead, then two quits), no check brings him back
     __runPrep(); __topClear();
     out.push('ONE '+life()+' '+one('8.64')+' '+enter());
     out.push(one('8.84')); out.push(one('8.95')); out.push(one('8.96')); out.push(one('9.32'));
     // TWO: 24.35 behind the checks before it
     __runPrep(); __topClear();
     out.push('TWO '+prev('24.35',4)+' '+enter()); out.push(one('24.35'));
     // THREE: 25.34 behind the checks before it, then with a living start: it ends him itself
     __runPrep(); __topClear();
     out.push('THREE '+prev('25.34',2)+' '+enter()); out.push(one('25.34'));
     __runPrep(); __topClear(); out.push('alone '+one('25.34'));
     // FOUR: the alone control for the other five
     var A=['8.84','8.95','8.96','9.32','24.35'], B=[];
     for(i=0;i<A.length;i++){ __runPrep(); B.push(one(A[i])); }
     out.push('FOUR '+B.join(' '));
     // FIVE: the planned fixture fix tried by hand: __topClear closes the card and restores a living pillager
     try{
       window.__topClear=function(){ var n=oTC(); try{ var m=document.getElementById('birthmodal'); if(m) m.classList.remove('on'); if(birthNeed()){ P.hall=[]; P.pil=null; P.pilGen=0; P.pilNote=null; acctEnsure(P); saveProfile(); } }catch(_f){} return n; };
       __runPrep(); __topClear();
       B=[one('8.64'),one('8.84'),one('8.95'),one('8.96'),one('9.32'),one('25.34')];
       prev('24.35',4); B.push(one('24.35'));
       out.push('FIVE '+B.join(' '));
     } finally { window.__topClear=oTC; }
     var s='PROBE '+out.join(' ')+' '+Math.round((performance.now()-t00)/1000)+'s';
     window.__p266=s.slice(300,600);
     return s.slice(0,300);
   }},
  {v:'37.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
