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

if ($s.Contains("  {v:'37.43',what:")) { throw "check 37.43 is in the fixture already" }

SubRx @'
  {v:'37.42',what:
'@ @'
  {v:'37.43',what:'PROBE ONLY (never shipped, job 266): slice zero up to 9.32 in its own tab, and 9.07 alone, on the fixture fix',
   run:function(){
     if(window.__p266!==undefined){ var tail=window.__p266; window.__p266=undefined; return tail||'-'; }
     var out=[], t00=performance.now(), Q={}, i, me=this.v;
     for(i=0;i<__REGRESS.length;i++) Q[__REGRESS[i].v]=i;
     function el(){ return (performance.now()-t00)/1000; }
     function life(){ return (P&&P.pil)?'L':'D'; }
     function mods(){ return [].map.call(document.querySelectorAll('.modal.on'),function(m){ return m.id.replace('modal',''); }).join('+')||'none'; }
     function sh(r){ return r?String(r).slice(0,9):'ok'; }
     function bare(v){ var t=__REGRESS[Q[v]], r; if(!t) return 'nochk'; __topClear(); __ctxHeal(); try{ r=t.run(); }catch(e){ r='threw '+e; } return sh(r); }
     function bare(v){ var t=__REGRESS[Q[v]], r; if(!t) return 'nochk'; __topClear(); __ctxHeal(); try{ r=t.run(); }catch(e){ r='threw '+e; } return r?String(r).slice(0,70):'ok'; }
     var j,t,r,t1,ran=0,skip=0,fails=[],six=[],rest=0,hv=[],T=['8.84','8.95','8.96','9.32'],k9=Q['9.32'];
     __runPrep();
     for(j=0;j<=k9;j++){ t=__REGRESS[j]; if(!t||t.v===me) continue;
       var isT=T.indexOf(t.v)>=0;
       if(t.v==='8.82'||(!isT&&el()>135)){ skip++; continue; }
       __topClear(); __ctxHeal(); rest+=__pilLive(); t1=performance.now();
       try{ r=t.run(); }catch(e){ r='threw '+e; }
       ran++; t1=(performance.now()-t1)/1000; if(t1>8) hv.push(t.v+'='+Math.round(t1)+'s');
       if(isT) six.push(t.v+'='+sh(r));
       else if(r&&String(r).indexOf('SKIP: ')!==0) fails.push(t.v+'='+String(r).slice(0,70));
     }
     out.push('W ran'+ran+' skip'+skip+' rest'+rest+' '+six.join(' ')+' red:'+(fails.slice(0,5).join(',')||'none')+' slow:'+hv.slice(0,5).join(','));
     __runPrep(); out.push('alone907='+bare('9.07')+life());
     bare('8.64'); out.push('dead907='+life()+bare('9.07'));
     var s='PROBE '+out.join(' ')+' '+Math.round(el())+'s';
     window.__p266=s.slice(300,600);
     return s.slice(0,300);
   }},
  {v:'37.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
