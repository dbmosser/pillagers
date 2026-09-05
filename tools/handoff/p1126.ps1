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

# THE PAUSE SCREEN'S KEY LINE. The entity was written double-escaped, so the
# box printed the six characters of the entity fourteen times, and the line
# had not been touched since F became melee (v10.64), sprint became a hold
# (v10.87), the backpack got its name and the throw keys moved. It now says
# what LEGEND says, which is what the H list says, and nothing else.
SubRx @'
  <div style="font-size:13.5px;color:var(--ash);letter-spacing:.08em;text-align:center;line-height:1.8;max-width:730px">MOUSE aim &amp;nbsp; LMB fire &amp;nbsp; RMB aim down sights &amp;nbsp; WASD move &amp;nbsp; SPACE dodge roll &amp;nbsp; SHIFT sprint on/off &amp;nbsp; CTRL / C crouch toggle<br>E interact &amp;nbsp; R reload &amp;nbsp; F heal/revive &amp;nbsp; Q/G throw &amp;nbsp; TAB bag &amp;nbsp; M map &amp;nbsp; ` superhot mode &amp;nbsp; SHIFT-` tuning sliders &amp;nbsp; P/ESC pause</div>
'@ @'
  <div id="pausekeys" style="font-size:13.5px;color:var(--ash);letter-spacing:.08em;text-align:center;line-height:1.8;max-width:730px">MOUSE aim &nbsp; LMB fire &nbsp; RMB aim down sights &nbsp; WASD move &nbsp; SPACE dodge roll &nbsp; SHIFT hold to sprint &nbsp; CTRL / C crouch on/off<br>E search / call for extraction &nbsp; R reload &nbsp; F melee strike &nbsp; 1-9 tactical belt &nbsp; TAB backpack &nbsp; ENTER equip from backpack &nbsp; M map &nbsp; H controls &nbsp; P / ESC pause</div>
'@

# STAMPS.
SubRx @'
var VER='11.25';
'@ @'
var VER='11.26';
'@
SubRx @'
var WHATSNEW_VER='11.25';
'@ @'
var WHATSNEW_VER='11.26';
'@
SubRx @'
  'FOUND: PILLAGERS OUT OF YOUR SIGHT NEVER FIRE BACK. A rule from the earliest builds only lets a pillager fight within 600 units of you, on a reason that stopped being true long ago. Out of your sight the machines shoot them and they never shoot back: zero rounds in a whole raid. Nothing changes yet; the switch and the numbers are on the board for a ruling.',
'@ @'
  'THE PAUSE SCREEN KEY LIST IS RIGHT AGAIN. It printed a stray "&nbsp;" between every key and still said F heals, TAB opens the bag and Q throws. It now matches the controls list under H: F is your melee strike, TAB is the backpack, 1 to 9 is the tactical belt.',
  'FOUND: PILLAGERS OUT OF YOUR SIGHT NEVER FIRE BACK. A rule from the earliest builds only lets a pillager fight within 600 units of you, on a reason that stopped being true long ago. Out of your sight the machines shoot them and they never shoot back: zero rounds in a whole raid. Nothing changes yet; the switch and the numbers are on the board for a ruling.',
'@
SubRx @'
  now:'v11.25: the 600 unit gate on pillager fighting is a rotted rule. Every site where a pillager may shoot a machine or a rival is gated to 600 units of the player, on the comment that the wall cache only covers that far; it covers the whole map. Machines hunt pillagers anywhere. Measured: out of the player sight a pillager fires zero rounds in a whole raid while the machines fire 88, and 33 of 40 die. New dial engageNear, 600 as shipped so nothing moves before the beta, 0 lifts it; both arms measured for his ruling.',
'@ @'
  now:'v11.26: the pause screen key line, found by a read-only audit of the HUD code and confirmed in the page: the non-breaking space entity was double-escaped, so the box printed the literal six characters fourteen times, and the line still said F heal, Q/G throw and TAB bag from before v10.64. It now mirrors the LEGEND table. A check reads the box and forbids the literal and the three stale phrases.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
