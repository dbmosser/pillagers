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

# PLAYER 2 FIRST CONTACT (his principle: player 2 equals player 1; his run reports showed none).

SubRx @'
      if(e.state!=='chase'&&T.firstContact===null) T.firstContact=G.t;
'@ @'
      // v16.36, HIS PRINCIPLE (player 2 equals player 1): first contact is stamped for the player this body went for. A body that
      // went for one of the party tells that seat; before this the host stamped it for itself and player 2 always read none.
      if(e.state!=='chase'){ if(p&&p.net) netContactSend(p.seat); else if(T.firstContact===null) T.firstContact=G.t; }
'@

SubRx @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
'@ @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='contact') return netContactTake(peer,m);   // v16.36: an enemy went for this seat first, from the host
'@

SubRx @'
function netKillTake(peer,m){
'@ @'
// v16.36: THE HOST tells a seat, once a raid, that an enemy first went for it; THE SEAT stamps its own first contact.
function netContactSend(s){
  var q;
  if(!NET.on||NET.role!=='host'||typeof s!=='number') return false;
  if(!G.netContact) G.netContact={};
  if(G.netContact[s]) return false;
  q=netPeerOfSeat(s); if(!q) return false;
  G.netContact[s]=1;
  return netSend(q,{t:'contact',seat:s});
}
function netContactTake(peer,m){
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(typeof G==='undefined'||!G||G.sim||!G.tel) return 'down';
  if(typeof m.seat==='number'&&m.seat!==NET.seat) return 'ignored';
  if(G.tel.firstContact===null) G.tel.firstContact=G.t;
  return 'contact';
}
function netKillTake(peer,m){
'@

SubRx @'
var VER='16.35';
'@ @'
var VER='16.36';
'@

$pat = "(?m)^  now:'v16\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.36: PLAYER 2 FIRST CONTACT. His run reports showed player 2 at firstContact none in every co-op raid: first contact was stamped where the host AI picks its target, which never runs on player 2, and it stamped the host even when the enemy went for player 2. The host now tells the seat an enemy went for, once a raid, and that seat stamps its own. The live two window test now also has player 2 shoot a host body for real: hits, damage and the kill credit all reach player 2. Check 16.36 fails on v16.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
