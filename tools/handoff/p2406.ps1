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

# MUSIC ON THE TITLE ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var MUS_THEMES=[HUB_THEME,THEME_TIN,THEME_DEEP,THEME_LAMPS,THEME_WATER];
'@ @'
var MUS_THEMES=[HUB_THEME,THEME_TIN,THEME_DEEP,THEME_LAMPS,THEME_WATER];
// v24.06, HIS ANSWER 27 b (2026-10-12): "music on the title and the demo video only, never in raids". THE ASCENT is the one piece
// that plays now: D minor, the four dark levers of v9.87 and v10.61 kept (the tune an octave down, the 900 Hz corner, no faster than
// 76 a minute), and under it a kit that hits: a deep kick on 1, the and of 2 and 3, a low thud of a snare on the backbeat, and the
// bass root pulsing in eighths, so the title lands like a trailer and not like a room tone. Drums and pulse are Web Audio voices made
// on the spot (a falling sine for the kick, a band of noise for the snare), through the same music gain, so the MUSIC and MASTER rows
// and the one-song rule for two windows hold. It is kept out of MUS_THEMES, the Undercroft list the older tune checks read.
var THEME_TITLE={
  name:'THE ASCENT', spb:0.163, title:1,
  bars:[
    {c:'Dm',b:38, lead:[74,0,0,0, 0,0,0,0,  77,0,0,0, 76,0,0,0]},
    {c:'Dm',b:38, lead:[74,0,0,0, 0,0,0,0,  0,0,0,0,  69,0,0,0]},
    {c:'Bb',b:34, lead:[70,0,0,0, 0,0,0,0,  74,0,0,0, 72,0,0,0]},
    {c:'Bb',b:34, lead:[70,0,0,0, 0,0,0,0,  0,0,0,0,  0,0,0,0]},
    {c:'Gm',b:31, lead:[67,0,0,0, 0,0,0,0,  70,0,0,0, 74,0,0,0]},
    {c:'Gm',b:31, lead:[72,0,0,0, 0,0,0,0,  70,0,0,0, 0,0,0,0]},
    {c:'A', b:33, lead:[69,0,0,0, 0,0,0,0,  73,0,0,0, 76,0,0,0]},
    {c:'A', b:33, lead:[73,0,0,0, 0,0,0,0,  0,0,0,0,  0,0,0,0]}
  ]
};
var MUS_KICK={0:1,6:0.7,8:1}, MUS_SNARE={4:1,12:1}, MUS_NZ=null;
// One step of the title kit. a must be a real context (the dry recorder of the fixture passes a number) and MUS.g must exist.
function musDrum(a,t,si,bb){
  var o, g, s, f, k=MUS_KICK[si], sn=MUS_SNARE[si], i, c;
  if(!a||typeof a.createOscillator!=='function'||!MUS.g) return 0;
  if(k){
    o=a.createOscillator(); g=a.createGain(); o.type='sine';
    o.frequency.setValueAtTime(120,t); o.frequency.exponentialRampToValueAtTime(42,t+0.16);
    g.gain.setValueAtTime(0.0001,t); g.gain.exponentialRampToValueAtTime(0.9*k,t+0.004); g.gain.exponentialRampToValueAtTime(0.001,t+0.42);
    o.connect(g); g.connect(MUS.g); o.start(t); o.stop(t+0.45);
  }
  if(sn){
    if(!MUS_NZ){ MUS_NZ=a.createBuffer(1,4410,a.sampleRate||44100); c=MUS_NZ.getChannelData(0); for(i=0;i<c.length;i++) c[i]=Math.random()*2-1; }
    s=a.createBufferSource(); s.buffer=MUS_NZ; f=a.createBiquadFilter(); f.type='bandpass'; f.frequency.value=850; f.Q.value=0.7;
    g=a.createGain(); g.gain.setValueAtTime(0.0001,t); g.gain.exponentialRampToValueAtTime(0.55,t+0.003); g.gain.exponentialRampToValueAtTime(0.001,t+0.2);
    s.connect(f); f.connect(g); g.connect(MUS.g); s.start(t); s.stop(t+0.22);
    o=a.createOscillator(); var g2=a.createGain(); o.type='triangle'; o.frequency.setValueAtTime(190,t); o.frequency.exponentialRampToValueAtTime(120,t+0.08);
    g2.gain.setValueAtTime(0.0001,t); g2.gain.exponentialRampToValueAtTime(0.35,t+0.003); g2.gain.exponentialRampToValueAtTime(0.001,t+0.12);
    o.connect(g2); g2.connect(MUS.g); o.start(t); o.stop(t+0.14);
  }
  if((si&1)===0&&bb){
    o=a.createOscillator(); g=a.createGain(); o.type='sawtooth'; o.frequency.value=440*Math.pow(2,(bb-69)/12);
    f=a.createBiquadFilter(); f.type='lowpass'; f.frequency.value=260; f.Q.value=1.2;
    g.gain.setValueAtTime(0.0001,t); g.gain.exponentialRampToValueAtTime(0.16,t+0.01); g.gain.exponentialRampToValueAtTime(0.001,t+0.17);
    o.connect(f); f.connect(g); g.connect(MUS.g); o.start(t); o.stop(t+0.19);
  }
  return (k?1:0)+(sn?2:0);
}
'@

SubRx @'
function musPick(){
  MUS.trk=MUS_THEMES[Math.floor(Math.random()*MUS_THEMES.length)]||HUB_THEME;
'@ @'
function musPick(){
  MUS.trk=THEME_TITLE;   // v24.06 (his answer 27 b): the title and the demo video play THE ASCENT; the Undercroft is silent
'@

SubRx @'
  var ch=HUB_CHORDS[cn]||HUB_CHORDS.Am;
'@ @'
  var ch=HUB_CHORDS[cn]||HUB_CHORDS.Am;
  if(T.title){ try{ musDrum(a,t,si,bb); }catch(_md){} }   // v24.06 (his answer 27 b): the title kit
'@

SubRx @'
  if(typeof pendingRun!=='undefined'&&pendingRun) return false;
'@ @'
  if(typeof pendingRun!=='undefined'&&pendingRun) return false;
  // v24.06, HIS ANSWER 27 b (2026-10-12): "music on the title and the demo video only, never in raids". The Undercroft floor is
  // silent now; the title screen plays, and so does the demo attract while its video runs (the video itself is muted). A raid was
  // already silent (the G line above). The one-song rule for two windows below still holds.
  if(!((typeof titleOn==='function'&&titleOn())||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&typeof ATT==='object'&&ATT&&ATT.on))) return false;
'@

SubRx @'
var VER='24.05';
'@ @'
var VER='24.06';
'@

$pat = "(?m)^  now:'v24\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.06: Music now plays on the title and the demo attract only, with a new dark track; the Undercroft is silent. Check 24.06 fails on v24.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
