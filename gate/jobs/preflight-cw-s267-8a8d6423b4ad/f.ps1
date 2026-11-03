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
  {v:'37.42',what:'job 267 slice probe: the melee checks after the earlier checks of their slice, in one page; never shipped',
   run:function(){
     if(typeof GATE_PROBE==='undefined') return 'no mark: this is the build before';
     var call=window.__s267=(window.__s267|0)+1, L=__REGRESS, i, MELEE={'11.38':1,'11.27':1,'10.64':1}, seen={};
     function ix(v){ for(var q=0;q<L.length;q++) if(L[q].v===v) return q; return -1; }
     function one(t){ var r; try{ __topClear(); __ctxHeal(); r=t.run(); }catch(e){ r='threw '+e; } return r; }
     var i38=ix('11.38'), i64=ix('10.64'), a=(call===1)?Math.floor(i38/120)*120:Math.max(0,i38-25), b=(call===1)?i38:i64+1, cap=(call===1)?55000:60000, t0=performance.now(), red=[], ran=0;
     for(i=a;i<b;i++){
       if(performance.now()-t0>cap) break;
       var t=L[i]; if(String(t.what).indexOf('job 267')===0) continue;
       var r=one(t); ran++;
       if(MELEE[t.v]) seen[t.v]=r?String(r).slice(0,40):'ok';
       else if(r&&String(r).indexOf('SKIP: ')!==0) red.push(t.v);
     }
     var stop=i;
     ['11.38','11.27','10.64'].forEach(function(v){ if(!seen[v]){ var r=one(L[ix(v)]); seen[v]=(r?String(r).slice(0,40):'ok')+((call===1)?'':'*'); } });
     var md=[].map.call(document.querySelectorAll('.modal.on'),function(x){ return x.id; }).join(',');
     try{ __topClear(); }catch(_t){}
     return (call===1?'A':'B')+' i38='+i38+' i64='+i64+' ran '+a+'-'+stop+' n'+ran+' '+Math.round((performance.now()-t0)/1000)+'s km'+JSON.stringify(P.keymap||{})+' md['+md+'] 11.38:'+seen['11.38']+' 11.27:'+seen['11.27']+' 10.64:'+seen['10.64']+' red '+red.slice(0,12).join(',');
   }},
  {v:'37.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
