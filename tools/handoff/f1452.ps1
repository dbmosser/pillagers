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
  {v:'14.51',what:
'@ @'
  {v:'14.52',what:'a report corrected after Copy report is saved again: with no drop address and this run already saved, sending the report again saves the file instead of marking it not saved, as two waiting runs always did (report audit finding 3)',
   run:function(){
     if(typeof autoExport!=='function'||typeof telemetryDest!=='function'||typeof downloadExport!=='function') return 'SKIP: no report save path in this build';
     if(typeof savedAtRun==='undefined'||typeof droppedThisSession==='undefined') return 'SKIP: the save counters are not reachable here';
     var bad=[], saves=0, _td=telemetryDest, _dl=downloadExport, _sp=saveProfile;
     var keep={at:savedAtRun,dropped:droppedThisSession,ae:P.autoExport,ad:P.autoDownload,lr:P.lastReport,runs:P.runs};
     try{
       telemetryDest=function(){ return null; };
       downloadExport=function(){ saves++; };
       saveProfile=function(){};
       P.autoExport=true; P.autoDownload=false; droppedThisSession=true; P.runs=5;
       // CONTROL: with two runs waiting since the last save, the report is saved.
       savedAtRun=P.runs-2; saves=0; autoExport();
       if(saves!==1) return 'SKIP: with two runs waiting the report was not saved ('+saves+'), so the save path did not run here';
       // THE FIX: this run already saved (Copy report), and the report goes out again with a note.
       savedAtRun=P.runs; saves=0; P.lastReport='zqx'; autoExport();
       if(saves!==1) bad.push('a report sent again for a run already saved was not saved ('+(P.lastReport==='no drop'?'marked not saved, 0 raids waiting':P.lastReport)+'), so the file on disk lacks the note');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       telemetryDest=_td; downloadExport=_dl; saveProfile=_sp;
       savedAtRun=keep.at; droppedThisSession=keep.dropped; P.autoExport=keep.ae; P.autoDownload=keep.ad; P.lastReport=keep.lr; P.runs=keep.runs;
       try{ syncAutoEx(); }catch(_s){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
