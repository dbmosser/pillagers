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

# IMPACTS SOUND LIKE WHAT THEY HIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function blip(type,d,pan){
'@ @'
// v23.84, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible): IMPACTS BY MATERIAL. Every round that hit a wall
// made the same faint tick, a tree the same as a car door or a window, and every round that hit a body made the same square blip,
// a pillager the same as a Warden. Now what is hit is heard: concrete chips, wood thocks, glass shatters, metal and armour ring,
// flesh thuds. matOf reads the wall flags (tree and furniture are wood, a window glass, a wreck, a locked wall or a door metal,
// the rest concrete); entMat reads the body (a pillager is flesh, the Bulwark and the Warden armour, every other machine metal).
// The material rides the fourth argument of sfx, which the party already passes on, so the other window hears it too. A clank
// or a hit with no material (the menus use the clank to say no) plays exactly as before. The decal roll beside the wall hit is
// untouched, so the seeded stream does not move.
function matOf(w){
  if(!w) return 'concrete';
  if(w.tree||w.furn) return 'wood';
  if(w.win) return 'glass';
  if(w.wreck||w.lockWall||w.door) return 'metal';
  return 'concrete';
}
function entMat(e){
  if(!e) return 'metal';
  if(e.kind==='raider'||e.k==='deer'||e.critter) return 'flesh';
  if(e.kind==='bulwark'||e.kind==='warden') return 'armor';
  return 'metal';
}
function impactMat(a,OUT,type,mat,vol,t){
  var i, n, b, c, s, f, g, o, og, o2, og2;
  function noise(len,pw,ft,fq,q,gv,at){
    var nb=a.createBuffer(1,len,a.sampleRate), nc=nb.getChannelData(0), j;
    for(j=0;j<len;j++) nc[j]=(Math.random()*2-1)*Math.pow(1-j/len,pw);
    var ns=a.createBufferSource(); ns.buffer=nb;
    var nf=a.createBiquadFilter(); nf.type=ft; nf.frequency.value=fq; nf.Q.value=q;
    var ng=a.createGain(); ng.gain.value=gv;
    ns.connect(nf); nf.connect(ng); ng.connect(OUT); ns.start(at);
  }
  function tone(ty,f0,f1,dur,gv,at){
    var to=a.createOscillator(), tg=a.createGain(); to.type=ty;
    to.frequency.setValueAtTime(f0,at); to.frequency.exponentialRampToValueAtTime(f1,at+dur);
    tg.gain.setValueAtTime(gv,at); tg.gain.exponentialRampToValueAtTime(0.0005,at+dur+0.01);
    to.connect(tg); tg.connect(OUT); to.start(at); to.stop(at+dur+0.02);
  }
  var J=1+(Math.random()*2-1)*0.08;
  if(mat==='flesh'){ noise(700,2.2,'lowpass',620*J,0.8,0.16*vol,t); tone('sine',150*J,58,0.09,0.12*vol,t); return true; }
  if(mat==='armor'){ tone('triangle',540*J,500*J,0.16,0.07*vol,t); tone('triangle',830*J,790*J,0.12,0.045*vol,t); noise(300,3,'highpass',2200*J,0.7,0.07*vol,t); return true; }
  if(mat==='metal'){ tone('triangle',(type==='hit'?1400:1100)*J,(type==='hit'?1250:980)*J,0.10,0.06*vol,t); noise(260,3,'bandpass',3200*J,2,0.06*vol,t); if(type==='hit') tone('square',240,70,0.09,0.07*vol,t); return true; }
  if(mat==='wood'){ noise(900,2.6,'lowpass',760*J,1.4,0.11*vol,t); tone('sine',190*J,110*J,0.07,0.06*vol,t); return true; }
  if(mat==='glass'){ noise(1400,1.8,'highpass',4800*J,0.7,0.07*vol,t); tone('triangle',2600*J,2500*J,0.14,0.025*vol,t+0.02); tone('triangle',3400*J,3300*J,0.11,0.02*vol,t+0.05); return true; }
  if(mat==='concrete'){ noise(520,2.4,'bandpass',1150*J,1.1,0.10*vol,t); noise(380,1.6,'highpass',3000*J,0.7,0.035*vol,t+0.012); return true; }
  return false;
}
function blip(type,d,pan){
'@

SubRx @'
  } else if(type==='hit'){
    var o=a.createOscillator(),g3=a.createGain();
'@ @'
  } else if(type==='hit'&&impactMat(a,OUT,'hit',arguments[3],vol,t)){
    // v23.84 (his #45): a hit on flesh, armour or metal is heard as what it is
  } else if(type==='hit'){
    var o=a.createOscillator(),g3=a.createGain();
'@

SubRx @'
  } else if(type==='clank'){
    var o4=a.createOscillator(),g6=a.createGain();
'@ @'
  } else if(type==='clank'&&impactMat(a,OUT,'clank',arguments[3],vol,t)){
    // v23.84 (his #45): a round hitting concrete, wood, glass or metal is heard as what it hit
  } else if(type==='clank'){
    var o4=a.createOscillator(),g6=a.createGain();
'@

SubRx @'
life:.18,c:'#8a939c',r:6});
          sfx("clank",b.x,b.y);
'@ @'
life:.18,c:'#8a939c',r:6});
          sfx("clank",b.x,b.y,matOf(_struck));
'@

SubRx @'
          sfx("clank",b.x,b.y); hit=true;
'@ @'
          sfx("clank",b.x,b.y,matOf(_struck)); hit=true;
'@

SubRx @'
spark(b.x,b.y,WK.c,26,340);
                  sfx('clank',b.x,b.y);
'@ @'
spark(b.x,b.y,WK.c,26,340);
                  sfx('clank',b.x,b.y,'metal');
'@

SubRx @'
spark(b.x,b.y,'#9fb4c4',10,220);
                  sfx('clank',b.x,b.y);
'@ @'
spark(b.x,b.y,'#9fb4c4',10,220);
                  sfx('clank',b.x,b.y,'armor');
'@

SubRx @'
if(NET.on&&netEntsPeer()) sfxHere("hit",en.x,en.y); else sfx("hit",en.x,en.y);
'@ @'
if(NET.on&&netEntsPeer()) sfxHere("hit",en.x,en.y,entMat(en)); else sfx("hit",en.x,en.y,entMat(en));
'@

SubRx @'
              sfx("hit",CW.x,CW.y); hit=true; break;
'@ @'
              sfx("hit",CW.x,CW.y,"flesh"); hit=true; break;
'@

SubRx @'
var VER='23.83';
'@ @'
var VER='23.84';
'@

$pat = "(?m)^  now:'v23\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.84: Bullet impacts sound like what they hit: concrete, wood, glass, metal, armour or flesh. Check 23.84 fails on v23.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
