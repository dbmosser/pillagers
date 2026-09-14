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

# COMBAT AND PLAYER STATE AUDIT OF 2026-09-14, finding 2: A DEAD PLAYER COULD STILL ACT DURING THE
# DEATH FADE. killPlayer clears downed and sets dying with a 1.5 second beat before endRaid, but
# every input handler asks only whether the raid is over, and the action verbs refuse only when
# downed. So in the red fade: a number key equipped a gun from the backpack over the armoury gun
# in hand, which went back to the armoury and so survived a death that should have taken it; F
# punched, and a kill it landed was credited and banked; G spent belt items; Space rolled. Every
# one of those verbs now refuses while dying.
SubRx @'
  if(p.downed||p.roll>0||p.rollCd>0||p.stam<ROLLSTAM) return;
'@ @'
  if(p.dying||p.downed||p.roll>0||p.rollCd>0||p.stam<ROLLSTAM) return;   // v13.80: not in the death fade
'@
SubRx @'
  if(!p||p.downed||p.roll>0||G.searching) return false;
'@ @'
  if(!p||p.downed||p.dying||p.roll>0||G.searching) return false;   // v13.80: not in the death fade
'@
SubRx @'
  if(!pp||!pp.sec||pp.downed||pp.roll>0||G.over||G.paused) return false;
'@ @'
  if(!pp||!pp.sec||pp.downed||pp.dying||pp.roll>0||G.over||G.paused) return false;   // v13.80
'@
SubRx @'
function equipFromBag(ix,slot){
  var p=G&&G.player;
  if(!p||p.downed||p.roll>0||G.over||G.paused) return false;
'@ @'
function equipFromBag(ix,slot){
  var p=G&&G.player;
  if(!p||p.downed||p.dying||p.roll>0||G.over||G.paused) return false;   // v13.80: a gun equipped in the death fade survived the death
'@
SubRx @'
  var p=G&&G.player; if(!p||p.downed||G.over) return false;
'@ @'
  var p=G&&G.player; if(!p||p.downed||p.dying||G.over) return false;   // v13.80
'@
SubRx @'
  if(G&&G.player&&G.player.downed){ if(!G.sim) say('Not while you are down.'); return; }
'@ @'
  if(G&&G.player&&G.player.downed){ if(!G.sim) say('Not while you are down.'); return; }
  if(G&&G.player&&G.player.dying) return;   // v13.80, combat audit: nor in the death fade
'@
SubRx @'
var VER='13.79';
'@ @'
var VER='13.80';
'@

$pat = "(?m)^  now:'v13\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.80: THE DEAD DO NOTHING IN THE DEATH FADE. Combat and player state audit of 2026-09-14, finding 2: killPlayer clears downed and sets dying for a 1.5 second beat, but the inputs ask only whether the raid is over and the verbs refuse only when downed, so in the fade a number key equipped a backpack gun over the armoury gun in hand, which went back to the armoury and survived the death, F punched with kills credited, G spent belt items and Space rolled. tryRoll, meleeStrike, swapGuns, equipFromBag, bagHeldGun and useHot now refuse while dying. Check 13.80 kills the player and presses the belt key of a backpack gun in the fade, requiring the armoury rifle lost at the death, with no key press as the control, and a punch in the fade refused; it fails on v13.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
