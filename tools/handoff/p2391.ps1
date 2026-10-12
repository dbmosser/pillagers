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

# HIT MARKERS AND KILLS ARE HEARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  heart:'vox',flap:'amb'};
'@ @'
  heart:'vox',flap:'amb',hitmark:'ui',killconf:'ui'};
'@

SubRx @'
  } else if(type==='pick'){
'@ @'
  } else if(type==='hitmark'||type==='killconf'){
    // v23.91, HIS ORDER 2026-10-12 (his #45, punchy arcade sound like CoD and Fortnite): THE HIT MARKER IS HEARD. A round of yours
    // that landed drew the X at the reticle in silence, and the hit sound itself plays out at the target, often far and muffled,
    // so in a fight you could not tell by ear whether you were landing. Now a landed round gives a crisp tick in your own ears (a
    // weak spot a higher one) and a kill gives the tick, a low thunk and a two note ding. On the HUD bus, so never compressed,
    // ducked or muffled. Played once per marker by the frame tick that ages it.
    var hkW=arguments[3]==='weak', hkb=a.createBuffer(1,90,a.sampleRate), hkc=hkb.getChannelData(0);
    for(var hki=0;hki<90;hki++) hkc[hki]=(Math.random()*2-1)*Math.pow(1-hki/90,2);
    var hks=a.createBufferSource(); hks.buffer=hkb;
    var hkf=a.createBiquadFilter(); hkf.type='highpass'; hkf.frequency.value=3000;
    var hkg=a.createGain(); hkg.gain.value=.05;
    hks.connect(hkf); hkf.connect(hkg); hkg.connect(OUT); hks.start(t);
    var hko=a.createOscillator(),hkog=a.createGain();
    hko.type='triangle'; hko.frequency.setValueAtTime(hkW?3200:2400,t); hko.frequency.exponentialRampToValueAtTime(hkW?2600:1900,t+.03);
    hkog.gain.setValueAtTime(.045,t); hkog.gain.exponentialRampToValueAtTime(.0005,t+.045);
    hko.connect(hkog); hkog.connect(OUT); hko.start(t); hko.stop(t+.05);
    if(type==='killconf'){
      var kco=a.createOscillator(),kcg=a.createGain();
      kco.type='sine'; kco.frequency.setValueAtTime(180,t); kco.frequency.exponentialRampToValueAtTime(85,t+.1);
      kcg.gain.setValueAtTime(.09,t); kcg.gain.exponentialRampToValueAtTime(.0005,t+.12);
      kco.connect(kcg); kcg.connect(OUT); kco.start(t); kco.stop(t+.13);
      var kdo=a.createOscillator(),kdg=a.createGain();
      kdo.type='triangle'; kdo.frequency.setValueAtTime(1320,t+.04); kdo.frequency.setValueAtTime(1760,t+.09);
      kdg.gain.setValueAtTime(.0001,t); kdg.gain.setValueAtTime(.04,t+.04); kdg.gain.exponentialRampToValueAtTime(.0005,t+.26);
      kdo.connect(kdg); kdg.connect(OUT); kdo.start(t+.04); kdo.stop(t+.27);
    }
  } else if(type==='pick'){
'@

SubRx @'
      if(G.hitMark){ G.hitMark.t+=dt; if(G.hitMark.t>G.hitMark.life) G.hitMark=null; }
'@ @'
      if(G.hitMark&&!G.hitMark.snd){ G.hitMark.snd=1; if(!G.sim) blip(G.hitMark.kill?'killconf':'hitmark',undefined,undefined,G.hitMark.weak?'weak':''); }   // v23.91 (his #45): the marker is heard once
      if(G.hitMark){ G.hitMark.t+=dt; if(G.hitMark.t>G.hitMark.life) G.hitMark=null; }
'@

SubRx @'
var VER='23.90';
'@ @'
var VER='23.91';
'@

$pat = "(?m)^  now:'v23\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.91: Landing a hit ticks in your ears and a kill rings, like CoD and Fortnite. Check 23.91 fails on v23.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
