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

# PLAYER 2 GETS CLOSE CALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netHitPlayer(p,amt,src,srcName,sx,sy){
'@ @'
function netHitPlayer(p,amt,src,srcName,sx,sy,rd){  // v28.35 (cloud-coop-p2-close-call), CLOUD HUNT 2026-10-15: rd marks an enemy round, so player 2 can earn CLOSE CALL
'@

SubRx @'
  m={t:'hit',seat:p.seat,dmg:+(+amt).toFixed(2),kind:netClean(src,16),name:netClean(srcName,24)}; if(LATCH_BITE) m.pi=1;   // crawlerlatch
'@ @'
  m={t:'hit',seat:p.seat,dmg:+(+amt).toFixed(2),kind:netClean(src,16),name:netClean(srcName,24)}; if(LATCH_BITE) m.pi=1;   // crawlerlatch
  if(rd) m.rd=1;  // v28.35 (cloud-coop-p2-close-call), CLOUD HUNT 2026-10-15: a round, not a blast or a bite
'@

SubRx @'
    if(dist(b,bd)<bd.r+3){ netHitPlayer(bd,b.dmg,(b.owner&&b.owner.kind)||'other',(b.owner&&b.owner.name)||'',b.x-b.vx*0.05,b.y-b.vy*0.05); return true; }
'@ @'
    if(dist(b,bd)<bd.r+3){ netHitPlayer(bd,b.dmg,(b.owner&&b.owner.kind)||'other',(b.owner&&b.owner.name)||'',b.x-b.vx*0.05,b.y-b.vy*0.05,1); return true; }  // v28.35 (cloud-coop-p2-close-call), CLOUD HUNT 2026-10-15: this is a round
'@

SubRx @'
  LATCH_BITE=m.pi?1:0;   // crawlerlatch: a crawler hanging on him bites through his roll too
'@ @'
  if(m.rd) try{ closeCall(null); }catch(_cc){}  // v28.35 (cloud-coop-p2-close-call), CLOUD HUNT 2026-10-15: a round reaching player 2 in his roll i-frames pays CLOSE CALL as it does the host
  LATCH_BITE=m.pi?1:0;   // crawlerlatch: a crawler hanging on him bites through his roll too
'@

SubRx @'
var VER='28.34';
'@ @'
var VER='28.35';
'@

$pat = "(?m)^  now:'v28\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.35: Player 2 now gets CLOSE CALL (stamina back and +25) when he rolls through an enemy round, just like player 1. Check 28.35 fails on v28.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
