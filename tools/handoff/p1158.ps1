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

# HIS NOTE, 2026-09-05 in-run at 130 s: "how lightning shows red noise, I want
# ALL noises to do that when they are outside the player's vision but within
# earshot, eg visualize noises with red circles!" That ring is noiseMark
# (v9.07): every world sound routed through sfx(type,x,y) draws a ring when
# you could hear it and could not see it. Four sounds never went through it,
# because they were played by distance alone with no position: the storm's
# strike telegraph, and the extraction's inbound pulse, touchdown and last
# call. They go through sfx now, with a ring size each, so every noise in the
# game marks itself the same way.

# 1. RING SIZES for the three sounds that had none.
SubRx @'
  step:  {r:26, hear:420},
  board: {r:34, hear:520}
};
'@ @'
  step:  {r:26, hear:420},
  board: {r:34, hear:520},
  // v11.58, HIS NOTE: the extraction's own sounds mark themselves too.
  inbound:  {r:30, hear:1400},
  touchdown:{r:88, hear:1500},
  lastcall: {r:44, hear:1400}
};
'@

# 2. THE STORM TELEGRAPH, at the strike point.
SubRx @'
    if(!G.sim) blip('charge',dist(p,{x:sx,y:sy}));
'@ @'
    if(!G.sim) sfx('charge',sx,sy);   // v11.58, HIS NOTE: a positioned sound marks itself
'@

# 3. THE EXTRACTION'S INBOUND PULSE, TOUCHDOWN AND LAST CALL, at the ring.
SubRx @'
      if(z.pingT>=_iv){ z.pingT=0; blip('inbound',dist(p,z)); }
'@ @'
      if(z.pingT>=_iv){ z.pingT=0; sfx('inbound',z.x,z.y); }   // v11.58: marks itself
'@
SubRx @'
      if(dist(p,z)<1400){ blip('touchdown',dist(p,z)); blip('alarm',dist(p,z));
'@ @'
      if(dist(p,z)<1400){ sfx('touchdown',z.x,z.y); sfx('alarm',z.x,z.y);   // v11.58: mark themselves
'@
SubRx @'
      blip('lastcall',dist(p,z));
'@ @'
      sfx('lastcall',z.x,z.y);   // v11.58: marks itself
'@

# STAMPS.
SubRx @'
var VER='11.57';
'@ @'
var VER='11.58';
'@
SubRx @'
var WHATSNEW_VER='11.57';
'@ @'
var WHATSNEW_VER='11.58';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'EVERY NOISE YOU CAN HEAR BUT NOT SEE DRAWS ITS RING. Four never did: the storm telegraph and the extraction pulse, touchdown and last call. They do now.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.57:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.57 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.57:[^']*'",{ param($m) "now:'v11.58: HIS NOTE of 2026-09-05, all noises outside vision but within earshot should draw a ring like lightning does. noiseMark (v9.07) already does that for every sound routed through sfx(type,x,y); four sounds bypassed it by playing by distance with no position: the strike telegraph and the extraction inbound pulse, touchdown and last call. They go through sfx now with ring sizes of their own. Check 11.58 requires the three new ring sizes, a ring for an unseen inbound behind the player and none for a seen one in front, and that strikeTick and tickExtractPoints route those four sounds through sfx.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
