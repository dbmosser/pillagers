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

# ALARMS VOLUME ROW AND A LIGHT TICK ON YOUR LAST ROUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SND_CAT={shot:'gun',reload:'gun',reloadin:'gun',dry:'gun',
'@ @'
var SND_CAT={shot:'gun',reload:'gun',reloadin:'gun',dry:'gun',lowmag:'gun',
'@

SubRx @'
pickGun:'ui',clockwarn:'ui',clocktick:'ui',
'@ @'
pickGun:'ui',clockwarn:'sting',clocktick:'sting',
'@

SubRx @'
var SND_CATS=['gun','imp','mach','foley','amb','vox','ui','sting','world'];
'@ @'
var SND_CATS=['gun','imp','mach','foley','amb','vox','ui','sting','world'];
// v36.xx (cw-alarmvol), HIS ORDER (2026-10-25, g-81 "Yes, their own row"; harsh sound is his worst party problem, answer 27): ALARMS VOLUME. The raid alarms
// and the raid clock get a row of their own in AUDIO, on top of effects volume. blip scales these types by it; the lock-on siren, the crit and warn stings,
// the teammate down alert and the two and one minute cues scale themselves. At FULL the mix is exactly what it was.
var SND_ALARM={alarm:1,seen:1,xalarm:1,lastcall:1,clockwarn:1,clocktick:1,lastmin:1};
function alarmVolK(t){ return SND_ALARM[t]?volOf('volAlarm'):1; }
'@

SubRx @'
// v26.xx (settings1): FOOTSTEPS VOLUME, the steps you make and the ones you hear
'@ @'
// v26.xx (settings1): FOOTSTEPS VOLUME, the steps you make and the ones you hear
  vol*=alarmVolK(type);   // v36.xx (cw-alarmvol): ALARMS VOLUME, before the quiet return so OFF is silent
'@

SubRx @'
dys.connect(dyf); dyf.connect(dyg); dyg.connect(OUT); dys.start(t);
'@ @'
dys.connect(dyf); dyf.connect(dyg); dyg.connect(OUT); dys.start(t);
    }
    if(type==='lowmag'){
    // v36.xx (cw-lowmag), HIS ANSWER (2026-10-25, g-82 "Add a lighter click near empty"): a light tick on your last rounds, about half the dry click, a hair
    // after the crack so it lands under the shot and not on top of it.
    var lmb=a.createBuffer(1,260,a.sampleRate),lmc=lmb.getChannelData(0);
    for(var lmi=0;lmi<260;lmi++) lmc[lmi]=(Math.random()*2-1)*Math.pow(1-lmi/260,2.6);
    var lms=a.createBufferSource(); lms.buffer=lmb;
    var lmf=a.createBiquadFilter(); lmf.type='bandpass'; lmf.frequency.value=3600; lmf.Q.value=6;
    var lmg=a.createGain(); lmg.gain.value=.05*vol;
    lms.connect(lmf); lmf.connect(lmg); lmg.connect(OUT); lms.start(t+.03);
'@

SubRx @'
*(0.7+0.3*clamp(1-nd/MSIREN_R,0,1))*kw;
'@ @'
*(0.7+0.3*clamp(1-nd/MSIREN_R,0,1))*kw; lv*=volOf('volAlarm'); /* v36.xx (cw-alarmvol): ALARMS VOLUME, the locked on text stays */
'@

SubRx @'
function alertSting(k){ if(!G||G.sim||!ALERTSND[k]) return false; return styTone(ALERTSND[k]); }
'@ @'
// v36.xx (cw-alarmvol): ALARMS VOLUME scales the crit and warn stings (OFF is silent); the extraction and good news sting stays on effects.
function alertSting(k){
  var n, v;
  if(!G||G.sim||!ALERTSND[k]) return false;
  n=ALERTSND[k];
  if(k==='crit'||k==='warn'){
    v=volOf('volAlarm'); if(!(v>0)) return false;
    if(v<1) n=n.map(function(q){ var c=q.slice(); c[5]=q[5]*v; return c; });
  }
  return styTone(n);
}
'@

SubRx @'
var a, out, t, i, o, og, f=[880,660,880,660], at;
'@ @'
var a, out, t, i, o, og, f=[880,660,880,660], at, mv=volOf('volAlarm');
  if(!(mv>0)) return false;   // v36.xx (cw-alarmvol): ALARMS VOLUME, the teammate down alert follows it
'@

SubRx @'
og.gain.exponentialRampToValueAtTime(0.2,at+0.012);
'@ @'
og.gain.exponentialRampToValueAtTime(0.2*mv,at+0.012);
'@

SubRx @'
var a, sp, t, out, f=null, i, n, o, g;
'@ @'
var a, sp, t, out, f=null, i, n, o, g, av=1;
'@

SubRx @'
sp=annSpec(k); if(!sp) return false;
'@ @'
sp=annSpec(k); if(!sp) return false;
  // v36.xx (cw-alarmvol): the two and one minute cues follow ALARMS VOLUME; OFF returns before the announcer is marked busy.
  if(k==='TWOMIN'||k==='ONEMIN'){ av=volOf('volAlarm'); if(!(av>0)) return false; if(av<1) sp={len:sp.len,lp:sp.lp,notes:sp.notes.map(function(q){ var c=q.slice(); c[5]=q[5]*av; return c; })}; }
'@

SubRx @'
hint:'Menu clicks and HUD pings: pickups, hit ticks and the clock. On top of effects volume.',
'@ @'
hint:'Menu clicks and HUD pings: pickups and hit ticks. On top of effects volume.',
'@

SubRx @'
{k:'mono', label:'MONO AUDIO', sec:'AUDIO',
'@ @'
// v36.xx (cw-alarmvol), HIS ORDER (2026-10-25, g-81): alarms, warnings and the raid clock on their own level. See SND_ALARM.
  {k:'volAlarm', label:'ALARMS VOLUME', sec:'AUDIO',
   hint:'Alarms, warnings and the raid clock. On top of effects volume.',
   opts:[
     {n:'OFF',  cfg:{volAlarm:0}},
     {n:'25%',  cfg:{volAlarm:0.25}},
     {n:'50%',  cfg:{volAlarm:0.5}},
     {n:'75%',  cfg:{volAlarm:0.75}},
     {n:'FULL', cfg:{volAlarm:1}}
   ], def:4},
  {k:'mono', label:'MONO AUDIO', sec:'AUDIO',
'@

SubRx @'
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@ @'
// v36.xx (cw-lowmag), HIS ANSWER (2026-10-25, g-82 "Add a lighter click near empty"): the last quarter of a magazine ticks under the shot, the same red step as the
// magazine ring. Only this window hears it (blip, not blipMine). Not for melee (mag 0) or with the infinite clip power up.
function lowMagClick(p){
  var m, lim;
  if(!p||!p.wep||!G||G.sim) return false;
  m=p.wep.mag; if(!(m>0)||pwrClip()) return false;
  lim=Math.max(1,Math.floor(m*0.25));
  if(!(p.ammo>=1&&p.ammo<=lim)) return false;
  blip('lowmag');
  return true;
}
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@

SubRx @'
fireWeapon(p,p.wep,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true);
'@ @'
fireWeapon(p,p.wep,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true); lowMagClick(p);   // v36.xx (cw-lowmag): after the shot, p.ammo is what is left
'@

SubRx @'
var VER='36.93';
'@ @'
var VER='36.94';
'@

$pat = "(?m)^  now:'v36\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.94: Settings, AUDIO has an ALARMS VOLUME row for alarms, warnings and the raid clock, and your last quarter magazine ticks lightly under each shot. Check 36.94 fails on v36.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
