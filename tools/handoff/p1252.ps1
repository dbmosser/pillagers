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

# MY OWN DEFECT FROM v12.20, found by the 2026-09-07 read-only audit.
#
# v12.20 moved the near edge of a pillager's throwing band out to the blast
# radius plus the scatter, so he would stop standing in his own charge, and then
# capped it at his own reach so a short-ranged man could still throw at all. The
# cap is the bug. For one gun in nine, the Riot Scattergun, the reach is 187 and
# the safe edge is 242, so the cap pulls the edge back inside the blast: the
# only distances he can throw from are 186.2 to 187.2, a window one unit wide,
# and every throw inside it lands within the radius of the man who threw it.
#
# Both of v12.20's stated goals fail for that one gun: the edge does not clear
# his blast, and the cap that was meant to stop a short-ranged man never
# throwing gives him a single unit instead of a band. The honest answer is that
# a man whose reach is inside his own blast should not throw at all.
SubRx @'
  // v12.20: the near edge of the band follows the blast radius (it was 180
  // against a 150 blast; at 190 he stood in his own charge), plus the scatter
  // of the aim point below and his own body; and never above his reach, or a
  // short-ranged pillager could never throw at all.
  var _fR=(CFG.fragR===undefined?190:CFG.fragR);
  if(fd<Math.min(_fR+52,(e.rng||520)-1)||fd>520) return false;
'@ @'
  // v12.20: the near edge of the band follows the blast radius (it was 180
  // against a 150 blast; at 190 he stood in his own charge), plus the scatter
  // of the aim point below and his own body.
  // v12.52, 2026-09-07 audit, and this was my own mistake at v12.20: the cap I
  // put on that edge so a short-ranged pillager could still throw pulled the
  // edge back INSIDE the blast for the one gun in nine whose reach is shorter
  // than it. A Riot Scattergun man reaches 187 against a safe edge of 242, and
  // since both callers already require him to be inside his reach, the only
  // distances he could throw from were 186.2 to 187.2: a band one unit wide,
  // entirely within the radius of the charge he was throwing. Both goals of
  // that line failed for him at once. The honest answer is the one the cap was
  // avoiding: a man whose whole reach is inside his own blast does not throw.
  var _fR=(CFG.fragR===undefined?190:CFG.fragR);
  var _fNear=_fR+52;
  if(_fNear>=(e.rng||520)) return false;
  if(fd<_fNear||fd>520) return false;
'@

# NEW IN.
SubRx @'
  'A HOWLER NO LONGER SHELLS ITS OWN CRATER. It heard its own impact, took the crater for a fresh report, and mailed another shell to it, and that one wound it up again. One noise from you became a barrage of two to four after you had gone quiet.',
'@ @'
  'A HOWLER NO LONGER SHELLS ITS OWN CRATER. It heard its own impact, took the crater for a fresh report, and mailed another shell to it, and that one wound it up again. One noise from you became a barrage of two to four after you had gone quiet.',
  'A PILLAGER WHOSE REACH IS INSIDE HIS OWN BLAST NO LONGER THROWS A CHARGE. One gun in nine has a shorter reach than the radius of a frag, and the man carrying it had a throwing window one unit wide, entirely inside his own explosion.',
'@

# STAMPS.
SubRx @'
var VER='12.51';
'@ @'
var VER='12.52';
'@
SubRx @'
var WHATSNEW_VER='12.51';
'@ @'
var WHATSNEW_VER='12.52';
'@
$cnt=([regex]::Matches($s,"now:'v12\.51:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.51 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.51:[^']*'",{ param($m) "now:'v12.52: my own defect from v12.20, found by the 2026-09-07 read-only audit. v12.20 moved the near edge of a pillagers throwing band out to the blast radius plus the scatter, so he would stop standing in his own charge, and then capped that edge at his own reach so a short-ranged man could still throw at all. The cap is the bug. For one gun in nine, the Riot Scattergun, the reach is 187 against a safe edge of 242, so the cap pulls the edge back inside the blast; and since both callers already require him to be inside his reach, the only distances he could throw from were 186.2 to 187.2, a band one unit wide and entirely within the radius of the charge he was throwing. Both goals of that line failed for him at once: the edge did not clear his blast, and the cap meant to stop a short-ranged man never throwing gave him a single unit instead of a band. The honest answer is the one the cap was avoiding: a man whose whole reach is inside his own blast does not throw. Check 12.52 pins a pillagers gun to the Riot Scattergun, stands the player inside that one unit window with a charge in the mans bag and every other gate open, and requires no throw at all; a control with the same man given an ordinary reach must still throw from outside the blast, and a third arm requires the thrown charge to land outside his own radius; fails on v12.51.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
