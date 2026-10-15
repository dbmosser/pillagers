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

# THE GUN MOMENTS HAVE SOUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(f<AR_A||f>AR_B) return false;
'@ @'
  // v27.95 (snd4), HIS ORDER (2026-10-15, "add the sounds"): THE GUN MOMENTS HAVE SOUNDS. The active reload's sweet spot made the old reload ping and a press outside
  // it made nothing, so you could not hear whether you had hit it. Now a press in the sweet spot is a bright lock click and a low thump (arHit), and a press outside it
  // a dull miss (arMiss); the Support MG's spin has its own sound, a motor engaging and a whine climbing two octaves as the barrels wind up (lmgSpinUp) and falling as
  // they wind down (lmgWindDown); and the finisher lands with a heavy blow of its own (finishBlow) on top of the crowbar sound. No words, no voices. Cosmetic only:
  // no seeded draw, no game state.
  if(f<AR_A||f>AR_B){ try{ blip('arMiss'); }catch(_am){} return false; }
'@

SubRx @'
  try{ rlfxPing(0); spark(p.x,p.y-14,'#9fe8b0',14,260); label(p.x,p.y-34,'ACTIVE RELOAD','#9fe8b0',0,true); }catch(_ar){}
'@ @'
  try{ blip('arHit'); spark(p.x,p.y-14,'#9fe8b0',14,260); label(p.x,p.y-34,'ACTIVE RELOAD','#9fe8b0',0,true); }catch(_ar){}
'@

SubRx @'
function lmgWhirr(){
  var a, out, t, o, f, g;
  if((G&&G.sim)||(typeof NET==='object'&&NET&&NET.specTick)) return;
  a=ac(); if(!a) return; out=sndBus('gun'); if(!out) return;
  lmgWhirrStop();
  try{
    t=a.currentTime; o=a.createOscillator(); f=a.createBiquadFilter(); g=a.createGain();
    o.type='sawtooth'; o.frequency.setValueAtTime(70,t); o.frequency.exponentialRampToValueAtTime(260,t+LMG_SPIN_T);
    f.type='lowpass'; f.frequency.value=900; f.Q.value=0.9;
    g.gain.setValueAtTime(0.0001,t); g.gain.linearRampToValueAtTime(0.05,t+LMG_SPIN_T*0.6); g.gain.linearRampToValueAtTime(0.0001,t+LMG_SPIN_T+0.05);
    o.connect(f); f.connect(g); g.connect(out); o.start(t); o.stop(t+LMG_SPIN_T+0.08);
    LMGSPIN.hum={o:o,g:g};
  }catch(e){}
}
'@ @'
function lmgWhirr(){
  var h=null;
  if((G&&G.sim)||(typeof NET==='object'&&NET&&NET.specTick)) return;
  lmgWhirrStop();
  try{ h=spkPlay('lmgSpinUp',{wid:(G&&G.player&&G.player.spin)||0}); }catch(e){ h=null; }   // v27.95 (snd4): the motor and the climbing whine, from the spin it starts at
  LMGSPIN.hum=h;   // the handle {g,o} (a gain node and a source with stop) that lmgWhirrStop cuts in 50 ms
}
'@

SubRx @'
  else if(!want&&LMGSPIN.hum) lmgWhirrStop();
'@ @'
  else if(!want&&LMGSPIN.hum){ lmgWhirrStop(); try{ spkPlay('lmgWindDown',{wid:was}); }catch(_lw){} }   // v27.95 (snd4): let go, the whine falls and the rattle slows from the spin you let go at
'@

SubRx @'
  try{ meleeImpact(p.x,p.y,e.x,e.y,e.r); meleeFoley('hit',e.x,e.y); G.shake=Math.max(G.shake||0,4.2); bloodFx(e.x,e.y-14,p.x,p.y,40); }catch(_f){}
'@ @'
  try{ meleeImpact(p.x,p.y,e.x,e.y,e.r); meleeFoley('hit',e.x,e.y); sfx('finishBlow',e.x,e.y); G.shake=Math.max(G.shake||0,4.2); bloodFx(e.x,e.y-14,p.x,p.y,40); }catch(_f){}   // v27.95 (snd4): and the heavy blow of the finisher on top
'@

SubRx @'
var VER='27.94';
'@ @'
var VER='27.95';
'@

$pat = "(?m)^  now:'v27\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.95: The active reload, the Support MG spin and the finisher have their own sounds. Check 27.95 fails on v27.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
