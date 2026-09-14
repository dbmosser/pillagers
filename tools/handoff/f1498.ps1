$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.97',what:
'@ @'
  {v:'14.98',what:'the rack line says what the wall pays: a rack built beside an Array names the pay of racks and Arrays together, which is what an extraction pays (copies audit finding 2)',
   run:function(){
     if(typeof buildRack!=='function'||typeof mfPayPer!=='function'||typeof RACK_COST==='undefined'||!window.__applyLoaded) return 'SKIP: no mainframe racks in this build';
     var bad=[], snap=null, _say=say, said='';
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.racks=0; q.arrays=1; q.kit=[]; q.stash=[];
       for(var k in RACK_COST) for(var j=0;j<RACK_COST[k];j++) q.stash.push(k);
       say=function(m){ said=String(m); };
       buildRack();
       say=_say;
       // CONTROL: the rack was built.
       if(__P().racks!==1) return 'SKIP: the rack was not built here ('+said.slice(0,80)+')';
       var want='$'+mfPayPer().toLocaleString();
       if(said.indexOf(want)<0) bad.push('with one Array the new rack says '+said.slice(0,90)+' where the wall pays '+want);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say=_say; try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
