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

# ARCADE: ONE-BUTTON QUICK HEAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ARCADE_CARD_T=4;   // seconds the card stays after the shield drops
'@ @'
// v23.46, HIS YES (2026-10-11) to the five recommendations, arcade23: ONE-BUTTON QUICK HEAL. Belt-then-fire is the heal control a
// walk-up player never finds, so in an arcade raid G on the keyboard (the key as set in CHANGE KEYS) and D-DOWN on the pad heal at
// once through useMedical: the same picker (findHeal), the same wind-up (startPrep), the same refusals and his ruling that a
// Bandage stops at 85 (healCeil) and only a Medkit reaches 100. Only a standing player heals this way; down, G and D-DOWN keep
// their old jobs (the belt words and the self-revive). Outside the arcade G still uses the selected belt item and D-DOWN is unchanged.
function arcadeQuickHeal(){
  var p=G&&G.player;
  if(!G||!G.arcade||G.sim||G.over||G.paused||!p||p.downed||p.dying||p.specOut) return false;
  try{ useMedical(); }catch(_qh){}
  return true;
}
var ARCADE_CARD_T=4;   // seconds the card stays after the shield drops
'@

SubRx @'
    ['RELOAD',kn('KeyR'),padB('X')],['SWITCH GUN','1-4',padB('LB')+' / '+padB('RB')],['HEAL','+ ON THE BELT, THEN FIRE','+ ON THE BELT, THEN FIRE'],
'@ @'
    ['RELOAD',kn('KeyR'),padB('X')],['SWITCH GUN','1-4',padB('LB')+' / '+padB('RB')],['HEAL',kn('KeyG'),padB('D-DOWN')],   // v23.46 (arcade23): the quick heal
'@

SubRx @'
  if(code==='KeyG'&&G&&!G.over&&!G.paused&&!repeat) useHot();
'@ @'
  if(code==='KeyG'&&G&&!G.over&&!G.paused&&!repeat&&!(G.arcade&&typeof arcadeQuickHeal==='function'&&arcadeQuickHeal())) useHot();   // v23.46 (arcade23): in the arcade G is the quick heal
'@

SubRx @'
  PAD.prev[4]=_lbN; PAD.prev[5]=_rbN;
  if(bagNav){
'@ @'
  PAD.prev[4]=_lbN; PAD.prev[5]=_rbN;
  if(G&&G.arcade&&!bagNav&&pressed(13)&&!PAD.prev[13]&&typeof arcadeQuickHeal==='function'){ try{ arcadeQuickHeal(); }catch(_aqh){} }   // v23.46 (arcade23): D-DOWN is the quick heal in the arcade
  if(bagNav){
'@

SubRx @'
var VER='23.45';
'@ @'
var VER='23.46';
'@

$pat = "(?m)^  now:'v23\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.46: In the arcade G on the keyboard and D-DOWN on the controller heal at once with what you carry, and the controls card shows it. Check 23.46 fails on v23.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
