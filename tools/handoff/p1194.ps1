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

# FIRST TEN MINUTES AUDIT, 2026-09-06: a note typed into the pause box during
# a raid and closed with ESC was thrown away. ESC is the way out the box's own
# legend names; the resume button banked the note and ESC did not. The alpha
# card asks him to leave notes; the channel dropped them.
SubRx @'
  if(!on&&!G){
    var _fn=document.getElementById('pausenote'), _ft=_fn?_fn.value.trim():'';
'@ @'
  // v11.94: A RAID NOTE SURVIVES ESC. The resume button banked the note and
  // ESC, the way out the box's own legend names, did not: it closed the box
  // with the text still sitting in it, unseen by the run report. Every close
  // of the box over a live raid banks it now, and the two copies of these
  // lines the resume and abandon buttons carried are gone: both close the box
  // before anything ends the raid, so this is the one place that banks.
  if(!on&&G&&!G.over){
    var _rn=document.getElementById('pausenote'), _rt=_rn?_rn.value.trim():'';
    if(_rt){ G.tel.notes.push({t:Math.round(elapsed()),txt:_rt}); _rn.value=''; }
  }
  if(!on&&!G){
    var _fn=document.getElementById('pausenote'), _ft=_fn?_fn.value.trim():'';
'@
SubRx @'
  disarmAbandon();   // v10.96: the same four lines this used to carry itself
  var note=document.getElementById('pausenote').value.trim();
  if(note&&G){ G.tel.notes.push({t:Math.round(elapsed()),txt:note}); document.getElementById('pausenote').value=''; }
  togglePauseBox(false);
};
'@ @'
  disarmAbandon();   // v10.96: the same four lines this used to carry itself
  togglePauseBox(false);   // v11.94: the close banks the note, for this button and for ESC alike
};
'@

SubRx @'
  var note=document.getElementById('pausenote').value.trim();
  if(note&&G){ G.tel.notes.push({t:Math.round(elapsed()),txt:note}); document.getElementById('pausenote').value=''; }
  togglePauseBox(false);
this.style.display='none';
'@ @'
  togglePauseBox(false);   // v11.94: the close banks the note
this.style.display='none';
'@

# STAMPS.
SubRx @'
var VER='11.93';
'@ @'
var VER='11.94';
'@
SubRx @'
var WHATSNEW_VER='11.93';
'@ @'
var WHATSNEW_VER='11.94';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A NOTE TYPED IN THE PAUSE BOX IS KEPT WHEN ESC CLOSES IT, the same as the resume button; it goes out with your run report.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.93:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.93 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.93:[^']*'",{ param($m) "now:'v11.94: from the 2026-09-06 first-ten-minutes audit, a note typed into the pause box during a raid and closed with ESC was thrown away; only the resume button banked it. Every close of the box over a live raid banks the note now, and the resume and abandon buttons lost their own copies of the lines. Check 11.94 pauses a raid, types a note, presses ESC on the box and requires the note in the run record; fails on v11.93.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
