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

# A HEARTBEAT YOU CAN HEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  } else if(type==='heart'){
    var ob=a.createOscillator(),gb=a.createGain();
    ob.type='sine'; ob.frequency.setValueAtTime(62,t); ob.frequency.exponentialRampToValueAtTime(38,t+.14);
    gb.gain.setValueAtTime(.001,t); gb.gain.linearRampToValueAtTime(.11*vol,t+.02);
    gb.gain.exponentialRampToValueAtTime(.001,t+.20);
    ob.connect(gb); gb.connect(OUT); ob.start(t); ob.stop(t+.22);

'@ @'
  } else if(type==='heart'){
    // v23.xx, HIS ANSWERS (2026-10-12), answer 35: "low-health heartbeat". THE HEARTBEAT IS HEARD ON A LAPTOP. It was one 62 to 38 Hz
    // sine thump, below what laptop and TV speakers can play (his answer 41: the floor is a five year old laptop), so on most machines
    // low health was silent. It is now a lub-dub, two beats 0.15 s apart (the second softer), each the old sub thump plus a short
    // 140 to 75 Hz knock through a lowpass that small speakers do play. The knock grows with how bad it is (the 4th argument, 0 to 1,
    // the same danger figure that sets the rate). When it plays and how fast are unchanged.
    var hbk=arguments[3], hbi, hbt, hba, ob, gb, hko, hkf, hkg;
    hbk=(typeof hbk==='number'&&isFinite(hbk))?clamp(hbk,0,1):0.5;
    for(hbi=0;hbi<2;hbi++){
      hbt=t+hbi*.15; hba=hbi?.68:1;
      ob=a.createOscillator(); gb=a.createGain();
      ob.type='sine'; ob.frequency.setValueAtTime(62,hbt); ob.frequency.exponentialRampToValueAtTime(38,hbt+.14);
      gb.gain.setValueAtTime(.001,hbt); gb.gain.linearRampToValueAtTime(.11*vol*hba,hbt+.02);
      gb.gain.exponentialRampToValueAtTime(.001,hbt+.20);
      ob.connect(gb); gb.connect(OUT); ob.start(hbt); ob.stop(hbt+.22);
      hko=a.createOscillator(); hkf=a.createBiquadFilter(); hkg=a.createGain();
      hko.type='triangle'; hko.frequency.setValueAtTime(140,hbt); hko.frequency.exponentialRampToValueAtTime(75,hbt+.09);
      hkf.type='lowpass'; hkf.frequency.value=420; hkf.Q.value=0.8;
      hkg.gain.setValueAtTime(.0001,hbt); hkg.gain.linearRampToValueAtTime(.06*vol*hba*(0.6+0.4*hbk),hbt+.012);
      hkg.gain.exponentialRampToValueAtTime(.001,hbt+.12);
      hko.connect(hkf); hkf.connect(hkg); hkg.connect(OUT); hko.start(hbt); hko.stop(hbt+.13);
    }

'@

SubRx @'
        blip('heart',0);

'@ @'
        blip('heart',0,undefined,frac);   // v23.xx (his answer 35): the knock grows as it gets worse

'@

SubRx @'
var VER='24.59';
'@ @'
var VER='24.60';
'@

$pat = "(?m)^  now:'v24\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.60: The low health heartbeat is now a lub-dub you can hear on laptop speakers. Check 24.60 fails on v24.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
