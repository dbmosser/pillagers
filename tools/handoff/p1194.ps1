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

# HIS FOUR WORDING NOTES, 2026-09-06 about 13:20 to 13:30, in chat:
#  1. '"Alarm went out. It..." It needs to say Crier or player wont know what
#     it is'. The Crier's alarm line names the Crier.
#  2. 'Listener has stopped listening -- why?' The line is the Pillbox's death
#     message and never said so. It says destroyed now.
#  3. '"One a raid" -> "One per raid"'. Both self-revive lines.
#  4. '"Resuming 6% done" -- wtf does this mean -- resuming what?' It is a
#     container search picked up where he left it. It says so now.
SubRx @'
say(sees?'Alarm went out. It kept eyes on you: they know exactly where you are.'
                 :'Alarm went out. They are coming to where it LAST saw you.');
'@ @'
say(sees?'The Crier raised the alarm. It kept eyes on you: they know exactly where you are.'   // v11.94, HIS NOTE: name the Crier
                 :'The Crier raised the alarm. They are coming to where it LAST saw you.');
'@
SubRx @'
        if(!G.sim) say(e.name+' has stopped listening.');
'@ @'
        if(!G.sim) say(e.name+' destroyed. It has stopped listening, and it dropped a cache.');   // v11.94, HIS NOTE: he could not tell this was a death
'@
SubRx @'
    G.tel.downs++; say('DOWN. F to get back up. You get one a raid.');
'@ @'
    G.tel.downs++; say('DOWN. F to get back up. You get one per raid.');   // v11.94, HIS NOTE: per raid
'@
SubRx @'
  if(p.revived) { say('Self-revive spent. One a raid.'); return false; }
'@ @'
  if(p.revived) { say('Self-revive spent. One per raid.'); return false; }   // v11.94, HIS NOTE: per raid
'@
SubRx @'
        if(!G.sim&&(near.prog||0)>0) say('Resuming, '+Math.round(100*near.prog/near.time)+'% done.');
'@ @'
        if(!G.sim&&(near.prog||0)>0) say('Search resumed, '+Math.round(100*near.prog/near.time)+'% done.');   // v11.94, HIS NOTE: resuming what
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
  'FOUR LINES SAY WHAT THEY MEAN: the Crier names itself when its alarm goes out, the Pillbox says destroyed when it dies, the self-revive is one per raid, and a search picked up again says Search resumed.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.93:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.93 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.93:[^']*'",{ param($m) "now:'v11.94: HIS FOUR WORDING NOTES of 2026-09-06: the Crier alarm line names the Crier (it said Alarm went out. It...), the Pillbox death line says destroyed (it said has stopped listening and he asked why), the self-revive says one per raid, and a container search picked up again says Search resumed instead of Resuming. Check 11.94 drives all four lines through the real code and reads them; fails on v11.93.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
