$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\handoff\dry\mk.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.64 CHECK, inserted before the v11.63 entry.
SubRx @'
  {v:'11.63',what:'a click on the [+] glyph of a collapsed CURRENT PILLAGERS board expands the board and starts no resize',
'@ @'
  {v:'11.64',what:'a note typed in the pause box on the floor is banked to the profile when the box closes, cleared from the box, and printed in the run report under FLOOR NOTES',
   run:function(){
     if(!window.__P||typeof togglePauseBox!=='function'||typeof buildExport!=='function') return 'SKIP: no pause box in this build';
     if(!document.getElementById('pausenote')) return 'SKIP: no note box in this document';
     var bad=[], prof, note='ZQX floor note 8812';
     try{
       __topClear(); __cleanProfile(); prof=__P();
       if(window.__hubEnter){ try{ __hubEnter(); }catch(_h){} }
       if(G) return 'SKIP: a raid is running, so this is not the floor';
       if(typeof state!=='undefined'&&state!=='hub') return 'SKIP: not on the floor (state '+state+'), so the box cannot open';
       delete prof.floorNotes;
       togglePauseBox(true);
       var ta=document.getElementById('pausenote'); ta.value=note;
       togglePauseBox(false);
       var fl=prof.floorNotes||[], last=fl[fl.length-1];
       if(!last||last.txt!==note) bad.push('the note typed on the floor was not banked (floorNotes: '+JSON.stringify(fl).slice(0,80)+')');
       if((ta.value||'').trim()===note) bad.push('the note is still sitting in the box, waiting to ride into the next raid');
       var rep=buildExport(), txt=(rep&&rep.join)?rep.join('\n'):String(rep);
       if(txt.indexOf(note)<0) bad.push('the run report does not carry the floor note');
       else if(txt.indexOf('FLOOR NOTES')<0) bad.push('the report carries the note but does not say what it is');
       // CONTROL: a second close with an empty box banks nothing more.
       togglePauseBox(true); togglePauseBox(false);
       if((prof.floorNotes||[]).length!==fl.length) bad.push('control: closing an empty box banked a note');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var ta2=document.getElementById('pausenote'); if(ta2) ta2.value=''; }catch(_t){}
       try{ togglePauseBox(false); }catch(_c){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.63',what:'a click on the [+] glyph of a collapsed CURRENT PILLAGERS board expands the board and starts no resize',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
