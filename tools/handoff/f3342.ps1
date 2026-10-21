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

if ($s.Contains("  {v:'33.42',what:")) { throw "check 33.42 is in the fixture already" }

SubRx @'
  {v:'33.41',what:
'@ @'
  {v:'33.42',what:'cw-nocachelbl, his order (2026-10-20) map on this second preraid screen should not have caches labelled: the raid start map draws no cache, looted or strongbox word, keeps the extract words, and the m key map still has them',
   run:function(){
     var bad=[], g, proto, oFt, rec, cs=[], sb=null, i, c, keep=[], mf0;
     function grab(){
       var t=[];
       rec=t; proto.fillText=function(){ t.push(String(arguments[0])); return oFt.apply(this,arguments); };
       try{ drawMapOverlay(); } finally { proto.fillText=oFt; }
       return t;
     }
     function cnt(t,rx){ var n=0; for(var k=0;k<t.length;k++) if(rx.test(t[k])) n++; return n; }
     __runPrep(); __topClear();
     try{
       __startRaid({mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       proto=CanvasRenderingContext2D.prototype; oFt=proto.fillText;
       for(i=0;i<g.containers.length&&(cs.length<2||!sb);i++){
         c=g.containers[i]; if(c.opened||c.strong) continue;
         if(cs.length<2){ keep.push([c,c.cache]); c.cache=1; cs.push(c); }
         else if(!sb){ keep.push([c,c.cache,c.strong]); c.strong=1; sb=c; }
       }
       if(cs.length<2||!sb) return 'SKIP: too few closed containers';
       mf0=g.mapFirst; g.mapOpen=true;
       g.mapFirst=0; var open=grab();
       if(cnt(open,/^(cache|strongbox)$/i)<3) bad.push('CONTROL: the m key map drew only '+cnt(open,/^(cache|strongbox)$/i)+' cache and strongbox words, so the arm cannot see the difference');
       g.mapFirst=1; var first=grab();
       if(cnt(first,/^(cache|looted|strongbox)$/i)) bad.push('the raid start map still draws '+cnt(first,/^(cache|looted|strongbox)$/i)+' cache, looted or strongbox words');
       if(cnt(first,/extract/i)<1) bad.push('the raid start map lost its extract words');
       if(first.length<8) bad.push('the raid start map drew only '+first.length+' texts');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       try{ keep.forEach(function(k){ k[0].cache=k[1]; if(k.length>2) k[0].strong=k[2]; }); }catch(_k){}
       try{ if(g){ g.mapFirst=0; g.mapOpen=false; } }catch(_m){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
