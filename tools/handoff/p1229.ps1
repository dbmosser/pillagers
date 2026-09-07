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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P1, confirmed by three refuters; his
# standing crawler note: "standing still and crawler didn't hurt me even though
# he was close", "crawler attacks and pathfinding were still kinda messed up").
# e.cd is two clocks on one field. On patrol the idle branch re-rolls the wander
# target whenever cd reaches 0 and writes cd=rnd(3,7), so a patrolling crawler
# carries a residual clock of up to seven seconds at every moment. The sighting
# transition into chase sets state, alert and the target and never touches cd
# for a machine (the only cd write there is the raider beat); packCall and the
# possum wake do not either. In chase the bite requires cd<=0, and cd only
# drains by dt. So a crawler that had just rolled a six-second wander, saw him
# and closed in under a second stood inside bite reach for five seconds doing
# nothing before its first bite: the residual wander clock, about 2.6 s on
# average, is served standing next to him. Three transitions into chase, one
# clamp each, crawlers only: the sentry shares the clock but a faster first
# shot is a balance change he has not asked for (NO BALANCING BEFORE ALPHA),
# so it is named in DESIGN and left.
SubRx @'
        e.state='chase'; e.alert=2.4; e.tx=p.x; e.ty=p.y;
'@ @'
        // v12.29, audit P1: a crawler's wander clock is the same field as its
        // bite cooldown, and it came into the chase with up to seven seconds
        // left on it. The first bite waits no longer than the clock a bite
        // itself sets. Crawlers only (a sentry's first shot is a balance call).
        if(e.kind==='crawler'&&e.state!=='chase'&&e.cd>0.3) e.cd=0.3;
        e.state='chase'; e.alert=2.4; e.tx=p.x; e.ty=p.y;
'@
SubRx @'
    e.alert=Math.max(e.alert,2.6);
    e.state='chase';
'@ @'
    e.alert=Math.max(e.alert,2.6);
    if(e.kind==='crawler'&&e.cd>0.3) e.cd=0.3;   // v12.29: the called crawler does not carry its wander clock into the rush
    e.state='chase';
'@
SubRx @'
        e.state='chase'; e.alert=4; e.tx=p.x; e.ty=p.y;
'@ @'
        if(e.kind==='crawler'&&e.cd>0.3) e.cd=0.3;   // v12.29: a crawler that was playing dead bites on waking, not after its old clock
        e.state='chase'; e.alert=4; e.tx=p.x; e.ty=p.y;
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A CRAWLER THAT SEES YOU BITES WHEN IT REACHES YOU. It used to stand next to you for up to seven seconds first, serving out the clock it had rolled for its next wander.',
'@

# STAMPS.
SubRx @'
var VER='12.28';
'@ @'
var VER='12.29';
'@
SubRx @'
var WHATSNEW_VER='12.28';
'@ @'
var WHATSNEW_VER='12.29';
'@
$cnt=([regex]::Matches($s,"now:'v12\.28:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.28 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.28:[^']*'",{ param($m) "now:'v12.29: 2026-09-07 audit P1 (his standing crawler note): a crawler on patrol re-rolls its wander target whenever e.cd reaches zero and writes cd=rnd(3,7), and the same field is the bite cooldown; the sighting transition, packCall and the possum wake never touched it, so a crawler that closed in under a second stood in bite reach for the rest of a wander clock of up to seven seconds before its first bite. On each of the three transitions into chase a crawler now carries no more than 0.3 s of clock. Sentries share the field and are left alone (a faster first shot is a balance call). Check 12.29 parks one crawler on patrol with 6.5 s of clock 120 units from a still, visible player and requires the first bite inside 2 s of stepping; a control with the clock at zero must also bite inside 2 s; a crawler called in by packCall with 6.5 s of clock must bite inside 3 s; fails on v12.28 at about 6.5 s.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
