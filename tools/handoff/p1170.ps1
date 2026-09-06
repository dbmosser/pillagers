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

# FEEDBACK TYPED IN THE PAUSE BOX ON THE FLOOR WAS KEPT SILENTLY AND ATTACHED
# TO THE NEXT RAID. The box opens on the floor since v8.70, with the same note
# field, and the buttons that read the field attach a note only when a raid is
# running. On the floor nothing read it and nothing cleared it (only the way
# to the character screen did), so the words sat in the box and rode into the
# next raid's first pause as if written there, stamped with that raid's clock.
# The close banks a floor note to the profile now, says so, and every report
# prints them under FLOOR NOTES.
SubRx @'
  pauseOpen=on;
  // v10.96: every opening starts unarmed.
'@ @'
  pauseOpen=on;
  // v11.70: a note typed on the floor has no raid to attach to. It used to sit
  // in the box and ride into the NEXT raid's first pause as if written there.
  // The close banks it to the profile; every report prints it under FLOOR NOTES.
  if(!on&&!G){
    var _fn=document.getElementById('pausenote'), _ft=_fn?_fn.value.trim():'';
    if(_ft){
      P.floorNotes=P.floorNotes||[];
      P.floorNotes.push({run:P.runs||0,t:Date.now(),txt:_ft.slice(0,400)});
      if(P.floorNotes.length>20) P.floorNotes.shift();
      _fn.value='';
      saveProfile();
      try{ say2('Noted. It goes out with your next run report.'); }catch(_sn){}
    }
  }
  // v10.96: every opening starts unarmed.
'@
SubRx @'
  var _pn=document.getElementById('pausenote');
  if(_pn) _pn.value='';               // a note on the floor has no raid to attach to
  try{ saveProfile(); }catch(_sp){}
  togglePauseBox(false);
'@ @'
  // v11.70: a note typed here is banked by the close below, not thrown away.
  try{ saveProfile(); }catch(_sp){}
  togglePauseBox(false);
'@
SubRx @'
  }catch(_te){}
  L.push('Active config ['+(CFG.preset||'custom')+']: '+JSON.stringify(CFG));
'@ @'
  }catch(_te){}
  // v11.70: notes typed in the pause box on the floor, with no raid to carry them.
  if(P.floorNotes&&P.floorNotes.length){
    L.push('FLOOR NOTES ('+P.floorNotes.length+'):');
    P.floorNotes.forEach(function(fn){
      var when=''; try{ when=new Date(fn.t).toISOString(); }catch(_w){}
      L.push('  after run #'+fn.run+' '+when+': '+fn.txt);
    });
  }
  L.push('Active config ['+(CFG.preset||'custom')+']: '+JSON.stringify(CFG));
'@

# STAMPS.
SubRx @'
var VER='11.69';
'@ @'
var VER='11.70';
'@
SubRx @'
var WHATSNEW_VER='11.69';
'@ @'
var WHATSNEW_VER='11.70';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A NOTE TYPED IN THE PAUSE BOX IN THE UNDERCROFT IS KEPT AND SENT. It used to sit in the box and get pinned to your next raid as if you wrote it there. Now it is banked when the box closes, the game says so, and it goes out at the top of your next run report.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.69:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.69 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.69:[^']*'",{ param($m) "now:'v11.70: feedback typed in the pause box on the floor was kept silently and attached to the next raid. The buttons attach a note only when a raid runs and nothing on the floor read or cleared the field, so the words rode into the next raid first pause stamped with its clock. The close banks a floor note to P.floorNotes (20 kept), says so, and buildExport prints them under FLOOR NOTES; the character-screen button no longer discards it. From the v11.46 audit, P2.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
