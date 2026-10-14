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

# MUSIC AT THE END OF A RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var MUS={g:null,lp:null,next:0,step:0};
'@ @'
var MUS={g:null,lp:null,next:0,step:0};
// v26.xx (outcomemusic): the end of a raid stinger (outMusic, below): its own gain and lowpass on the music path, the clock it rings until
// (end, on the audio clock; wall, the same on the page clock, so a stopped audio clock cannot hold the title music for ever), how many
// have started (n) and which (last), and the level it asks for before the Music and Master rows (base).
var OUTM={g:null,lp:null,nz:null,nzAc:null,end:0,wall:0,n:0,last:'',base:0.36};
'@

SubRx @'
    if(typeof MUS==='object'&&MUS&&MUS.g&&MUS.g.gain&&typeof MUS.lvl==='number'){ a=(typeof AC!=='undefined'&&AC)?AC.currentTime:0; try{ MUS.g.gain.setTargetAtTime(MUS.lvl*mu*m,a,0.5); }catch(_vm){} }
'@ @'
    if(typeof MUS==='object'&&MUS&&MUS.g&&MUS.g.gain&&typeof MUS.lvl==='number'){ a=(typeof AC!=='undefined'&&AC)?AC.currentTime:0; try{ MUS.g.gain.setTargetAtTime(MUS.lvl*mu*m,a,0.5); }catch(_vm){} }
    // v26.xx (outcomemusic): and a stinger that is ringing follows the rows too
    try{ if(typeof OUTM==='object'&&OUTM&&OUTM.g&&OUTM.g.gain&&typeof AC!=='undefined'&&AC&&OUTM.end>AC.currentTime) OUTM.g.gain.setTargetAtTime(OUTM.base*outLevel(),AC.currentTime,0.05); }catch(_vo){}
'@

SubRx @'
function musicWanted(){
  if(musicMode()==='off') return false;
'@ @'
function musicWanted(){
  if(musicMode()==='off') return false;
  // v26.xx (outcomemusic): THE TITLE AND THE ATTRACT WAIT FOR THE END OF A RAID PIECE. The EXTRACTED and KILLED IN ACTION pieces (outMusic)
  // ring for about five and a half seconds after the card comes up, and the title or the demo attract can be on screen the moment
  // the card is gone, so their song starts only after it has rung out and the two never play over each other.
  if(OUTM.end>0&&AC&&AC.currentTime<OUTM.end&&Date.now()<OUTM.wall) return false;
'@

SubRx @'
  try{ if(typeof NET==='object'&&NET&&NET.same&&NET.musP) netMusPan(); }catch(_mpt){}   // v21.22 (R5): the song moves to the middle when both players are on the floor
'@ @'
  try{ if(typeof NET==='object'&&NET&&NET.same&&NET.musP) netMusPan(); }catch(_mpt){}   // v21.22 (R5): the song moves to the middle when both players are on the floor
  // v26.xx (outcomemusic): NOTHING PLAYS WHILE A RAID IS LIVE. A piece from the last raid that is still ringing when a new raid goes up
  // (the demo drops the next run in 1.5 seconds after RUN OVER) is cut here, every frame it could still be heard. The card of a raid that
  // just ended holds G.over, so the piece that card started is not touched.
  try{ if(OUTM.end>0&&G&&!G.over) outMusicCut(); }catch(_omc){}
'@

SubRx @'
// The acoustic of a world point. Ordered most enclosed first, because a locked
'@ @'
// v26.xx (outcomemusic), HIS ORDER (2026-10-14): "add some success music when player successful extracts and some failure music when
// player is KIA". TWO SHORT PIECES, one for each way a raid can end, in the dark low register of the title: a rising one for EXTRACTED
// and a falling one for KILLED IN ACTION, 5.6 seconds each, all Web Audio voices (no files). THEY ARE NOT RAID MUSIC and his ruling
// "no music in raids" stands: each plays ONCE as the end card comes up (endRaid for a career or any ordinary raid; the RUN OVER card of the
// DEMO, an extraction run or a death or burn run; and the player 2 window when the host run end reaches it), never while a raid is
// live (tickMusic cuts one still ringing when a raid goes up), and the title and the attract wait for it to ring out (musicWanted), so
// the two never overlap. An abandon plays none: backing out is not a result to score, and a tune for a choice would be wrong either way.
// They ride the music path: a gain of their own behind a lowpass, out through netMusOut like the title (so a window whose sound is off or
// panned to a side stays so), scaled by the Music and Master rows and the musicVol dial, so Music OFF and a Music volume of Off build
// nothing at all. They sit on no sound bus: nothing ducks them and they duck nothing. EXTRACTED: a low heartbeat that climbs, under D minor,
// F, G minor and A with the bass walking up and a line climbing D F G A, then the hit and a bright D major with a shimmer above it that
// rings out. KILLED IN ACTION: a dull hit over a bare D drone (D1, D2 with a grit in it, a fifth coming in) that fades, a slow line
// falling A G F E D over it, and a thin D minor under the last note. No seeded draw (the noise is a fixed sequence of its own), nothing
// under G.sim, no game state.
function outHz(m){ return 440*Math.pow(2,(m-69)/12); }
function outLevel(){ return volOf('volMusic')*volOf('volMaster')*(CFG.musicVol===undefined?1:CFG.musicVol); }
// the notes of one piece: [start s, from Hz, to Hz, seconds, wave, peak, attack s, noise lowpass Hz]; len the whole piece, lp the corner of
// its lowpass, fig the Hz of the line you hear (the order they come in)
function outSpec(k){
  var N=[], F=[];
  function nt(t0,m0,m1,d,w,pk,at){ N.push([t0,outHz(m0),outHz(m1),d,w,pk,at]); }
  function hit(t0,f0,f1,d,pk){ N.push([t0,f0,f1,d,'sine',pk,0.004]); }
  if(k==='win'){
    [0,0.8,1.6,2.4].forEach(function(t0,i){ hit(t0,100,40,0.5,0.40+i*0.05); });   // the low pulse, a heartbeat that climbs...
    hit(3.2,112,34,1.0,0.62);                                                         // ...into the hit on the last chord
    [[0,38],[0.8,41],[1.6,43],[2.4,45]].forEach(function(b){ nt(b[0],b[1],b[1],1.05,'triangle',0.26,0.03); });   // the bass walks up: D F G A
    [[0,[50,57,62]],[0.8,[53,57,60]],[1.6,[55,58,62]],[2.4,[57,61,64]]].forEach(function(c){ c[1].forEach(function(m){ nt(c[0],m,m,1.05,'triangle',0.07,0.2); }); });   // D minor, F, G minor, A
    nt(3.2,38,38,2.4,'triangle',0.28,0.02); nt(3.2,26,26,2.4,'sine',0.22,0.02);        // the last chord: D2 and a sub D1 under it...
    [50,57,62,66,69].forEach(function(m){ nt(3.2,m,m,2.4,'triangle',0.075,0.03); });    // ...D major, D3 A3 D4 F#4 A4...
    [62,66,69].forEach(function(m){ nt(3.2,m,m,2.2,'sawtooth',0.022,0.03); });          // ...with the edge that makes it bright...
    nt(3.35,78,78,2.2,'sine',0.045,0.02); nt(3.5,81,81,2.0,'sine',0.03,0.02);           // ...and F#5 and A5 shimmering above
    [[0.1,62],[0.9,65],[1.7,67],[2.5,69],[3.2,74]].forEach(function(l,j){ nt(l[0],l[1],l[1],j<4?0.9:2.4,'triangle',j<4?0.10:0.11,0.05); F.push(outHz(l[1])); });   // the line: D F G A, then D5
    return {len:5.6,lp:2600,chordAt:3.2,fig:F,notes:N};
  }
  if(k==='kia'){
    hit(0,90,32,1.1,0.72);                                  // the hit...
    N.push([0,0,0,0.7,'noise',0.28,0.003,240]);              // ...with a dull thud of low noise under it
    nt(0,26,26,5.5,'sine',0.30,0.05); nt(0,38,38,5.5,'triangle',0.22,0.05);   // the drone: D1 and D2...
    nt(0,38,38,4.6,'sawtooth',0.035,0.3);                    // ...with a grit in it...
    nt(0.5,45,45,5.0,'triangle',0.09,0.7);                   // ...and a bare fifth coming in
    [[0.55,69,1.3],[1.35,67,1.3],[2.15,65,1.5],[3.05,64,1.3],[3.9,62,1.7]].forEach(function(l){   // the line falls: A G F E D
      nt(l[0],l[1],l[1],l[2],'triangle',0.11,0.07); nt(l[0],l[1],l[1],l[2],'square',0.028,0.07); nt(l[0],l[1]-12,l[1]-12,l[2],'sine',0.05,0.07); F.push(outHz(l[1]));
    });
    [50,53,57].forEach(function(m){ nt(3.9,m,m,1.7,'triangle',0.05,0.4); });   // a thin D minor under the last note
    return {len:5.6,lp:1100,fig:F,notes:N};
  }
  return null;
}
// half a second of noise from a fixed sequence of its own (a linear congruential), made once per audio context
function outNoise(a){
  var sr=a.sampleRate||44100, L=Math.floor(sr*0.8), b, c, i, s=12345;
  if(OUTM.nz&&OUTM.nzAc===a) return OUTM.nz;
  b=a.createBuffer(1,L,sr); c=b.getChannelData(0);
  for(i=0;i<L;i++){ s=(s*1664525+1013904223)>>>0; c[i]=s/2147483648-1; }
  OUTM.nz=b; OUTM.nzAc=a;
  return b;
}
// one voice of a piece into dest, t the start of the piece
function outVoice(a,dest,t,n){
  var T=t+n[0], d=n[3], A=n[6]||0.01, g=a.createGain(), o, s, f;
  g.gain.setValueAtTime(0.0001,T); g.gain.linearRampToValueAtTime(n[5],T+A); g.gain.exponentialRampToValueAtTime(0.0005,T+d);
  if(n[4]==='noise'){
    s=a.createBufferSource(); s.buffer=outNoise(a); s.loop=true;
    f=a.createBiquadFilter(); f.type='lowpass'; f.frequency.value=n[7]||300; f.Q.value=0.7;
    s.connect(f); f.connect(g); g.connect(dest); s.start(T); s.stop(T+d+0.05);
    return;
  }
  o=a.createOscillator(); o.type=n[4]; o.frequency.setValueAtTime(n[1],T);
  if(n[2]!==n[1]) o.frequency.exponentialRampToValueAtTime(n[2],T+Math.min(d*0.35,0.3));
  o.connect(g); g.connect(dest); o.start(T); o.stop(T+d+0.05);
}
// Play the piece for how a raid ended: 'win' (EXTRACTED) or 'kia' (KILLED IN ACTION). One at a time; nothing is built when the music is off
// or at nothing. Returns whether it started.
function outMusic(k){
  var a, sp, t, lv, d, g, lp, i;
  if(G&&G.sim) return false;
  if(musicMode()==='off') return false;
  lv=outLevel(); if(!(lv>0)) return false;
  sp=outSpec(k); if(!sp) return false;
  a=ac(); if(!a) return false;
  t=a.currentTime; if(t<OUTM.end) return false;
  try{
    d=netMusOut(a); if(!d) return false;
    g=a.createGain(); g.gain.value=OUTM.base*lv;
    lp=a.createBiquadFilter(); lp.type='lowpass'; lp.frequency.value=sp.lp; lp.Q.value=0.6;
    lp.connect(g); g.connect(d);
    for(i=0;i<sp.notes.length;i++) outVoice(a,lp,t+0.03,sp.notes[i]);
  }catch(_om){ return false; }
  OUTM.g=g; OUTM.lp=lp; OUTM.end=t+0.03+sp.len; OUTM.wall=Date.now()+Math.round((sp.len+0.6)*1000); OUTM.n++; OUTM.last=k;
  return true;
}
// A raid is up while a piece rings: fade it out fast and let the title wait no longer (tickMusic).
function outMusicCut(){
  var a=(typeof AC!=='undefined'&&AC)?AC:null;
  OUTM.end=0;
  if(OUTM.g&&OUTM.g.gain&&a){ try{ OUTM.g.gain.cancelScheduledValues(a.currentTime); OUTM.g.gain.setTargetAtTime(0,a.currentTime,0.05); }catch(_oc){} }
  return true;
}
// The acoustic of a world point. Ordered most enclosed first, because a locked
'@

SubRx @'
  document.getElementById('outcome').classList.add('on');
}
function buildTags(){
'@ @'
  document.getElementById('outcome').classList.add('on');
  // v26.xx (outcomemusic), HIS ORDER (2026-10-14): the piece for how the raid ended plays as the card comes up. An abandon plays none.
  try{ if(how==='extract') outMusic('win'); else if(how==='dead') outMusic('kia'); }catch(_om){}
}
function buildTags(){
'@

SubRx @'
  ARCADE.over={at:Date.now(),why:String(why||''),team:arcadeTeam(),p1:host?me:mt,p2:host?mt:me};
'@ @'
  ARCADE.over={at:Date.now(),why:String(why||''),team:arcadeTeam(),p1:host?me:mt,p2:host?mt:me};
  try{ outMusic(why==='extract'?'win':((why==='dead'||why==='burn')?'kia':'')); }catch(_om){}   // v26.xx (outcomemusic): the RUN OVER card of an extraction run, a death or a burn plays its piece; an idle out or END RUN none
'@

SubRx @'
  ARCADE.endSend={id:id,at:now,last:now,x2:x2};
  netSamePost({t:'arcend',pair:NET.pair,run:id,x2:x2});
'@ @'
  var ko=(!x2&&ARCADE.over&&(ARCADE.over.why==='dead'||ARCADE.over.why==='burn'))?1:0;   // v26.xx (outcomemusic): a run that ended on a death or the burn, so player 2 plays the failure piece
  ARCADE.endSend={id:id,at:now,last:now,x2:x2,ko:ko};
  netSamePost(ko?{t:'arcend',pair:NET.pair,run:id,x2:x2,ko:1}:{t:'arcend',pair:NET.pair,run:id,x2:x2});
'@

SubRx @'
  netSamePost({t:'arcend',pair:NET.pair,run:e.id,x2:e.x2?1:0});
'@ @'
  netSamePost(e.ko?{t:'arcend',pair:NET.pair,run:e.id,x2:e.x2?1:0,ko:1}:{t:'arcend',pair:NET.pair,run:e.id,x2:e.x2?1:0});
'@

SubRx @'
      return arcadeEndTake();
'@ @'
      // v26.xx (outcomemusic): the host run end is how this window hears its own outcome: the doubled score of an extraction (x2) plays the
      // success piece, a death or the burn (ko) the failure piece, anything else (END RUN, an idle out) none. It plays while the raid is
      // still up here, or within four seconds of the marked out word that stopped it (the out word can arrive first).
      try{ if((G&&G.arcade&&!G.netWasJoin)||Date.now()-(+ARCADE.p2StopAt||0)<4000) outMusic(m.x2?'win':(m.ko?'kia':'')); }catch(_om){}
      return arcadeEndTake();
'@

SubRx @'
  if(G&&G.arcade&&!G.netWasJoin) arcadeRaidStop('end');
'@ @'
  if(G&&G.arcade&&!G.netWasJoin){ ARCADE.p2StopAt=Date.now(); arcadeRaidStop('end'); }   // v26.xx (outcomemusic): and when, for the success or failure piece of the arcend that follows
'@

SubRx @'
var VER='26.21';
'@ @'
var VER='26.22';
'@

$pat = "(?m)^  now:'v26\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.22: The EXTRACTED card plays a short rising piece and the KILLED IN ACTION card a low falling one, at the Music volume. Check 26.22 fails on v26.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
