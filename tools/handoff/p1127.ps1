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

# F DID TWO THINGS. v10.64 made F the melee strike on the keydown path and left
# the older held-F heal in updatePlayer, so one press swung a punch and burned
# a Bandage. Heals are used from the tactical belt (select the slot, FIRE, or
# G) since v8.72, and the downed self-revive on F is a different state and
# stays. The held-F heal goes.
SubRx @'
  if(keys['KeyF']&&!p.healLock){ p.healLock=true; useMedical(); }
  if(!keys['KeyF']) p.healLock=false;
'@ @'
  // v11.27: the held-F heal is gone. F is the melee strike (v10.64) and a
  // heal is used from the tactical belt; with both bound, one press punched
  // AND burned the smallest heal in the backpack. healLock is still cleared
  // here so the downed self-revive on F keeps its edge trigger.
  if(!keys['KeyF']) p.healLock=false;
'@

# STAMPS.
SubRx @'
var VER='11.26';
'@ @'
var VER='11.27';
'@
SubRx @'
var WHATSNEW_VER='11.26';
'@ @'
var WHATSNEW_VER='11.27';
'@
SubRx @'
  'THE PAUSE SCREEN KEY LIST IS RIGHT AGAIN. It printed a stray "&nbsp;" between every key and still said F heals, TAB opens the bag and Q throws. It now matches the controls list under H: F is your melee strike, TAB is the backpack, 1 to 9 is the tactical belt.',
'@ @'
  'F NO LONGER BURNS A BANDAGE WHEN YOU PUNCH. Since F became the melee strike, a press while hurt also used the smallest heal in your backpack, silently. Heals are used from the tactical belt, and F now only strikes (and still revives you when you are down).',
  'THE PAUSE SCREEN KEY LIST IS RIGHT AGAIN. It printed a stray "&nbsp;" between every key and still said F heals, TAB opens the bag and Q throws. It now matches the controls list under H: F is your melee strike, TAB is the backpack, 1 to 9 is the tactical belt.',
'@
SubRx @'
  now:'v11.26: the pause screen key line, found by a read-only audit of the HUD code and confirmed in the page: the non-breaking space entity was double-escaped, so the box printed the literal six characters fourteen times, and the line still said F heal, Q/G throw and TAB bag from before v10.64. It now mirrors the LEGEND table. A check reads the box and forbids the literal and the three stale phrases.',
'@ @'
  now:'v11.27: F did two things. v10.64 bound the melee strike to the F keydown and left the older held-F heal in the player update, so one press while hurt swung a punch and burned the smallest heal in the backpack, with "Applying Bandage..." on screen. Reproduced: melee 1, bandage gone, one press. The held-F heal is removed; heals are used from the tactical belt; the downed self-revive on F stays. Check: F strikes and the backpack keeps its bandage, the belt still spends it, down and F still revives.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
