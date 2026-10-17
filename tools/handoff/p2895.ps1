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

# PLAYER 2 NEAR MISSES PIN PILLAGERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
            if(en.kind==='raider'&&en.suppB!==b&&dist(b,en)<en.r+SUPP_R){ en.suppB=b; suppHit(en); }
'@ @'
            if(en.kind==='raider'&&en.suppB!==b&&dist(b,en)<en.r+SUPP_R){ en.suppB=b; suppHit(en); if(NET.on&&NET.role==='join'&&en.nid&&netEntsPeer()){ NET.supQ=NET.supQ||{}; NET.supQ[en.nid]=(NET.supQ[en.nid]|0)+1; } }   // v28.xx (cw-nearmiss), CLOUD HUNT 2026-10-15: on a linked window the host runs this man, so the round past him is counted for the host, sent in one word a tenth of a second (netFxStep)
'@

SubRx @'
  if(m.t==='contact') return netContactTake(peer,m);   // v16.36: an enemy went for this seat first, from the host
'@ @'
  if(m.t==='sup'){ if(NET.role!=='host'||!netEntsHost()||peer.state!=='in'||!m.q||typeof m.q!=='object') return 'ignored'; var _sk, _su, _sn; for(_sk in m.q){ if(!Object.prototype.hasOwnProperty.call(m.q,_sk)) continue; _su=(NET.entMap&&NET.entMap[_sk|0])||null; if(!_su||G.ents.indexOf(_su)<0) continue; _sn=Math.min(16,Math.max(0,m.q[_sk]|0)); while(_sn-->0) suppHit(_su); } return 'sup'; }   // v28.xx (cw-nearmiss), CLOUD HUNT 2026-10-15: rounds of one of the party went past these men (counts by body), suppression counted on the host
  if(m.t==='contact') return netContactTake(peer,m);   // v16.36: an enemy went for this seat first, from the host
'@

SubRx @'
hitStopOn(e,m.hs===1?HITSTOP_DMG:0); suppHit(e); /*v28.xx (cw-hitstoprule)
'@ @'
hitStopOn(e,m.hs===1?HITSTOP_DMG:0); /*v28.xx (cw-nearmiss), CLOUD HUNT 2026-10-15: no suppHit here: a gun round already counted by its sup word as it reached him, and the host own frag, fists, finisher, air strike and screen clear never pin*/ /*v28.xx (cw-hitstoprule)
'@

SubRx @'
  return G.fxBullets?G.fxBullets.length:0;
'@ @'
  if(NET.supQ&&!netEntsPeer()) NET.supQ=null;   // v28.xx (cw-nearmiss), CLOUD HUNT 2026-10-15: rounds this linked window sent past men the host runs, one reliable word a tenth of a second
  NET.supAcc=(NET.supAcc||0)+dt;
  if(NET.supAcc>=NET_HUB_STEP&&NET.supQ){ NET.supAcc=0; var _spq=netPeerOfSeat(0); if(_spq) netSend(_spq,{t:'sup',q:NET.supQ}); NET.supQ=null; }
  return G.fxBullets?G.fxBullets.length:0;
'@

SubRx @'
var VER='28.94';
'@ @'
var VER='28.95';
'@

$pat = "(?m)^  now:'v28\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.95: Player 2s fire pins pillagers the same way player 1s does: rounds that go close count, not only the ones that hit. Check 28.95 fails on v28.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
