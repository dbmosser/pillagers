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

# the downed bar gives half a second back per hit and shows it; the bleed clock has two decimals (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var DB_ZA=0.40, DB_ZB=0.60, DB_PASS=1.0, DB_STEADY=1.2, DB_LOCK=0.3, DB_RATE=0.5, DB_DRAWS=0;
'@ @'
// cw-downgain, HIS WORDS (2026-10-18): "the active downed system should show you the increase in time when you hit it successfully, e.g. +1 second -- or
// whatever" and "maybe it should give player a half second back, and players clock should include 2 decimals so that it is shown to run down". A HIT now
// gives DB_GAIN (half a second) back to the bleed-out clock at once, in place of the slow bleed above, and a green +0.50s rises over the bar for DB_POP
// seconds while the clock flashes green. ONE HIT A PASS: after a hit the spot turns green and is spent until the slider leaves it, so a burst of clicks
// inside one pass gives one half second (a press in a spent spot does nothing, it is not a miss). The slider crosses the spot once a second, so a hit on
// every pass bleeds at half speed, the same best case as the slow bleed it replaces. The clock under DOWN shows two decimals.
var DB_ZA=0.40, DB_ZB=0.60, DB_PASS=1.0, DB_GAIN=0.5, DB_POP=0.8, DB_LOCK=0.3, DB_DRAWS=0;
'@

SubRx @'
function downBarTick(p,dt){
  var dn=!!mouse.down, press, f;
  if(!G||G.sim||G.over||!p||!p.downed){ if(p&&p.dbOn) p.dbOn=0; return false; }
  if(p.dbOn!==1){ p.dbOn=1; p.dbT=0; p.dbSteady=0; p.dbLock=0; p.dbFlash=0; p.dbPulse=0; p.dbPrev=dn; }   // a trigger already held as he fell is not a press
  p.dbT+=dt;
  if(p.dbLock>0) p.dbLock=Math.max(0,p.dbLock-dt);
  if(p.dbFlash>0) p.dbFlash=Math.max(0,p.dbFlash-dt);
  if(p.dbPulse>0) p.dbPulse=Math.max(0,p.dbPulse-dt);
  press=dn&&!p.dbPrev; p.dbPrev=dn;
  if(!press||p.dbLock>0) return false;
  f=downBarPos(p.dbT);
  if(f<DB_ZA||f>DB_ZB){ p.dbLock=DB_LOCK; p.dbFlash=DB_LOCK; try{ blip('arMiss'); }catch(_dm){} return false; }
  p.dbSteady=DB_STEADY; p.dbPulse=0.25;
  try{ blip('arHit'); }catch(_dh){}
  return true;
}

'@ @'
function downBarTick(p,dt){
  var dn=!!mouse.down, press, f;
  if(!G||G.sim||G.over||!p||!p.downed){ if(p&&p.dbOn) p.dbOn=0; return false; }
  if(p.dbOn!==1){ p.dbOn=1; p.dbT=0; p.dbSpent=0; p.dbLock=0; p.dbFlash=0; p.dbPulse=0; p.dbGain=0; p.dbGainT=0; p.dbPrev=dn; }   // a trigger already held as he fell is not a press
  p.dbT+=dt;
  if(p.dbLock>0) p.dbLock=Math.max(0,p.dbLock-dt);
  if(p.dbFlash>0) p.dbFlash=Math.max(0,p.dbFlash-dt);
  if(p.dbPulse>0) p.dbPulse=Math.max(0,p.dbPulse-dt);
  if(p.dbGainT>0) p.dbGainT=Math.max(0,p.dbGainT-dt);
  f=downBarPos(p.dbT);
  if(f<DB_ZA||f>DB_ZB) p.dbSpent=0;   // cw-downgain: out of the spot, the next pass may score again
  press=dn&&!p.dbPrev; p.dbPrev=dn;
  if(!press||p.dbLock>0) return false;
  if(f<DB_ZA||f>DB_ZB){ p.dbLock=DB_LOCK; p.dbFlash=DB_LOCK; try{ blip('arMiss'); }catch(_dm){} return false; }
  if(p.dbSpent) return false;   // cw-downgain: one hit a pass
  p.dbSpent=1; p.downT+=DB_GAIN; p.dbGain=DB_GAIN; p.dbGainT=DB_POP; p.dbPulse=0.25;
  try{ blip('arHit'); }catch(_dh){}
  return true;
}

'@

SubRx @'
  f=downBarPos(p.dbT); inz=(f>=DB_ZA&&f<=DB_ZB); lk=(p.dbLock>0); st=(p.dbSteady>0);
'@ @'
  f=downBarPos(p.dbT); inz=(f>=DB_ZA&&f<=DB_ZB); lk=(p.dbLock>0); st=!!(p.dbSpent&&inz);   // cw-downgain: st is a spot already scored this pass
'@

SubRx @'
  ctx.fillStyle=lk?'rgba(150,40,32,.60)':(inz?'rgb(255,150,138)':'rgb(232,58,44)');
  if(inz&&!lk){ ctx.shadowColor='rgba(255,90,70,.95)'; ctx.shadowBlur=9; }
'@ @'
  ctx.fillStyle=lk?'rgba(150,40,32,.60)':(st?'rgb(110,196,132)':(inz?'rgb(255,150,138)':'rgb(232,58,44)'));
  if(inz&&!lk){ ctx.shadowColor=st?'rgba(110,220,140,.9)':'rgba(255,90,70,.95)'; ctx.shadowBlur=9; }
'@

SubRx @'
  if(st){ ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#9fe8b0'; ctx.fillText('STEADY',cx,y0-10); }
'@ @'
  if(p.dbGainT>0){   // cw-downgain: the time a hit gave back rises over the bar and fades
    var _gk=p.dbGainT/DB_POP; ctx.font=FS(TYPE.head); ctx.textAlign='center'; ctx.globalAlpha=Math.min(1,_gk*2); ctx.fillStyle='#9fe8b0';
    ctx.fillText('+'+(+p.dbGain||0).toFixed(2)+'s',cx,Math.round(y0-10-(1-_gk)*14)); ctx.globalAlpha=1;
  }
'@

SubRx @'
  var _ds=(p.dbSteady>0)?Math.min(dt,p.dbSteady):0;   // v28.xx (downbar1): the slice of this step that is a slow bleed
  if(_ds>0) p.dbSteady-=_ds;
  p.downT-=(dt-_ds)+_ds*DB_RATE;
'@ @'
  p.downT-=dt;   // cw-downgain: a hit on the downed bar gives time back at once (downBarTick); there is no slow bleed any more
'@

SubRx @'
    ctx.font=_fD; ctx.fillStyle='#ffb0a0';
    ctx.fillText(Math.max(0,Math.ceil(p.downT))+'s',W/2+130,_barY+9);
'@ @'
    // cw-downgain, HIS WORDS (2026-10-18): "players clock should include 2 decimals so that it is shown to run down". Left aligned so the digits do not
    // push into the bar as they change, and green while a hit's +0.50s shows.
    ctx.font=_fD; ctx.fillStyle=(p.dbGainT>DB_POP*0.5)?'#9fe8b0':'#ffb0a0'; ctx.textAlign='left';
    ctx.fillText(Math.max(0,p.downT).toFixed(2)+'s',W/2+110,_barY+9); ctx.textAlign='center';
'@

SubRx @'
  if(p.dbOn){ p.dbOn=0; p.dbSteady=0; p.dbLock=0; }
'@ @'
  if(p.dbOn){ p.dbOn=0; p.dbSpent=0; p.dbLock=0; p.dbGainT=0; }
'@

SubRx @'
var VER='30.90';
'@ @'
var VER='30.91';
'@

$pat = "(?m)^  now:'v30\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.91: Downed: a good hit on the bar gives half a second back and shows +0.50s. The bleed clock counts down in hundredths. Check 30.91 fails on v30.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
