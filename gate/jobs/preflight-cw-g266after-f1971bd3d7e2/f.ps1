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

if ($s.Contains("  {v:'37.42',what:")) { throw "check 37.42 is in the fixture already" }

SubRx @'
  {v:'37.41',what:
'@ @'
  {v:'37.42',what:'PROBE ONLY (never shipped, job 266): the six behind the checks before them, on the fixture fix',
   run:function(){
     if(window.__p266!==undefined){ var tail=window.__p266; window.__p266=undefined; return tail||'-'; }
     var out=[], t00=performance.now(), Q={}, i, me=this.v;
     for(i=0;i<__REGRESS.length;i++) Q[__REGRESS[i].v]=i;
     function el(){ return (performance.now()-t00)/1000; }
     function life(){ return (P&&P.pil)?'L':'D'; }
     function mods(){ return [].map.call(document.querySelectorAll('.modal.on'),function(m){ return m.id.replace('modal',''); }).join('+')||'none'; }
     function sh(r){ return r?String(r).slice(0,9):'ok'; }
     function bare(v){ var t=__REGRESS[Q[v]], r; if(!t) return 'nochk'; __topClear(); __ctxHeal(); try{ r=t.run(); }catch(e){ r='threw '+e; } return sh(r); }
     // E: no step between checks but __topClear, as a runner without the new line: __hubEnter alone must bring him back
     __runPrep(); __topClear(); bare('8.64');
     var e0=life(); __topClear(); __hubEnter();
     out.push('E '+e0+' hub['+mods()+' '+life()+']');
     var A=['8.84','8.95','8.96','9.32'], B=[];
     for(i=0;i<A.length;i++){ bare('8.64'); B.push(A[i]+'='+bare(A[i])); }
     bare('24.36'); B.push('24.35='+bare('24.35')); B.push('25.34='+bare('25.34'));
     out.push(B.join(' '));
     // M: the birth and hall checks, which stage nobody living on purpose, in slice style
     A=['37.39','37.38','37.37','37.36','37.35','37.34','37.33','37.30','37.29','37.21','37.20','37.19','37.18','37.14']; B=[];
     for(i=0;i<A.length;i++){ var mr=bare(A[i]); if(mr!=='ok') B.push(A[i]+'='+mr); }
     out.push('M'+A.length+' red:'+(B.join(',')||'none'));
     // W: a stretch of the real list in one tab, exactly the step __regressBg takes
     function win(tag,a,b,limit,T){
       var j,t,r,ran=0,skip=0,fails=[],six=[],rest=0;
       __runPrep();
       for(j=Math.max(0,a);j<=b;j++){ t=__REGRESS[j]; if(!t||t.v===me) continue;
         var isT=T.indexOf(t.v)>=0;
         if(!isT&&el()>limit){ skip++; continue; }
         __topClear(); __ctxHeal(); rest+=__pilLive();
         try{ r=t.run(); }catch(e){ r='threw '+e; }
         ran++;
         if(isT) six.push(t.v+'='+sh(r));
         else if(r&&String(r).indexOf('SKIP: ')!==0) fails.push(t.v);
       }
       out.push(tag+' ran'+ran+' skip'+skip+' rest'+rest+' '+six.join(' ')+' red:'+(fails.slice(0,8).join(',')||'none'));
     }
     win('W1',0,Q['9.32'],100,['8.84','8.95','8.96','9.32']);
     win('W2',Q['25.34']-40,Q['25.34'],125,['25.34']);
     win('W3',Q['24.35']-40,Q['24.35'],150,['24.35']);
     var s='PROBE '+out.join(' ')+' '+Math.round(el())+'s';
     window.__p266=s.slice(300,600);
     return s.slice(0,300);
   }},
  {v:'37.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
