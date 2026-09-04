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

# ============ HIS NOTE, 2026-09-03 about 21:32: "its not clear to me how to
# ============ melee or if i can at all".
# ============
# ============ Measured on v10.63 before writing anything. With a rifle in his
# ============ hand and a crawler at arm's length, ten keys were pressed one at a
# ============ time (F, T, Y, U, J, K, L, N, R and V) and not one of them touched
# ============ it. The only way to strike anything was to equip Bare Hands and
# ============ pull the trigger. And the word MELEE appears on screen in exactly
# ============ two places, both of them the ammo counter saying your hands are
# ============ empty; no controls list, full or short, named a key for it. So the
# ============ answer to his question was: barely, and nothing tells you.
# ============
# ============ F strikes now, with whatever you are holding, and the controls say
# ============ so. The swing itself is the one the game already had, the Bare
# ============ Hands attack, so its damage, its arc, its backstab bonus, its
# ============ noise and its sound are the ones that were already measured.

# 1. The strike.
SubRx @'
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@ @'
// v10.64, his note: "its not clear to me how to melee or if i can at all".
// A strike with whatever is in your hands, on its own cooldown, using the swing
// the game already has: Bare Hands, which is why the damage, the arc, the
// backstab bonus, the noise and the sound need no second copy here.
function meleeStrike(){
  if(!G||G.over||G.paused||G.sim||G.trade) return false;
  var p=G.player;
  if(!p||p.downed||p.roll>0||G.searching) return false;
  var gap=(WEAPONS.fists.rof||420)/1000;
  if(p.meleeAt!==undefined&&(G.t-p.meleeAt)<gap) return false;
  p.meleeAt=G.t;
  G.punchT=0.22;                      // the thrust the fists attack draws
  // G.tel, not a bare T: T is a local alias for it inside the functions that
  // use it, and a bare one here threw before the swing ever ran. The dry run
  // caught that: the punch played and nothing was hit.
  if(G.tel) G.tel.melee=(G.tel.melee||0)+1;
  fireWeapon(p,WEAPONS.fists,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true);
  return true;
}
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@

# 2. The key.
SubRx @'
  if(code==='KeyX'&&G&&!G.over&&!G.paused&&!repeat) swapGuns();
'@ @'
  if(code==='KeyX'&&G&&!G.over&&!G.paused&&!repeat) swapGuns();
  if(code==='KeyF'&&G&&!G.over&&!G.paused&&!repeat) meleeStrike();   // v10.64, his note
'@

# 3. The controls say so, in both lists, or it is the same invisible feature
#    with a key attached.
SubRx @'
  ['FIGHT',[['MOUSE','aim'],['LMB','fire'],['RMB','aim down sights'],['R','reload'],['X','swap weapon']]],
'@ @'
  ['FIGHT',[['MOUSE','aim'],['LMB','fire'],['RMB','aim down sights'],['R','reload'],['X','swap weapon'],['F','melee strike, whatever you are holding']]],
'@
SubRx @'
  ['R','reload'],['X','swap gun'],
'@ @'
  ['R','reload'],['X','swap gun'],
  ['F','melee'],
'@
SubRx @'
// The twelve keys a player actually presses, two columns, no headings. Anything
'@ @'
// The thirteen keys a player actually presses, two columns, no headings. Anything
'@

SubRx @'
var VER='10.63';
'@ @'
var VER='10.64';
'@
SubRx @'
  now:'v10.63: a Howler standing outside cannot bomb you inside a house. Its shell bursts on the roof and nobody under that roof is touched, though you will hear it land. A Howler that has come inside with you is still dangerous.',
'@ @'
  now:'v10.64: F strikes. You can melee with whatever you are holding instead of only with empty hands, and the controls list says so, in the short list and the full one.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
