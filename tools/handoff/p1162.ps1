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

# THE OUTCOME CARD PRINTED BASE XP; THE PROFILE WAS CREDITED BASE x NIGHT x
# WEATHER x DOSE. The card built its own record without the night and wxHard
# flags and printed spForRun+xpForRun raw, while commitRun, a moment later, ran
# addProgress (round(base x night x weather)) and addXp (round(that x dose)). A
# night run said +100 and banked 120, and the "XP in all" and "XP away" figures
# on the same line were wrong with it. One helper now owns the night and weather
# arithmetic, the bank uses it, and the card prints exactly what will be banked.
SubRx @'
function addProgress(rec){
'@ @'
// v11.62: the one place the night and weather multipliers are applied to a run's
// base XP. addProgress banks it; the outcome card prints it (times the dose
// multiplier addXp applies), so the two can never disagree again.
function xpBaseFor(rec){
  return Math.round((spForRun(rec)+xpForRun(rec))*(rec.night?nightXpMul():1)*(rec.wxHard?wxXpMul():1));
}
function addProgress(rec){
'@

SubRx @'
  var _xb=Math.round((spForRun(rec)+xpForRun(rec))*(rec.night?nightXpMul():1)*(rec.wxHard?wxXpMul():1)), _xg=addXp(_xb);
'@ @'
  var _xb=xpBaseFor(rec), _xg=addXp(_xb);
'@

SubRx @'
    var _grec={outcome:how,haul:haul,containers:T.containers,kills:T.kills,termPay:tPay,
      doorsOpened:T.doorsOpened||0,caches:T.cachesOpened||0,dist:T.distance||0};
    var gained=spForRun(_grec)+xpForRun(_grec);
'@ @'
    var _grec={outcome:how,haul:haul,containers:T.containers,kills:T.kills,termPay:tPay,
      doorsOpened:T.doorsOpened||0,caches:T.cachesOpened||0,dist:T.distance||0,
      // v11.62: the same two flags the banked record carries, so the card prints
      // what addProgress and addXp will actually credit: night, weather and dose.
      night:(typeof isDay==='function'&&!isDay())?1:0,
      wxHard:(typeof wxHardId==='function')?wxHardId((G.wx&&G.wx.id)||'clear'):0};
    var gained=Math.round(xpBaseFor(_grec)*buzzXpMul());
'@

# STAMPS.
SubRx @'
var VER='11.61';
'@ @'
var VER='11.62';
'@
SubRx @'
var WHATSNEW_VER='11.61';
'@ @'
var WHATSNEW_VER='11.62';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE XP ON THE OUTCOME CARD IS THE XP YOU GET. A night run, hard weather or a dose in your blood pays more, and the game banked that bonus but the card printed the plain figure, so the XP line, the total and the distance to the next reward were all off. The card now prints exactly what is banked.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.61:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.61 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.61:[^']*'",{ param($m) "now:'v11.62: the outcome card printed base XP while the profile was credited base x night x weather x dose. The card built its own record without the night and wxHard flags and printed the raw sum, while commitRun ran addProgress (round of base x night x weather) and addXp (round of that x dose); a night run said +100 and banked 120, and the total and the distance to the next reward were wrong with it. One helper, xpBaseFor, now owns the night and weather arithmetic, the bank uses it, and the card prints the same figure times the dose multiplier. From the v11.46 audit, P1, raised by two regions.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
