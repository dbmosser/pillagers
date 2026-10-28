$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# BOXES SEARCH FASTER TOGETHER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var NET_SRCH_REACH=200;
'@ @'
// v28.xx (cw-cx-duosearch), his decision 2026-10-28: "Crates open faster with two". Every box, in demo and career co-op.
var DUO_SRCH=1.5, DUO_R=200;
function duoAt(ct,seat){
  if(!ct||!NET.on||!G||G.sim||!NET.upSeed||(G.seed>>>0)!==(NET.upSeed>>>0)) return false;
  if(seat===undefined) seat=NET.seat;
  var p=G.player, i, q;
  if(NET.role==='host'&&seat!==NET.seat&&!G.over&&p&&!p.downed&&!p.dying&&!p.specOut&&p.hp>0&&Math.hypot(p.x-ct.x,p.y-ct.y)<=DUO_R) return true;
  for(i=0;i<(NET.up||[]).length;i++){
    q=NET.up[i];
    if(q&&q.seat!==seat&&netUpShown(q)&&!netUpGone(q)&&!netUpHid(q)&&!q.dn&&!q.specOut&&!q.out&&q.hp>0&&Math.hypot(q.x-ct.x,q.y-ct.y)<=DUO_R) return true;
  }
  return false;
}
var NET_SRCH_REACH=200;
'@

SubRx @'
      near.prog=(near.prog||0)+dt/buzzSlow()*(G.arcade?ARCADE_SRCH:1);   // v23.33 (arcade11): six times as fast in the arcade
'@ @'
      near.prog=(near.prog||0)+dt/buzzSlow()*(G.arcade?ARCADE_SRCH:1)*(duoAt(near,NET.seat)?DUO_SRCH:1);   // v28.xx (cw-cx-duosearch): a nearby party member helps the host search
'@

SubRx @'
  if(s.ok) near.prog=Math.min(near.time||1,(near.prog||0)+dt/buzzSlow());
'@ @'
  if(s.ok) near.prog=Math.min(near.time||1,(near.prog||0)+dt/buzzSlow()*(G.arcade?ARCADE_SRCH:1)*(duoAt(near,NET.seat)?DUO_SRCH:1));   // v28.xx (cw-cx-duosearch): predict the same speed as the host
'@

SubRx @'
    ct.prog=(ct.prog||0)+dt/r.slow*(G.arcade?ARCADE_SRCH:1);   // v23.33 (arcade11): a box held through the host is fast in the arcade too
'@ @'
    ct.prog=(ct.prog||0)+dt/r.slow*(G.arcade?ARCADE_SRCH:1)*(duoAt(ct,+s)?DUO_SRCH:1);   // v28.xx (cw-cx-duosearch): the host himself can help a partner search
'@

SubRx @'
var VER='35.91';
'@ @'
var VER='35.92';
'@

$pat = "(?m)^  now:'v35\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.92: Boxes search 1.5 times faster with a nearby teammate. Check 35.92 fails on v35.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
