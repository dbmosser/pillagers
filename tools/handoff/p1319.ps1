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

# HIS REPORT, 2026-09-12: "roll w space bar not working at all", withdrawn ten
# minutes later as a false alarm. It was not a false alarm. It was this.
#
# A ROLL COSTS 45 OF 100 STAMINA. Measured on a live raid: 100, then 55 after one
# roll, then 16 after the second. The third is refused, and the refusal is the
# first line of tryRoll, which returns. No sound, no line, no bar flash, nothing
# at all. The key is dead in the hand and the game does not say why, so a man who
# has just rolled twice concludes the key is broken. He did, and he reported it.
#
# THIS IS HIS OWN RECORDED PATTERN. The crafting note was the same shape: a
# working hold behind a button that answered every wrong gesture with silence.
# The rule that came out of it was "fix the words", and there were no words here.
#
# NO DIAL MOVES. The cost stays 45, the cooldown stays 0.85, the roll is exactly
# as expensive as it was. The only change is that being refused is audible.
#
# RATE LIMITED, because Space is a key people hold. One line and one sound per
# second and a half at most, on the same clock as the other spoken refusals.
SubRx @'
function tryRoll(){
  var p=G.player;
  if(p.downed||p.roll>0||p.rollCd>0||p.stam<ROLLSTAM) return;
'@ @'
function tryRoll(){
  var p=G.player;
  // v13.19, HIS REPORT: a refused roll used to be silent, which is how a key
  // that is working reads as a key that is broken. The other three refusals are
  // states he can see: he knows he is down, he can see the roll happening, and
  // the cooldown is a tenth of a second after one he just watched. Stamina is
  // the one he cannot see the reason for, and it is the one that costs 45 of
  // 100, so the third roll in a row is always the one that dies quietly.
  if(!p.downed&&!(p.roll>0)&&!(p.rollCd>0)&&p.stam<ROLLSTAM){
    G.rollSayT=(G.rollSayT||0);
    if(G.rollSayT<=0){
      G.rollSayT=1.5;
      if(!G.sim){ say('No legs left to roll with.'); blip('clank'); }
    }
    return;
  }
  if(p.downed||p.roll>0||p.rollCd>0||p.stam<ROLLSTAM) return;
'@

SubRx @'
  if(G.punchT>0) G.punchT-=dt;
'@ @'
  if(G.rollSayT>0) G.rollSayT-=dt;   // v13.19: the refused-roll line, once every 1.5s at most
  if(G.punchT>0) G.punchT-=dt;
'@

SubRx @'
var VER='13.18';
'@ @'
var VER='13.19';
'@

$pat = "(?m)^  now:'v13\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.19: HIS REPORT of 2026-09-12, roll with space bar not working at all, which he withdrew ten minutes later as a false alarm. IT WAS NOT A FALSE ALARM, it was this. A roll costs 45 of 100 stamina, measured on a live raid: 100, then 55 after one roll, then 16 after the second, so the third is refused by the first line of tryRoll, which simply returns. No sound, no line, no bar flash, nothing at all, so the key is dead in the hand and the game does not say why, and a man who has just rolled twice concludes the key is broken, which is exactly what he did and reported. THIS IS HIS OWN RECORDED PATTERN: the crafting note was the same shape, a working hold behind a button that answered every wrong gesture with silence, and the rule that came out of it was fix the words, and there were no words here. Of the four things that refuse a roll, three are states he can already see, since he knows he is down, he can see the roll happening, and the cooldown is a tenth of a second after one he just watched; stamina is the one with no visible reason and it is the one that costs 45, so the third roll in a row is always the one that dies quietly. NO DIAL MOVES: the cost stays 45 and the cooldown stays 0.85, the roll is exactly as expensive as it was, and the only change is that being refused is audible. Rate limited to one line and one sound every 1.5 seconds, because Space is a key people hold. Check 13.19 drains the bar on a live raid and requires the refusal to speak, requires a roll that CAN happen to stay silent so the line is not wallpaper, and requires holding the key not to repeat it; the control fails on v13.18, where the refusal says nothing at all',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
