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

# FIRST TEN MINUTES AUDIT, 2026-09-06: on a death or an abandon the outcome
# card prints the run's XP with the drink's dose bonus, then the same
# function clears the drink, then it banks the run through addXp, which
# reads the bonus live and finds none. The card said more than the profile
# got, the exact disagreement v11.63 was written to end.
SubRx @'
function endRaid(how){
  if(G.over) return;
  G.over=how;
'@ @'
function endRaid(how){
  if(G.over) return;
  G.over=how;
  // v12.16: THE BONUS THE CARD PRINTS IS THE BONUS THE RUN BANKS. Taken here,
  // before the death branch below clears the drink; the banking at the bottom
  // of this function ran after that clear and paid the run without it.
  if(G.tel) G.tel.doseMul=buzzXpMul();
'@
SubRx @'
    dur:Math.round(elapsed()),
'@ @'
    doseMul:(T.doseMul>0)?T.doseMul:1,   // v12.16: the dose bonus the card printed, banked below
    dur:Math.round(elapsed()),
'@
SubRx @'
  var _xb=xpBaseFor(rec), _xg=addXp(_xb);
'@ @'
  var _xb=xpBaseFor(rec), _xg=addXp(_xb,(rec.doseMul>0)?rec.doseMul:undefined);   // v12.16: the multiplier the card printed
'@
SubRx @'
function addXp(n){
  n=Math.round(n||0); if(n<=0) return 0;
  var g=Math.round(n*buzzXpMul());
'@ @'
function addXp(n,mul){
  n=Math.round(n||0); if(n<=0) return 0;
  var g=Math.round(n*((mul!==undefined)?mul:buzzXpMul()));   // v12.16: a run banks the bonus its card printed
'@

# STAMPS.
SubRx @'
var VER='12.15';
'@ @'
var VER='12.16';
'@
SubRx @'
var WHATSNEW_VER='12.15';
'@ @'
var WHATSNEW_VER='12.16';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A DEATH BANKS THE XP ITS CARD PRINTS, drink bonus included; it used to pay the run without the bonus after the drink was cleared.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.15:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.15 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.15:[^']*'",{ param($m) "now:'v12.16: from the 2026-09-06 first-ten-minutes audit, a death or an abandon printed the run XP with the drink bonus on the card, cleared the drink, and then banked the run through addXp with no bonus, so the profile got less than the card said. The bonus is taken at the top of the ending and carried on the record into the banking. Check 12.16 dies with two doses in the blood and requires the profile paid exactly what the card printed; fails on v12.15.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
