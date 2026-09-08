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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P2), specced from the source.
#
# ONE REPORT BECAME A BARRAGE. A Howler that hears a noise writes the bearing
# down, keeps it for eight seconds and mails a shell to it. The shell lands two
# seconds later and its own impact is a noise of 480, which every listening
# machine on the map hears, including the Howler that fired it: the bearing is
# overwritten with the crater and the eight seconds are wound back to full. Its
# cooldown then runs out with the clock still going, so it shells its own crater,
# and that impact winds it up again. The man made ONE sound and went quiet,
# which is the whole counterplay, and was shelled two to four more times at the
# spot he was heard.
#
# The shell now carries the machine that fired it, and that machine does not
# take its own crater for a fresh report. Everything else on the map still hears
# the impact exactly as before, which is what pulls the room to a burst, and the
# firing Howler still walks to it as it always did.
SubRx @'
          G.shells.push({mortar:1,x0:e.x,y0:e.y,
            tx:e.heardX+rnd(-_hs2,_hs2),ty:e.heardY+rnd(-_hs2,_hs2),
'@ @'
          G.shells.push({mortar:1,x0:e.x,y0:e.y,by:e,   // v12.51: whose shell this is
            tx:e.heardX+rnd(-_hs2,_hs2),ty:e.heardY+rnd(-_hs2,_hs2),
'@

SubRx @'
          G.shells.push({mortar:1,x0:e.x,y0:e.y,tx:_htx+rnd(-_hsc,_hsc),ty:_hty+rnd(-_hsc,_hsc),
'@ @'
          G.shells.push({mortar:1,x0:e.x,y0:e.y,by:e,tx:_htx+rnd(-_hsc,_hsc),ty:_hty+rnd(-_hsc,_hsc),   // v12.51: whose shell this is
'@

SubRx @'
  ping(SH.tx,SH.ty,480,false,false,'robot','fire');
'@ @'
  // v12.51, 2026-09-07 audit: A HOWLER DOES NOT TAKE ITS OWN CRATER FOR A FRESH
  // REPORT. This impact is a noise of 480 and every listening machine hears it,
  // which is right and is what pulls a room to a burst. The machine that FIRED
  // it heard it too: the bearing it was shooting at was overwritten with the
  // crater and its eight second clock wound back to full, so when its cooldown
  // ran out it shelled its own crater, and that impact wound it up again. One
  // report became a barrage of two to four, every shell after the first landing
  // on a man who had already gone quiet, which is the counterplay this machine
  // was built around. Only the three fields the hearing sweep writes are put
  // back, and only for the machine that fired: everything else on the map hears
  // this exactly as before, and the firing Howler is still turned toward the
  // crater by the same ping, which is what used to end the barrage on its own.
  var _shBy=SH.by, _shT=null, _shX=null, _shY=null;
  if(_shBy){ _shT=_shBy.hearT; _shX=_shBy.heardX; _shY=_shBy.heardY; }
  ping(SH.tx,SH.ty,480,false,false,'robot','fire');
  if(_shBy){ _shBy.hearT=_shT; _shBy.heardX=_shX; _shBy.heardY=_shY; }
'@

# NEW IN.
SubRx @'
  'BREAKING A CRIER LINE OF SIGHT NOW ACTUALLY CANCELS ITS ALARM. The cancel cleared the windup and then fired the alarm on the very same frame, so hiding never once called one off. The three seconds have to be unbroken now, which they always claimed to be.',
'@ @'
  'BREAKING A CRIER LINE OF SIGHT NOW ACTUALLY CANCELS ITS ALARM. The cancel cleared the windup and then fired the alarm on the very same frame, so hiding never once called one off. The three seconds have to be unbroken now, which they always claimed to be.',
  'A HOWLER NO LONGER SHELLS ITS OWN CRATER. It heard its own impact, took the crater for a fresh report, and mailed another shell to it, and that one wound it up again. One noise from you became a barrage of two to four after you had gone quiet.',
'@

# STAMPS.
SubRx @'
var VER='12.50';
'@ @'
var VER='12.51';
'@
SubRx @'
var WHATSNEW_VER='12.50';
'@ @'
var WHATSNEW_VER='12.51';
'@
$cnt=([regex]::Matches($s,"now:'v12\.50:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.50 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.50:[^']*'",{ param($m) "now:'v12.51: 2026-09-07 audit (P2). One report became a barrage. A Howler that hears a noise writes the bearing down, keeps it for eight seconds and mails a shell to it. The shell lands two seconds later and its own impact is a noise of 480 that every listening machine on the map hears, including the Howler that fired it: the bearing was overwritten with the crater and the eight seconds wound back to full, so when its cooldown ran out it shelled its own crater, and that impact wound it up again. The man made ONE sound and went quiet, which is the whole counterplay the Listener and the Howler are built around, and was shelled two to four more times at the spot he was heard. Each shell now carries the machine that fired it, and that machine does not take its own crater for a fresh report: only the three fields the hearing sweep writes are put back, and only for the shooter, so everything else on the map still hears the impact exactly as before and the firing Howler is still turned toward the crater by the same noise. Check 12.51 puts one Howler alone on an empty map four hundred units from a single staged noise, points it away so it cannot see him, and steps twenty seconds of raid with the man silent: after the first impact the eight second clock must have DECAYED rather than been wound back, the bearing must still be the noise and not the crater, and the shell count must be at most the two that the eight second bearing and the five to seven second cooldown honestly allow; fails on v12.50.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
