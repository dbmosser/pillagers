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

# KID MODE STAYS ON AFTER THE HOST LEAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!netContPeer()) return false;
'@ @'
  if(!netContPeer()) return false;
  // v21.97, from the whole-game bug hunt of 2026-10-08 (K7): KID MODE AND KID FIRING STAY WITH PLAYER 2 AFTER THE TAKEOVER. Both
  // asked for a live link to a host, and a lost link or a bye resets the party right after this, so from the takeover on the
  // child took every hit in full and his gun stopped aiming, while the out word (no reset) kept both. This raid is marked as one
  // this window joined, and both read that mark too. G is built fresh for every raid, so the mark ends with it; solo never sets it.
  G.netWasJoin=1;
'@

SubRx @'
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&isFinite(amt)) amt*=netKidMul();   // v16.44, his order: kid mode, player 2 takes less
'@ @'
  // v21.97 (K7): and on a raid this window joined and took over when the host left
  if(typeof NET==='object'&&NET&&((NET.on&&NET.role==='join')||(typeof G!=='undefined'&&G&&G.netWasJoin))&&isFinite(amt)) amt*=netKidMul();   // v16.44, his order: kid mode, player 2 takes less
'@

SubRx @'
function netAfOn(){ return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&(afOwn()||NET.afHost===1)); }
'@ @'
function netAfOn(){ return !!(typeof NET==='object'&&NET&&((NET.on&&NET.role==='join')||(typeof G!=='undefined'&&G&&G.netWasJoin))&&(afOwn()||NET.afHost===1)); }   // v21.97 (K7): and on a raid this window joined and took over
'@

SubRx @'
var VER='21.96';
'@ @'
var VER='21.97';
'@

$pat = "(?m)^  now:'v21\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.97: In co-op, Kid mode and Kid firing stay on for player 2 after the host leaves the raid. Check 21.97 fails on v21.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
