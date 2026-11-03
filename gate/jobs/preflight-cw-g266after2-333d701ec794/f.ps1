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
  {v:'37.42',what:'PROBE ONLY (never shipped, job 266): the real slice stretches before 25.34 and 24.35 and the rest before 9.32, on the fixture fix',
   run:function(){
     if(window.__p266!==undefined){ var tail=window.__p266; window.__p266=undefined; return tail||'-'; }
     var out=[], t00=performance.now(), Q={}, i, me=this.v;
     for(i=0;i<__REGRESS.length;i++) Q[__REGRESS[i].v]=i;
     function el(){ return (performance.now()-t00)/1000; }
     function life(){ return (P&&P.pil)?'L':'D'; }
     function mods(){ return [].map.call(document.querySelectorAll('.modal.on'),function(m){ return m.id.replace('modal',''); }).join('+')||'none'; }
     function sh(r){ return r?String(r).slice(0,9):'ok'; }
     function bare(v){ var t=__REGRESS[Q[v]], r; if(!t) return 'nochk'; __topClear(); __ctxHeal(); try{ r=t.run(); }catch(e){ r='threw '+e; } return sh(r); }
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
     function st(k){ return k-(k%120); }
     var k5=Q['25.34'], k4=Q['24.35'], k9=Q['9.32'];
     out.push('at'+k5+','+k4);
     win('W2',st(k5),k5,60,['25.34']);
     win('W3',st(k4),k4,110,['24.35']);
     win('W1',Q['8.96']+1,k9,150,['9.32']);
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
