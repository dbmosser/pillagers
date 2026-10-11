$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# KEYS FOLLOW THE DEVICE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      say('Knocked down. Extraction progress bar reset. Hold E to try again.','ext',{c:'warn',key:'xcall'});   // v16.17, his note: extraction hold meant nothing to him; v16.19: his words, Extraction progress bar reset
'@ @'
      // v22.63, the raid text rewrite (R20): KEYS FOLLOW THE DEVICE. His words stay word for word; only the E token is the key the
      // pull is on: the bound key on a keyboard (an unmoved keyboard reads exactly as before) and X on a controller.
      say('Knocked down. Extraction progress bar reset. Hold '+keyLabel('KeyE','E')+' to try again.','ext',{c:'warn',key:'xcall'});   // v16.17, his note: extraction hold meant nothing to him; v16.19: his words, Extraction progress bar reset
'@

SubRx @'
    if(!p.autoJog&&mg>0){ if(!G.sim) say('Stop first, then tap CAPS to auto-jog.'); }
    else { p.autoJog=!p.autoJog; if(!G.sim) say(p.autoJog?'Auto-jog on. Tap CAPS or move to stop.':'Auto-jog off.'); }
'@ @'
    // v22.63, the raid text rewrite (R20): HIS ORDER (2026-10-09), a raid line is a short caps headline with, only when needed, a
    // short detail. The auto-jog lines are STOP FIRST and AUTO-JOG ON or OFF, and the detail names the key auto-jog is bound to.
    if(!p.autoJog&&mg>0){ if(!G.sim) say('STOP FIRST','info',{sub:'Then tap ['+keyLabel('CapsLock','CAPS')+'] to auto-jog.'}); }
    else { p.autoJog=!p.autoJog; if(!G.sim){ if(p.autoJog) say('AUTO-JOG ON','sys',{sub:'Tap ['+keyLabel('CapsLock','CAPS')+'] or move to stop.'}); else say('AUTO-JOG OFF','sys'); } }
'@

SubRx @'
  if(p.autoJog&&mg>0){ p.autoJog=false; if(!G.sim) say('Auto-jog off.'); }
'@ @'
  if(p.autoJog&&mg>0){ p.autoJog=false; if(!G.sim) say('AUTO-JOG OFF','sys'); }   // v22.63 (R20): the caps headline
'@

SubRx @'
    if(p.autoJog){ p.autoJog=false; if(!G.sim) say('Auto-jog off.'); }
'@ @'
    if(p.autoJog){ p.autoJog=false; if(!G.sim) say('AUTO-JOG OFF','sys'); }   // v22.63 (R20): the caps headline
'@

SubRx @'
var VER='22.62';
'@ @'
var VER='22.63';
'@

$pat = "(?m)^  now:'v22\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.63: Knocked down mid-pull names the pull key of the device in hand, and the auto-jog lines are caps headlines. Check 22.63 fails on v22.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
