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
  {v:'11.00',what:'he picks the weather on the way up
'@ @'
  {v:'11.01',what:'the end of raid buttons ask about this game, and a pressed one reaches the run report',
   run:function(){
     if(typeof TAGS==='undefined') return 'SKIP: this build has no feedback tags';
     if(!(window.__deploy&&window.__state)) return 'SKIP: this fixture cannot end a raid';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so no tag can be clicked';
     var bad=[], i, j;
     // 1. THE THREE A FRIEND CANNOT SAY ANY OTHER WAY. The alpha exists to find
     //    out what breaks on somebody else's machine, and a tag is the only
     //    feedback most people will ever give.
     var joined=TAGS.join(' | ').toLowerCase();
     var MUST=[['crash','a way to say it crashed'],
               ['looked wrong','a way to say something looked wrong'],
               ['sound','a way to say the sound was off'],
               ['read','a way to say text was hard to read']];
     for(i=0;i<MUST.length;i++)
       if(joined.indexOf(MUST[i][0])<0) bad.push('the end of raid buttons have no '+MUST[i][1]);
     // 2. AND THEY ARE ABOUT THIS GAME, not the questions of thirty builds ago.
     //    Eight of the old twenty-four asked about one machine each, from an era
     //    he has since answered with dozens of logged runs.
     var STALE=['listener beatable','listener unfair','pillbox worth it','pillbox a chore',
                'bulwark great','bulwark unfair','howler great','howler unfair'];
     var left=[];
     for(i=0;i<STALE.length;i++) if(joined.indexOf(STALE[i])>=0) left.push(STALE[i]);
     if(left.length>2) bad.push(left.length+' of the buttons are still the one-machine questions of v5.72: '+left.join(', '));
     // 3. NO DUPLICATES, and a sane number of them. A tag row he cannot scan is
     //    a tag row nobody presses.
     var seen={};
     for(i=0;i<TAGS.length;i++){
       var t=String(TAGS[i]);
       if(seen[t]) bad.push('the button '+t+' appears twice');
       seen[t]=1;
       if(t.length>34) bad.push('the button '+t+' is '+t.length+' characters and will not fit the row');
     }
     if(TAGS.length<12) bad.push('only '+TAGS.length+' buttons, which is not enough to cover a raid');
     if(TAGS.length>40) bad.push(TAGS.length+' buttons is more than anyone reads');
     // 4. AND PRESSING ONE REACHES THE REPORT. This is the whole point: a button
     //    that does not arrive is worse than no button. Driven through the real
     //    end of raid card and the real way out.
     if(!(window.__endRaid&&document.getElementById('tagwrap'))) return bad.length?bad.join('; '):null;
     __runPrep(); __resetCfg(); __pinDefaults(0);
     var prof=__P(), keepLog=(prof.log||[]).slice();
     try{
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0;
       __endRaid('extract');
       var w=document.getElementById('tagwrap');
       var cells=w?w.querySelectorAll('.tag'):[];
       if(!cells.length){ bad.push('the end of raid card drew no buttons at all'); }
       else {
         if(cells.length!==TAGS.length) bad.push('the card drew '+cells.length+' buttons for '+TAGS.length+' in the list');
         // press two, and press a third twice so the second press turns it off
         var want=[String(cells[0].textContent),String(cells[1].textContent)];
         cells[0].click(); cells[1].click();
         cells[2].click(); cells[2].click();
         var off=String(cells[2].textContent);
         var btn=document.getElementById('oc_btn');
         if(!btn) bad.push('control: there is no way out of the card, so nothing can be logged');
         else {
           btn.click();
           var log=prof.log||[], rec=log[log.length-1];
           if(!rec) bad.push('control: the run did not reach the log, so the tags cannot be checked');
           else {
             var got=(rec.tags||[]).map(function(x){ return String(x).toUpperCase(); }).join(' | ');
             for(j=0;j<want.length;j++)
               if(got.indexOf(want[j].toUpperCase())<0)
                 bad.push('the button '+want[j]+' was pressed and did not reach the run report, which reads '+(got||'nothing'));
             if(got.indexOf(off.toUpperCase())>=0)
               bad.push('control: '+off+' was pressed twice and still reached the report, so a button cannot be unpressed');
           }
         }
       }
     } finally {
       prof.log=keepLog;
       try{ __topClear(); }catch(_tc){}
       try{ saveProfile(); }catch(_sp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.00',what:'he picks the weather on the way up
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
