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

# ============ HIS NOTE, 2026-09-03 about 21:50: "undercroft music needs to be
# ============ darker and gloomier, feels too happy". v9.87 took the register
# ============ down an octave and closed the filter to 1500 on his earlier note,
# ============ and it is still too happy, because register was only part of it.
# ============ What is left that reads as cheerful: the tune is a SQUARE wave,
# ============ which is the brightest thing in the mix and the sound of a toy;
# ============ the arpeggio rolls on every eighth, and a steady shimmer is
# ============ cheerful whatever notes it plays; and the room walks along at a
# ============ hundred beats a minute.
# ============
# ============ So: the tune is a triangle with the square left underneath it as a
# ============ shadow at a third of its old level, the room slows to seventy-six
# ============ a minute, the filter closes from 1500 to 900, the shimmer halves
# ============ to one note a quarter and drops to two thirds of its level, and
# ============ the bass under it all is held nearly twice as long so the room
# ============ hums instead of ticking.

# 1. Slower: a sixteenth every 0.197 s is 76 a minute, against 0.15 for 100.
SubRx @'
function musStepSec(T){
  var s=T.spb;
  if(CFG.musDark!==0&&s<0.15) s=0.15;
  return s;
}
'@ @'
function musStepSec(T){
  var s=T.spb;
  // v10.61, his note: 100 a minute is a walking pace and he called it happy.
  // 76 is the slowest a sixteenth can go here before the tune stops joining up.
  if(CFG.musDark!==0&&s<0.197) s=0.197;
  return s;
}
'@

# 2. Darker: the corner comes down from 1500 to 900.
SubRx @'
function musLpHz(){ return (CFG.musDark===0)?3200:1500; }
'@ @'
function musLpHz(){ return (CFG.musDark===0)?3200:900; }   // v10.61, his note: 1500 was still bright
'@

# 3. The bass is held nearly twice as long, so the floor of the room hums.
SubRx @'
  if(si===0) musVoice(a,t,bb,'triangle',0.34,1.9,0.02);
  else if(si===8) musVoice(a,t,bb,'triangle',0.22,1.5,0.02);
'@ @'
  // v10.61: held long enough to run into the next chord, which is what makes a
  // room hum rather than tick.
  if(si===0) musVoice(a,t,bb,'triangle',0.34,dk?3.4:1.9,dk?0.06:0.02);
  else if(si===8) musVoice(a,t,bb,'triangle',0.22,dk?2.6:1.5,dk?0.06:0.02);
'@

# 4. The shimmer halves: one note a quarter instead of one an eighth, quieter.
SubRx @'
  if((si&1)===0){
    var an=ch[((si>>1)+bi)%3];
    if(!dk&&((si>>1)&3)===0) an+=12;         // lift the top of each group an octave
    if(dk) an-=12;
    musVoice(a,t,an,'triangle',dk?0.06:0.085,0.46,0.012);
  }
'@ @'
  // v10.61, his note: a steady shimmer on every eighth is cheerful whatever it
  // plays. Half as often and two thirds as loud, so it reads as a drip rather
  // than a sparkle.
  if(dk?((si&3)===0):((si&1)===0)){
    var an=ch[((si>>1)+bi)%3];
    if(!dk&&((si>>1)&3)===0) an+=12;         // lift the top of each group an octave
    if(dk) an-=12;
    musVoice(a,t,an,'triangle',dk?0.04:0.085,dk?0.62:0.46,dk?0.05:0.012);
  }
'@

# 5. The tune is a triangle, with the square left under it as a shadow.
SubRx @'
  if(dk) m-=12;
  musVoice(a,t,m,'square',0.105,1.05,0.045);
  musVoice(a,t+0.022,m,'triangle',0.075,1.05,0.05,1.004);
'@ @'
  if(dk) m-=12;
  // v10.61, his note: the square was the brightest thing in the room and the
  // reason it sounded like a toy. The triangle carries the tune now and the
  // square sits under it at a third of its old level, so the edge is still
  // there and nothing is leading with it.
  musVoice(a,t,m,'square',dk?0.035:0.105,1.05,dk?0.09:0.045);
  musVoice(a,t+0.022,m,'triangle',dk?0.115:0.075,dk?1.5:1.05,dk?0.08:0.05,1.004);
'@

SubRx @'
var VER='10.60';
'@ @'
var VER='10.61';
'@
SubRx @'
  now:'v10.60: walls are solid again. Nothing goes see-through when you stand behind it, and in the Undercroft nobody can stand inside the part of a wall that is painted, which is what was catching the people down there on the counters and the piers.',
'@ @'
  now:'v10.61: the Undercroft is darker and gloomier. The tune is no longer led by the bright square wave that made it sound like a toy, the room has slowed from a hundred beats a minute to seventy-six, the filter is closed further, the shimmer plays half as often, and the bass is held long enough to hum.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
