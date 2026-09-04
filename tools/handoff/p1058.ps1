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

# ============ HIS NOTES, 2026-09-03 about 21:25 and 21:27: "trailing noise is
# ============ way overdone" and "trailing noises need to be much shorter, i can
# ============ hear them wayy later". v10.56 gave the big guns a tail, the room
# ============ answering, at 0.35 of the crack and 1.6 times its length, and put
# ============ the action clicks up to 0.42 s after the shot. Everything a shot
# ============ schedules now lands inside 0.30 s: the big cracks are shorter,
# ============ the tail is shorter than the crack and a tenth of its level, the
# ============ bolt clicks at 0.16 s and the pump at 0.16 and 0.26.

# 1. The big cracks, shorter.
SubRx @'
      dmr:    {len:5200,lp:1400,hp:120,g:.20,decay:2.4,body:{f0:120,f1:45,d:.12,g:.14,type:'sine'},bolt:1},
      magnum: {len:4800,lp:1100,hp:80,g:.24,decay:2.0,body:{f0:95,f1:38,d:.16,g:.20,type:'sine'},tail:1},
      sniper: {len:7600,lp:1000,hp:60,g:.26,decay:1.8,body:{f0:80,f1:32,d:.22,g:.22,type:'sine'},tail:1,bolt:1},
'@ @'
      dmr:    {len:4200,lp:1400,hp:120,g:.20,decay:2.6,body:{f0:120,f1:45,d:.10,g:.14,type:'sine'},bolt:1},
      magnum: {len:3800,lp:1100,hp:80,g:.24,decay:2.4,body:{f0:95,f1:38,d:.12,g:.20,type:'sine'},tail:1},
      sniper: {len:5600,lp:1000,hp:60,g:.26,decay:2.2,body:{f0:80,f1:32,d:.14,g:.22,type:'sine'},tail:1,bolt:1},
'@
SubRx @'
      lance:  {len:6400,lp:1200,hp:60,g:.24,decay:2.0,body:{f0:90,f1:34,d:.20,g:.20,type:'sine'},tail:1}
'@ @'
      lance:  {len:5000,lp:1200,hp:60,g:.24,decay:2.2,body:{f0:90,f1:34,d:.14,g:.20,type:'sine'},tail:1}
'@

# 2. The tail: shorter than the crack, a tenth of its level.
SubRx @'
      // the room answering a big gun: a longer, darker wash under the crack
      var tl=Math.round(V.len*1.6),tb=a.createBuffer(1,tl,a.sampleRate),tc=tb.getChannelData(0);
      for(var ti=0;ti<tl;ti++) tc[ti]=(Math.random()*2-1)*Math.pow(1-ti/tl,1.4);
      var ts=a.createBufferSource(); ts.buffer=tb;
      var tf=a.createBiquadFilter(); tf.type='lowpass'; tf.frequency.value=420*J;
      var tgn=a.createGain(); tgn.gain.value=V.g*vol*.35;
'@ @'
      // the room answering a big gun: a darker wash under the crack. v10.58,
      // his notes: shorter than the crack and a tenth of its level; at 1.6 times
      // the crack and 0.35 he could hear it "wayy later".
      var tl=Math.round(V.len*0.9),tb=a.createBuffer(1,tl,a.sampleRate),tc=tb.getChannelData(0);
      for(var ti=0;ti<tl;ti++) tc[ti]=(Math.random()*2-1)*Math.pow(1-ti/tl,2.2);
      var ts=a.createBufferSource(); ts.buffer=tb;
      var tf=a.createBiquadFilter(); tf.type='lowpass'; tf.frequency.value=320*J;
      var tgn=a.createGain(); tgn.gain.value=V.g*vol*.10;
'@

# 3. The action, sooner.
SubRx @'
      var ck=V.pump?[.28,.42]:[.25],cfq=V.pump?1400:2400;
'@ @'
      var ck=V.pump?[.16,.26]:[.16],cfq=V.pump?1400:2400;   // v10.58: inside 0.30 s of the shot
'@

SubRx @'
var VER='10.57';
'@ @'
var VER='10.58';
'@
SubRx @'
  now:'v10.57: footsteps. Heel then sole, left and right in the ear, the ground under you adds its own tell (grit, a creaking board, ringing plate, a rustle, a splash and a drip), a sprint lands harder and a crouch softer, and the machines and the pillagers now walk on the same five surfaces you do.',
'@ @'
  now:'v10.58: the trailing noise after a big gun is much shorter and a tenth as loud, the big cracks themselves are shorter, and the bolt and pump click inside a third of a second of the shot. Nothing a shot makes lands later than that.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
