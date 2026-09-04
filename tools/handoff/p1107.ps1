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

# ============ HIS NOTE 22, ASKED TWICE: CRAWLERS ARE NOT ATTACKING PROPERLY.
# ============
# ============ "Once again, crawlers aren't attacking properly?", 2026-09-04, and
# ============ before that, 2026-09-03: "i saw atleast one instance where i was
# ============ standing still and crawler didn't hurt me even though he was
# ============ close".
# ============
# ============ REPRODUCED, AND THE NUMBER IS SHARP. One crawler stood 30 units
# ============ from a still player and facing him, with its bite reaching to 36,
# ============ three seconds each time, varying only how well hidden he was:
# ============
# ============   concealment 1.00 to 0.35   bites, 65 damage
# ============   concealment 0.25 and below ZERO damage, sits in patrol forever
# ============
# ============ THE CAUSE: a crawler's EYES shrink with concealment and its REACH
# ============ does not. Sight is 100 units times concealment; the bite reaches
# ============ 36. Below about 0.3 there is a band where it is close enough to
# ============ bite and cannot see, and the bite lives inside the chase branch, so
# ============ it never enters chase and stands there touching him doing nothing.
# ============ That is exactly what he saw, both times.
# ============
# ============ THE FIX: you cannot hide from something that is already touching
# ============ you. A crawler's sight gets a FLOOR equal to its own reach plus a
# ============ margin, in every direction rather than only in its cone, so
# ============ anything within biting distance has found him whatever the
# ============ concealment says. A wall still stops it: canSee does its own line
# ============ of sight and the bite tests for one separately.
# ============
# ============ THIS CHANGES WHAT CRAWLERS DO and I am not pretending otherwise,
# ============ so it sits on a dial. touchSees 0 restores exactly the old
# ============ behaviour for measuring against.
SubRx @'
    var sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_far0*(e.alert>0?1.35:1)*pcon*wkSight,e.cone,_amb0*pcon*wkSight);
'@ @'
    var _fSee=_far0*(e.alert>0?1.35:1)*pcon*wkSight, _aSee=_amb0*pcon*wkSight;
    // v11.07, HIS NOTE 22: A THING THAT CAN BITE YOU HAS FOUND YOU. The floor is
    // its own reach plus a margin, so it notices you a moment before it can bite
    // rather than exactly on the line, and it applies to the corner of the eye as
    // well as the cone, because you do not hide from something you are touching
    // by standing behind it.
    if((CFG.touchSees===undefined?1:CFG.touchSees)&&e.kind==='crawler'){
      var _tch=(e.r+(p.r||11))+MELEE_REACH+2;
      if(_fSee<_tch) _fSee=_tch;
      if(_aSee<_tch) _aSee=_tch;
    }
    var sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee,e.cone,_aSee);
'@

SubRx @'
raiderCrawl:1,nightDens:1.35,bldgRuin:0.09};
'@ @'
raiderCrawl:1,nightDens:1.35,bldgRuin:0.09,touchSees:1};
'@

SubRx @'
var VER='11.06';
'@ @'
var VER='11.07';
'@
SubRx @'
  now:'v11.06: the black block over the jersey, your note. Not the backpack, which is drawn behind the body. It was the jersey own black side panels, 2.4 wide each on a chest 13 wide, measured at 2,384 pixels against 3,222 of red, plus the chest rig band laid straight across the lower half of the 23. The panels are trim now and the jersey is drawn after the rig instead of before it.',
'@ @'
  now:'v11.07: crawlers not attacking, your note, asked twice. Reproduced: a crawler 30 units away with a bite that reaches 36, facing you, bites for 65 damage in three seconds at concealment 0.35 and does NOTHING at 0.25 and below. Its eyes shrink with your concealment and its reach does not, so there is a band where it can bite and cannot see, and the bite only exists inside chase. Its sight now has a floor equal to its own reach: you cannot hide from something that is touching you.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A CRAWLER CLOSE ENOUGH TO BITE YOU HAS FOUND YOU. Hiding used to shrink its eyes below its own reach, so one could stand against you, unable to see you, and do nothing. Its sight now has a floor equal to how far it can reach. Walls still stop it.',
'@
SubRx @'
var WHATSNEW_VER='11.06';
'@ @'
var WHATSNEW_VER='11.07';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
