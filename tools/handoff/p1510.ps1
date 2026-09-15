$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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
    if(!G.sim){ dropDeadKeys(); saveProfile(); }
    G=null; keys={};
    showScreen('hub');
    return;
'@ @'
    // v15.10, quit audit finding 8: A NOTE TYPED IN THE PAUSE BOX SURVIVES AN INSTANT QUIT. The confirm closes the box first,
    // which banks the note into this raid's notes, and this branch then threw the raid away before P.runs++ and pendingRun,
    // the only readers of those notes: the note was in no run record, not under FLOOR NOTES and in no report, and nothing
    // said so. With no run to attach it to, it is kept as a floor note, in the shape and cap the floor close uses, so the
    // run still counts as never having happened.
    var _qNoted=!G.sim&&T.notes&&T.notes.length>0;
    if(_qNoted){
      P.floorNotes=P.floorNotes||[];
      for(var _qn=0;_qn<T.notes.length;_qn++) P.floorNotes.push({run:P.runs||0,t:Date.now(),txt:String(T.notes[_qn].txt).slice(0,400)});
      while(P.floorNotes.length>20) P.floorNotes.shift();
    }
    if(!G.sim){ dropDeadKeys(); saveProfile(); }
    G=null; keys={};
    showScreen('hub');
    // v15.10, quit audit finding 8: and the Undercroft says it was kept, with the floor close's own line.
    if(_qNoted){ try{ say2('Noted. It goes out with your next run report.'); }catch(_qsn){} }
    return;
'@
SubRx @'
var VER='15.09';
'@ @'
var VER='15.10';
'@

$pat = "(?m)^  now:'v15\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.10: A NOTE TYPED IN THE PAUSE BOX SURVIVES AN INSTANT QUIT. Abandoning a raid in its first moments, before moving, looting or firing, throws the run away as if it never happened, and a note typed in the pause box went with it, into no run record and no report, with no word said. The note is now kept with the floor notes, printed under FLOOR NOTES in the next report, and the Undercroft says Noted. Check 15.10 types a note in the box right after ascending, confirms the abandon and reads the floor notes; it fails on v15.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
