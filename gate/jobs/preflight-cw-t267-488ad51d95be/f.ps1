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
  {v:'37.42',what:'job 267 slice probe two: 11.27 through 10.64 in list order in one page; never shipped',
   run:function(){
     if(typeof GATE_PROBE==='undefined') return 'no mark: this is the build before';
     var call=window.__t267=(window.__t267|0)+1; if(call>1) return 'second call: nothing run';
     var L=__REGRESS, i, seen={}, red=[], ran=0, t0=performance.now();
     function ix(v){ for(var q=0;q<L.length;q++) if(L[q].v===v) return q; return -1; }
     var a=ix('11.27'), b=ix('10.64');
     for(i=a;i<=b;i++){
       if(performance.now()-t0>140000) break;
       var t=L[i], r; if(String(t.what).indexOf('job 267')===0) continue;
       try{ __topClear(); __ctxHeal(); r=t.run(); }catch(e){ r='threw '+e; } ran++;
       if(t.v==='11.27'||t.v==='10.64') seen[t.v]=r?String(r).slice(0,60):'ok';
       else if(r&&String(r).indexOf('SKIP: ')!==0) red.push(t.v);
     }
     var md=[].map.call(document.querySelectorAll('.modal.on'),function(x){ return x.id; }).join(',');
     try{ __topClear(); }catch(_t){}
     return 'ran '+a+'-'+(i-1)+' of '+a+'-'+b+' n'+ran+' '+Math.round((performance.now()-t0)/1000)+'s km'+JSON.stringify(P.keymap||{})+' md['+md+'] 11.27:'+(seen['11.27']||'not reached')+' 10.64:'+(seen['10.64']||'not reached')+' red '+red.slice(0,14).join(',');
   }},
  {v:'37.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
