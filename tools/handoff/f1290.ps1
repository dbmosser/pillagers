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

# v12.90 CHECK, inserted before the v12.89 entry.
#
# EVERY NEEDLE IS ASSEMBLED, because this row would otherwise be found by its own
# search the way three checks were in two builds.
#
# IT TESTS ALL FOUR SURFACES, not the constant: the buttons the card draws, the
# Undercroft run row, the FEELING TAGS aggregate, and the per-run line in the
# report he is sent. And it requires the STORED value to be left alone, because
# the whole point of a display-time map is that nothing he has already exported
# is rewritten under him.
#
# THE CONTROL IS A TAG THAT WAS NEVER RENAMED. A map that swallowed or blanked
# everything it did not know would pass every arm above.
SubRx @'
  {v:'12.89',what:'in a raid ESC closes what is in front
'@ @'
  {v:'12.90',what:'the feeling tag for the tactical belt calls it the tactical belt, on the card and in the report he is sent, and a run logged before the rename shows the new name on all three surfaces without the stored value being rewritten (audit finding 4, 2026-09-11)',
   run:function(){
     if(typeof TAGS!=='object'||!TAGS.length) return 'SKIP: this fixture has no feeling tags to read';
     if(typeof buildExport!=='function'||typeof fmtRun!=='function') return 'SKIP: this fixture cannot build a run report';
     if(!window.__P) return 'SKIP: this fixture cannot read the profile';
     var bad=[], P2=__P(), keepLog=(P2.log||[]).slice();
     var OLD='Hot'+'bar worked well', NEW='Tactical belt'+' worked well';
     try{
       // THE BUTTON FACES. TAGS is the button face itself: buildTags writes each
       // string straight into the element text.
       var joined=TAGS.join(' | ');
       if(joined.indexOf(OLD)>=0)
         bad.push('the feeling tag he taps still names the retired word, and that string is stored on the run and written into the report he is sent, so the word he retired reaches him in the file a friend copies out');
       if(joined.indexOf(NEW)<0)
         bad.push('control: there is no tactical belt tag at all now, so the button was deleted rather than renamed and he has lost the one way to tell Daniel the belt worked');
       // A RUN LOGGED BEFORE THE RENAME. It holds the old literal, and all three
       // surfaces that show a stored tag have to carry it forward.
       P2.log=[{n:1,outcome:'extract',ver:'1.00',preset:'std',weapon:'Fists',dur:30,haul:100,
                kills:{sentry:0,crawler:0,raider:0,snitch:0},tags:[OLD],note:''}];
       // fmtRun builds the row as an ELEMENT, so the text is read off it rather
       // than treated as a string.
       var row=''; try{ var _el=fmtRun(P2.log[0]); row=(_el&&(_el.textContent||_el.innerText))||''; }
       catch(_r){ bad.push('the run row threw on a run logged before the rename: '+(_r&&_r.message||_r)); }
       if(row&&row.indexOf(OLD)>=0)
         bad.push('the Undercroft run row still prints the retired word for a run he logged before the rename');
       if(row&&row.indexOf(NEW)<0)
         bad.push('the Undercroft run row shows neither name for a run logged before the rename, so the tag has vanished off the row rather than being carried forward');
       var rep=''; try{ rep=buildExport()||''; }catch(_x){ bad.push('the report threw on a run logged before the rename: '+(_x&&_x.message||_x)); }
       if(rep&&rep.indexOf(OLD)>=0)
         bad.push('the report he is sent still prints the retired word for a run logged before the rename, in the tag summary or under the run itself');
       if(rep&&rep.indexOf(NEW)<0)
         bad.push('the report shows neither name for a run logged before the rename, so the tag was dropped from the file rather than carried forward');
       // NOTHING STORED IS REWRITTEN. That is the reason for doing this at display
       // time, so an export he already has still reads the same way.
       if(!(P2.log[0].tags&&P2.log[0].tags[0]===OLD))
         bad.push('showing the run rewrote what is stored on it, so a display-time map has quietly become a migration with no stamp on it');
       // CONTROL: A TAG THAT WAS NEVER RENAMED MUST PASS THROUGH UNTOUCHED.
       var plain=null,i;
       for(i=0;i<TAGS.length;i++) if(TAGS[i]!==NEW){ plain=TAGS[i]; break; }
       if(plain){
         P2.log=[{n:1,outcome:'extract',ver:'1.00',preset:'std',weapon:'Fists',dur:30,haul:100,
                  kills:{sentry:0,crawler:0,raider:0,snitch:0},tags:[plain],note:''}];
         var rep2=''; try{ rep2=buildExport()||''; }catch(_y){}
         if(rep2&&rep2.indexOf(plain)<0)
           bad.push('control: the tag ['+plain+'], which was never renamed, no longer reaches the report, so the map is swallowing everything it does not recognise');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.log=keepLog; saveProfile(); }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.89',what:'in a raid ESC closes what is in front
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
