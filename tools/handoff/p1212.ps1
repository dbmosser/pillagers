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

# FROM THE 2026-09-06 READ-ONLY REVIEW OF v11.77 (the bigger blast): three
# things were calibrated to the old 150 radius and did not move with it. A
# pillager throws only in a band whose near edge (180) cleared his own blast
# at 150 and is inside it at 190, so he stood in his own charge at the near
# edge of every throw; the near edge follows the dial now. The "It hit cover.
# MOVE." warning fired only inside 110, half the new radius; it follows the
# dial too. And the card printed the coefficients as the centre damage, when
# the centre is coefficient plus floor: 140 and 98, not 115 and 80.
SubRx @'
  if(fd<180||fd>520) return false;
  var ix=-1;
  for(var i=0;i<e.bag.length;i++){ var it=ITEMS[e.bag[i]]; if(it&&it.use==='throw'&&it.tk==='frag'){ ix=i; break; } }
'@ @'
  // v12.12: the near edge of the band follows the blast radius (it was 180
  // against a 150 blast; at 190 he stood in his own charge), plus the scatter
  // of the aim point below and his own body; and never above his reach, or a
  // short-ranged pillager could never throw at all.
  var _fR=(CFG.fragR===undefined?190:CFG.fragR);
  if(fd<Math.min(_fR+52,(e.rng||520)-1)||fd>520) return false;
  var ix=-1;
  for(var i=0;i<e.bag.length;i++){ var it=ITEMS[e.bag[i]]; if(it&&it.use==='throw'&&it.tk==='frag'){ ix=i; break; } }
'@
SubRx @'
  if(blocked&&rngT<110) say(tk==='frag'?'It hit cover. MOVE.':'It hit cover, dropped short.');
'@ @'
  if(blocked&&rngT<(tk==='frag'?(CFG.fragR===undefined?190:CFG.fragR):110)) say(tk==='frag'?'It hit cover. MOVE.':'It hit cover, dropped short.');   // v12.12: the warning covers the whole blast
'@
SubRx @'
  'FRAG CHARGES REACH FURTHER AND HIT HARDER. Radius 150 to 190; to a machine or a pillager 115 at the centre, was 85; to you 80 at the centre, was 60. The fuse is still 1.1 seconds.',
'@ @'
  'FRAG CHARGES REACH FURTHER AND HIT HARDER. Radius 150 to 190; to a machine or a pillager 140 at the centre, was 100; to you 98 at the centre, was 72. The fuse is still 1.1 seconds.',
'@
SubRx @'
  // P.cfg=CFG;P.cfgv=17, and here CFG is still the file-scope default because
'@ @'
  // P.cfg=CFG;P.cfgv=18 (17 when this was written), and here CFG is still the file-scope default because
'@
SubRx @'
  // the player's dials and stamped cfgv 17, skipping every cfgv migration. storeSet
'@ @'
  // the player's dials and stamped the current cfgv, skipping every cfgv migration. storeSet
'@

# STAMPS.
SubRx @'
var VER='12.11';
'@ @'
var VER='12.12';
'@
SubRx @'
var WHATSNEW_VER='12.11';
'@ @'
var WHATSNEW_VER='12.12';
'@
$cnt=([regex]::Matches($s,"now:'v12\.11:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.11 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.11:[^']*'",{ param($m) "now:'v12.12: from the read-only review of the shipped v11.77, three things stayed calibrated to the old 150 blast: the pillager throw band near edge (180, inside a 190 blast) now follows the radius plus 52 (scatter and body), floored at his reach; the It hit cover MOVE warning covered 110, half the blast, and now covers the radius; and the card printed coefficients as centre damage (the centre is 140 and 98, was 100 and 72). The same build repairs check 11.44, whose cfgv sentinel was pinned at 17 and could never fire again. Check 12.12 hands a staged pillager a frag at 200 units and requires no throw, at 260 requires a throw, and reads the card figures; fails on v12.11.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
