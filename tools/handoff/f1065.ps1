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
  {v:'10.64',what:'F strikes with a gun in hand, through the real key handler, and both controls lists name the key',
'@ @'
  {v:'10.65',what:'the end of raid card can copy the report: the button is there, it logs the raid it just played into the text, it cannot log it twice, and it leaves the card open',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__endRaid&&window.__P)) return 'SKIP: this build cannot end a raid';
     var P2=__P();
     var b=document.getElementById('oc_copy');
     if(!b) return 'the end of raid card has no Copy report button';
     var oc=document.getElementById('outcome');
     var ta=document.getElementById('exporttext');
     if(!ta) return 'SKIP: this build has no recorder box to fill';
     var keepLog=(P2.log||[]).slice(), keepRuns=P2.runs, keepAuto=P2.autoExport;
     try{
       P2.autoExport=false;   // no file saves from a check
       __startRaid({seed:4242,mapIx:0});
       __endRaid('extract');
       if(!oc.classList.contains('on')) return 'SKIP: the outcome card did not open';
       var note=document.getElementById('oc_note');
       if(note) note.value='probe note 4242';
       // The raid is already written to the log when the card opens (v8.17 banks
       // it before the card is drawn), and the card patches the tags and the note
       // onto that same row. So what matters here is that the copy carries them,
       // and that leaving afterwards does not write a second row.
       var before=(P2.log||[]).length;
       ta.value='';
       b.onclick();
       var afterCopy=(P2.log||[]).length;
       if(afterCopy!==before) bad.push('Copy report wrote another row for a raid already logged (the log went from '+before+' to '+afterCopy+')');
       var lastRow=(P2.log||[])[(P2.log||[]).length-1]||{};
       if(lastRow.note!=='probe note 4242') bad.push('the note typed on the card did not reach the logged raid (it holds '+JSON.stringify(lastRow.note)+')');
       // 2. The text it handed over holds that raid, and the note typed on the card.
       var txt=ta.value||'';
       if(!txt.length) bad.push('Copy report handed over nothing');
       else {
         if(txt.indexOf('FLIGHT RECORDER')<0) bad.push('what it handed over is not the run report');
         if(note&&txt.indexOf('probe note 4242')<0) bad.push('the note typed on the card is not in the report it handed over');
         if(txt.indexOf('EXTRACT')<0) bad.push('the raid it just played is not in the report it handed over');
       }
       // 3. The card is still open, so he can still read it and still leave.
       if(!oc.classList.contains('on')) bad.push('Copy report closed the card');
       // 4. Leaving afterwards cannot log the same raid a second time.
       var ocb=document.getElementById('oc_btn');
       if(ocb) ocb.onclick();
       var afterLeave=(P2.log||[]).length;
       if(afterLeave!==afterCopy) bad.push('leaving after a copy logged the raid again (the log went from '+afterCopy+' to '+afterLeave+')');
     } finally {
       P2.log=keepLog; P2.runs=keepRuns; P2.autoExport=keepAuto;
       try{ saveProfile(); }catch(_sv){}
       var o2=document.getElementById('outcome'); if(o2) o2.classList.remove('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.64',what:'F strikes with a gun in hand, through the real key handler, and both controls lists name the key',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
