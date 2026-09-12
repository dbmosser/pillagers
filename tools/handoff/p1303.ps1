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

# FOUND WHILE SWEEPING HIS EDITS FOR v13.02. Two features carry the same warning and
# the game writes it two different ways, so his edit of it reaches one of them.
#
# WHAT HE SEES. The HIRE tab is headed with the warning in capitals, and he rewrote
# that one: his version says what the warning is actually for, that the feature may
# glitch. THE LAST POUR carries the same warning on the Undercroft floor, written in
# mixed case. His wording is matched on the whole string, so the floor sign is a
# different string and his edit never touches it. He walks past the game's version of
# a warning he has already rewritten.
#
# IT IS ALSO HIS OWN RULE BROKEN. One word per thing. Two spellings of one warning is
# the same defect as two words for one object, and it is the reason the edit split.
#
# THE ASTERISKS ARE HIS, from v7.74. They stay. Only the spelling is made one.
SubRx @'
      wc.fillText('***Experimental***',_lx2,s3.y-35);
'@ @'
      // v13.03: THE SAME WARNING, SPELLED THE SAME WAY. The hire tab carries this
      // warning in capitals and he has rewritten that one; his wording is matched on
      // the whole string, so this sign being mixed case meant his version reached one
      // of the two features it warns about and not the other. His asterisks, v7.74.
      wc.fillText('***EXPERIMENTAL***',_lx2,s3.y-35);
'@

# NEW IN.
SubRx @'
  'THE GAME NOW CHECKS THAT THE WORDS YOU WROTE STILL APPEAR.
'@ @'
  'THE EXPERIMENTAL WARNING IS SPELLED ONE WAY. Two features carry it and the game wrote it two ways, so the wording you gave it reached the hire tab and never the sign on the floor by the bar. One spelling, so one edit covers both.',
  'THE GAME NOW CHECKS THAT THE WORDS YOU WROTE STILL APPEAR.
'@

# STAMPS.
SubRx @'
var VER='13.02';
'@ @'
var VER='13.03';
'@
SubRx @'
var WHATSNEW_VER='13.02';
'@ @'
var WHATSNEW_VER='13.03';
'@
$cnt=([regex]::Matches($s,"now:'v13\.02:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v13.02 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v13\.02:[^']*'",{ param($m) "now:'v13.03: found while sweeping his edits for v13.02. Two features carry the same warning and the game writes it two different ways, so his edit of it reaches one of them. The HIRE tab is headed with the warning in capitals and he rewrote that one, his version saying what the warning is actually for, that the feature may glitch; THE LAST POUR carries the same warning on the Undercroft floor written in mixed case, and his wording is matched on the whole string, so the floor sign is a different string and his edit never touches it, leaving him walking past the game version of a warning he has already rewritten. It is also his own rule broken, one word per thing: two spellings of one warning is the same defect as two words for one object, and it is the reason the edit split. The asterisks are his, from v7.74, and they stay; only the spelling is made one. Check 13.03 records what the floor actually draws, finds the entry in his baked map whose key is that warning, and requires the drawn text to be his wording rather than the games, with the control that the warning is still drawn at all so making it one spelling has not deleted the sign; fails on v13.02, where the floor draws the games spelling because his edit cannot match it.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
