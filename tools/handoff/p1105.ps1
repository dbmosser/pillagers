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

# ============ HIS QUESTION, AND IT FINDS A DEFECT IN MY OWN v11.00.
# ============
# ============ "is a daytime blsackout meaningfully harder than normal daytime
# ============ play?", 2026-09-04.
# ============
# ============ THE ANSWER IS NO, AND AT TWO TIMES OF DAY IT IS LITERALLY NOTHING.
# ============ Lamp brightness is wx().lights * (isDay() ? tod().lights : 1), and
# ============ the times of day carry lights of 0.7 at dawn, ZERO at 8am, ZERO at
# ============ noon, 0.25 at 6pm and 1 at dusk. Blackout multiplies by 0.18. At
# ============ 8am and noon that is zero times 0.18: the lamps a blackout kills
# ============ were already off.
# ============
# ============ AND LAMP BRIGHTNESS FEEDS TWO THINGS IN THE WHOLE FILE: the "lit"
# ============ percentage in the flight recorder, and the glow the lamps draw.
# ============ Nothing in vision, concealment or machine AI reads it. So a
# ============ blackout is what a human can SEE, which is real difficulty for a
# ============ person and none at all for the bot.
# ============
# ============ WHAT THAT MAKES WRONG: v11.00, four builds ago, mine. It classed a
# ============ weather as hard if it cuts sight OR kills the lamps, and paid his
# ============ 1.1x for it. In daylight that pays a bonus for killing lamps that
# ============ were already dark.
# ============
# ============ THE FIX: killing the lamps only counts when the lamps were ON. The
# ============ rule asks how much light is actually lost, and wants a real amount
# ============ of it, so a blackout pays at night and at dusk and dawn and pays
# ============ nothing at 8am and noon. Cutting SIGHT, which is rain, fog and
# ============ storm, is unchanged: that is the weather itself and does not care
# ============ what time it is.
SubRx @'
function wxHardId(id){
  for(var i=0;i<WEATHER.length;i++) if(WEATHER[i].id===id)
    return ((WEATHER[i].view!==undefined&&WEATHER[i].view<1)||(WEATHER[i].lights!==undefined&&WEATHER[i].lights<1))?1:0;
  return 0;
}
'@ @'
// v11.05, HIS QUESTION: how much lamp light there is BEFORE the weather touches
// it. In daylight that is the time of day, which is zero at 8am and noon; at
// night the lamps are the light.
function lampBase(day,tdo){
  var d=(day===undefined)?((typeof isDay==='function')?isDay():true):!!day;
  if(!d) return 1;
  var t=tdo||((typeof tod==='function')?tod():null);
  return (t&&t.lights!==undefined)?t.lights:1;
}
// A weather is HARD if it cuts what he can see. Two ways to do that, and they are
// not the same: the weather itself can cut sight, which is true whatever the
// hour, or it can kill the lamps, which is only worth anything when the lamps
// were on. A quarter of the light has to actually go for it to count.
function wxHardId(id,day,tdo){
  for(var i=0;i<WEATHER.length;i++) if(WEATHER[i].id===id){
    var W=WEATHER[i];
    if(W.view!==undefined&&W.view<1) return 1;
    if(W.lights!==undefined&&W.lights<1){
      var base=lampBase(day,tdo);
      return ((base-base*W.lights)>=0.15)?1:0;
    }
    return 0;
  }
  return 0;
}
'@

# ---- the sector page tells the truth about it rather than promising a bonus
SubRx @'
  hint.textContent=nm+(hard?('. Harder going, so XP pays '+(Math.round(wxXpMul()*100)/100)+'x.'):'. No bonus for an easy sky.');
'@ @'
  // v11.05, HIS QUESTION: a blackout is only harder if the lamps were on, and in
  // daylight whether they are depends on an hour that is rolled at the drop. Say
  // that, rather than promising a bonus that will not arrive.
  var lampsOnly=(function(){ for(var q=0;q<WEATHER.length;q++) if(WEATHER[q].id===want)
      return !(WEATHER[q].view!==undefined&&WEATHER[q].view<1)&&(WEATHER[q].lights!==undefined&&WEATHER[q].lights<1);
    return false; })();
  var payLine='. Harder going, so XP pays '+(Math.round(wxXpMul()*100)/100)+'x.';
  if(lampsOnly){
    hint.textContent=nm+(isDay()
      ? '. Only harder if the lamps were on, and in daylight that depends on the hour you land at.'
      : payLine);
    return;
  }
  hint.textContent=nm+(hard?payLine:'. No bonus for an easy sky.');
'@

SubRx @'
var VER='11.04';
'@ @'
var VER='11.05';
'@
SubRx @'
  now:'v11.04: the other end of the restore code, your note 14. Settings, the recorder tab, under the report: paste a code, press READ CODE and it tells you whose character it is and what it is worth, then type the word restore and press REPLACE. Nothing is written before the word. It does not bring back the run log, because the log is history and is not in the code.',
'@ @'
  now:'v11.05: your question about a daytime blackout, and the answer is no. Lamp brightness is the weather times the time of day, and the time of day is ZERO at 8am and noon, so a blackout there kills lamps that were already off. That makes my v11.00 wrong: it paid your 1.1x for killing the lamps whatever the hour. Killing the lamps only counts now when a real amount of light actually goes. Cutting sight, which is rain, fog and storm, is unchanged.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A DAYTIME BLACKOUT IS NOT HARDER, so it no longer pays as if it were. The lamps are already off at 8am and noon, and a blackout multiplying zero is still zero. It pays at night, at dusk and at dawn, when there is light to lose. Rain, fog and storm cut your sight whatever the hour and are unchanged.',
'@
SubRx @'
var WHATSNEW_VER='11.04';
'@ @'
var WHATSNEW_VER='11.05';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
