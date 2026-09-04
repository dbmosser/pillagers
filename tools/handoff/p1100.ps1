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

# ============ HIS NOTE 16: WEATHER IS A CHOICE, AND THE HARD ONES PAY MORE.
# ============
# ============ "add weather conditions as a selection toggle in the 'Where are
# ============ you going' screen", then, the same day: "choose more difficult
# ============ weather shouild hive small xp boost like 1.1x". 2026-09-04.
# ============
# ============ REPRODUCED: the sector page has SURFACE with DAY and NIGHT, added
# ============ at v9.97 on his note, and nothing at all for weather. The weather
# ============ is one seeded roll at the drop and he has never had a say in it.
# ============
# ============ THE ONE THING THAT COULD HAVE GONE WRONG, and would have been
# ============ invisible: pickWeather draws from the SEEDED stream, so an
# ============ implementation that skips the roll when a weather is pinned moves
# ============ every roll after it, and the map, the loot and the bodies all
# ============ change. The roll ALWAYS happens. Pinning replaces the answer, never
# ============ the draw, and the two map fingerprints prove it.
# ============
# ============ WHICH ONES PAY THE BONUS is derived, not listed: a weather is HARD
# ============ if it cuts sight or kills the lamps, which is view below 1 or
# ============ lights below 1. That is rain, fog, blackout and storm today, and a
# ============ weather added later is priced by what it does rather than by
# ============ whether I remembered to add it to a list. His 1.1x sits on the dial
# ============ wxXp beside his nightXp 1.2, and both apply, so a hard night pays
# ============ 1.32x.

# ---- 1. the control, in the same shape as his SURFACE row
SubRx @'
    <span id="condhint" style="font-size:11px;color:var(--ash)"></span>
  </div>
'@ @'
    <span id="condhint" style="font-size:11px;color:var(--ash)"></span>
  </div>
  <!-- v11.00, HIS NOTE 16: and the weather, chosen the same way, on the same
       page, at the same moment. SURPRISE ME is the old behaviour and stays the
       default; Partly Cloudy is only reachable through it, because it is the one
       state that exists to TURN into another. -->
  <div id="sectorwx" style="display:flex;align-items:center;gap:8px;margin-top:9px;flex-wrap:wrap">
    <span style="font-size:11px;letter-spacing:.14em;color:var(--ash)">WEATHER</span>
    <button class="deploy ghost wxb" data-wx="any" style="flex:0 0 auto;padding:7px 14px">SURPRISE ME</button>
    <button class="deploy ghost wxb" data-wx="clear" style="flex:0 0 auto;padding:7px 14px">CLEAR</button>
    <button class="deploy ghost wxb" data-wx="rain" style="flex:0 0 auto;padding:7px 14px">RAIN</button>
    <button class="deploy ghost wxb" data-wx="fog" style="flex:0 0 auto;padding:7px 14px">FOG</button>
    <button class="deploy ghost wxb" data-wx="blackout" style="flex:0 0 auto;padding:7px 14px">BLACKOUT</button>
    <button class="deploy ghost wxb" data-wx="storm" style="flex:0 0 auto;padding:7px 14px">STORM</button>
    <span id="wxhint" style="font-size:11px;color:var(--ash)"></span>
  </div>
'@

# ---- 2. what he picked, and the bonus, both derived from the weather table
SubRx @'
function pickWeather(){
  var id=rollTable([['clear',26],['partly',16],['rain',20],['fog',16],['blackout',10],['storm',12]]);
  for(var i=0;i<WEATHER.length;i++) if(WEATHER[i].id===id) return WEATHER[i];
  return WEATHER[0];
}
'@ @'
// v11.00, HIS NOTE 16: he picks the weather on the way up, or leaves it to the
// roll. THE ROLL ALWAYS HAPPENS: it is one draw from the SEEDED stream, and
// skipping it when a weather is pinned would move every roll after it, changing
// the map, the loot and the bodies. Pinning replaces the answer, never the draw.
function wxPicked(){ var v=(typeof P!=='undefined'&&P&&P.wxPick)||'any'; return v; }
function pickWeather(){
  var id=rollTable([['clear',26],['partly',16],['rain',20],['fog',16],['blackout',10],['storm',12]]);
  var want=wxPicked(), i;
  if(want&&want!=='any') for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===want) return WEATHER[i];
  for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===id) return WEATHER[i];
  return WEATHER[0];
}
// HIS 1.1x. A weather is HARD if it cuts sight or kills the lamps, asked of the
// weather table rather than kept as a list beside it, so a state added later is
// priced by what it does.
function wxHardId(id){
  for(var i=0;i<WEATHER.length;i++) if(WEATHER[i].id===id)
    return ((WEATHER[i].view!==undefined&&WEATHER[i].view<1)||(WEATHER[i].lights!==undefined&&WEATHER[i].lights<1))?1:0;
  return 0;
}
function wxXpMul(){ return (CFG.wxXp===undefined)?1.1:CFG.wxXp; }
'@

# ---- 3. the dial, beside his night one
SubRx @'
buzzXp:0.025,nightXp:1.2,
'@ @'
buzzXp:0.025,nightXp:1.2,wxXp:1.1,
'@

# ---- 4. the record knows what it went up in
SubRx @'
    night:(typeof isDay==='function'&&!isDay())?1:0,   // v10.06, his answer 22: the record knows it went up in the dark
'@ @'
    night:(typeof isDay==='function'&&!isDay())?1:0,   // v10.06, his answer 22: the record knows it went up in the dark
    wxHard:(typeof wxHardId==='function')?wxHardId((G.wx&&G.wx.id)||'clear'):0,   // v11.00, his note 16
'@

# ---- 5. and it pays
SubRx @'
  var _xb=Math.round((spForRun(rec)+xpForRun(rec))*(rec.night?nightXpMul():1)), _xg=addXp(_xb);
'@ @'
  // v11.00, his note 16: hard weather pays too, and both apply, so a hard night
  // is 1.2 times 1.1.
  var _xb=Math.round((spForRun(rec)+xpForRun(rec))*(rec.night?nightXpMul():1)*(rec.wxHard?wxXpMul():1)), _xg=addXp(_xb);
'@

# ---- 6. the page shows which one is chosen, the way his day and night do
SubRx @'
(function(){
  var bs=[document.getElementById('condday'),document.getElementById('condnight')];
'@ @'
// v11.00, HIS NOTE 16: the chosen weather is drawn amber like the chosen map and
// the chosen surface, so the page reads as three choices of one shape.
function syncSectorWx(){
  var host=document.getElementById('sectorwx'); if(!host) return;
  var want=wxPicked(), bs=host.querySelectorAll('.wxb'), i, hard=0, nm='';
  for(i=0;i<bs.length;i++){
    var on=(bs[i].getAttribute('data-wx')===want);
    bs[i].style.borderColor=on?'var(--amber)':'';
    bs[i].style.color=on?'var(--amber)':'';
    bs[i].style.background=on?'rgba(255,192,74,.10)':'';
  }
  var hint=document.getElementById('wxhint'); if(!hint) return;
  if(want==='any'){ hint.textContent='Whatever the surface gives you.'; return; }
  for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===want){ nm=WEATHER[i].name; hard=wxHardId(want); }
  hint.textContent=nm+(hard?('. Harder going, so XP pays '+(Math.round(wxXpMul()*100)/100)+'x.'):'. No bonus for an easy sky.');
}
(function(){
  var wb=document.querySelectorAll('#sectorwx .wxb');
  for(var i=0;i<wb.length;i++) wb[i].onclick=function(){
    P.wxPick=this.getAttribute('data-wx')||'any';
    saveProfile(); syncSectorWx();
  };
})();
(function(){
  var bs=[document.getElementById('condday'),document.getElementById('condnight')];
'@
SubRx @'
    P.cond=(this.getAttribute('data-cond')==='night')?'night':'day';
    saveProfile(); syncSectorCond();
'@ @'
    P.cond=(this.getAttribute('data-cond')==='night')?'night':'day';
    saveProfile(); syncSectorCond(); try{ syncSectorWx(); }catch(_sw){}
'@
SubRx @'
  if(hint) hint.textContent=day?'You go up in daylight.':('You go up in the dark. XP pays '+(Math.round(nightXpMul()*100)/100)+'x.');
}
'@ @'
  if(hint) hint.textContent=day?'You go up in daylight.':('You go up in the dark. XP pays '+(Math.round(nightXpMul()*100)/100)+'x.');
  try{ syncSectorWx(); }catch(_sw2){}
}
'@

SubRx @'
var VER='10.99';
'@ @'
var VER='11.00';
'@
SubRx @'
  now:'v10.99: no pillager has ever worn a hat, a beard or a tattoo. Measured: the same rack changes your operator by 31,978 pixels and a pillager by zero, because the block that draws them sits inside a hero-only branch along with your fringe. The crowd rolls all three for every member and none were drawn. The branch closes after the fringe now, which is the one thing in there that is actually yours.',
'@ @'
  now:'v11.00: weather is a choice on the sector page, your note, and the hard ones pay your 1.1x. SURPRISE ME is the old roll and stays the default. Rain, fog, blackout and storm pay the bonus because they cut sight or kill the lamps, asked of the weather table rather than kept as a list. It stacks with night, so a hard night pays 1.32x. The seeded roll still happens whatever you pick, or the map itself would change.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'YOU CHOOSE THE WEATHER NOW, on the same page as the map and the surface. SURPRISE ME leaves it to the roll, which is what it always was. RAIN, FOG, BLACKOUT and STORM pay 1.1x XP because they cut your sight or kill the lamps, and that stacks with the night bonus, so a hard night pays 1.32x.',
'@
SubRx @'
var WHATSNEW_VER='10.99';
'@ @'
var WHATSNEW_VER='11.00';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
