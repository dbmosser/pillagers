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

# MACHINES BEEP WHEN THEY LOCK ON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(e.state!=='chase'&&!G.sim&&(G.seenT||0)<=0){ G.seenT=5.0; sfx('seen',e.x,e.y); }
'@ @'
        if(e.state!=='chase'&&!G.sim&&(G.seenT||0)<=0){ G.seenT=5.0; sfx('seen',e.x,e.y); }
        // v23.xx, HIS ANSWERS (2026-10-12), answer 34 a: "machine beeps". A MACHINE BEEPS WHEN IT LOCKS ON. The stinger above plays
        // once in five seconds for the whole map, and only the sentry, the crawler and the Crier sound their alarm, so a Warden, a
        // Howler or a Bulwark turning on him made no sound of its own. Every machine (anything that is not a person) now gives a
        // short rising double beep where it stands the moment it acquires him: once per machine in three seconds, a quarter second
        // apart across the map, within 760. Sound only: nothing is drawn from a seeded stream.
        if(e.state!=='chase'&&!G.sim&&killWord(e)===' DESTROYED'&&!e.merc&&dist(e,p)<760&&!(typeof e.beepAt==='number'&&e.beepAt>(G.t||0)-3)&&!(typeof G.beepAt==='number'&&G.beepAt>(G.t||0)-0.25)){ e.beepAt=G.t||0; G.beepAt=G.t||0; sfx('lockon',e.x,e.y); }
'@

SubRx @'
seen:'mach',alarm:'mach',
'@ @'
seen:'mach',alarm:'mach',lockon:'mach',
'@

SubRx @'
  } else if(type==='clocktick'){

'@ @'
  } else if(type==='lockon'){
    // v23.xx (his answer 34 a): a machine locks on. Two short square pips through a band, the second higher (1.6 then 2.15 kHz),
    // a target-acquired chirp that reads as a machine and not as the clock or the menu.
    for(var lki=0;lki<2;lki++){
      var lkt=t+lki*.085, lko=a.createOscillator(), lkf=a.createBiquadFilter(), lkg=a.createGain();
      lko.type='square'; lko.frequency.setValueAtTime(lki?2150:1600,lkt);
      lkf.type='bandpass'; lkf.frequency.value=lki?2150:1600; lkf.Q.value=3;
      lkg.gain.setValueAtTime(.0001,lkt); lkg.gain.linearRampToValueAtTime(.05*vol,lkt+.006);
      lkg.gain.setValueAtTime(.05*vol,lkt+.05); lkg.gain.exponentialRampToValueAtTime(.001,lkt+.07);
      lko.connect(lkf); lkf.connect(lkg); lkg.connect(OUT); lko.start(lkt); lko.stop(lkt+.08);
    }
  } else if(type==='clocktick'){

'@

SubRx @'
var VER='24.58';
'@ @'
var VER='24.59';
'@

$pat = "(?m)^  now:'v24\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.59: Every machine gives a short double beep where it stands when it locks on to you. Check 24.59 fails on v24.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
