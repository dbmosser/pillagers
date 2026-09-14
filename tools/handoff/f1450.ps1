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
  {v:'14.49',what:
'@ @'
  {v:'14.50',what:'Clear recorder clears the crash list and the floor notes as well as the run log: two clicks leave no old crash and no old floor note for the next report (report audit finding 6)',
   run:function(){
     var b=document.getElementById('wipelog');
     if(!b||typeof b.onclick!=='function') return 'SKIP: no Clear recorder button in this document';
     var bad=[], _sp=saveProfile, keep={log:P.log,crashes:P.crashes,floorNotes:P.floorNotes,lastSim:P.lastSim};
     try{
       saveProfile=function(){};
       P.log=[{zqx:1}]; P.crashes=[{v:VER,t:Date.now(),kind:'error',msg:'zqx old fault',where:'',n:1}]; P.floorNotes=[{run:1,t:Date.now(),txt:'zqx old note'}];
       delete b.dataset.armed;
       b.onclick(); b.onclick();
       // CONTROL: the run log was cleared, so the confirmed click ran.
       if(P.log&&P.log.length) return 'SKIP: two clicks did not clear the run log here';
       if(P.crashes&&P.crashes.length) bad.push('Clear recorder left '+P.crashes.length+' old crash entry in the next report');
       if(P.floorNotes&&P.floorNotes.length) bad.push('Clear recorder left '+P.floorNotes.length+' old floor note in the next report');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       saveProfile=_sp; P.log=keep.log; P.crashes=keep.crashes; P.floorNotes=keep.floorNotes; P.lastSim=keep.lastSim;
       try{ delete b.dataset.armed; b.textContent='Clear recorder'; }catch(_b){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
