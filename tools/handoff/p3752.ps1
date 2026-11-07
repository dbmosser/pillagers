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

# OVERSEER CHASES TOP DAMAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _se=G.ents[_sq];
'@ @'
    var _se=G.ents[_sq];
    // v28.xx (cw-cx-overseertarget): his g-24 answer, "Whoever hurt it most". Only the host keeps the fight ledger, before hit tags decay.
    if(_se.boss&&NET.on&&NET.role==='host'){
      var _ovD=(_se.ovHp0===undefined?_se.hp:_se.ovHp0)-_se.hp;
      if(_ovD>0&&_se.pHitT>0){
        _se.ovDmg=_se.ovDmg||{};
        var _ovS=_se.pHitSeat|0;
        _se.ovDmg[_ovS]=(_se.ovDmg[_ovS]||0)+_ovD;
      }
      _se.ovHp0=_se.hp;
    }
'@

SubRx @'
function netTargetFor(e){
  var best=G.player, bd, i, g, b, d, up;   // v16.14: a host who is out (spectating) is nobody's target
  if(!NET.on||!best||!e||e.merc||!NET.upSeed) return best;
  bd=dist(e,best); up=!best.downed;
  if(best.specOut){ bd=1e9; up=false; }
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    b=netUpBody(g); d=dist(e,b);
    if((!b.downed&&!up)||(((!b.downed)===up)&&d<bd)){ best=b; bd=d; up=!b.downed; }
  }
  return best;
}
'@ @'
function netTargetFor(e){
  var best=G.player, bd, i, g, b, d, up;
  if(!NET.on||!best||!e||e.merc||!NET.upSeed) return best;
  // v28.xx (cw-cx-overseertarget): the host chooses; a joining window reads the seat from the ninth snapshot field.
  if(e.boss&&NET.role==='join'&&e.ovTargetSeat>=0){
    if(e.ovTargetSeat===(NET.seat|0)) return best;
    for(i=0;i<NET.up.length;i++){
      g=NET.up[i];
      if(g.seat===e.ovTargetSeat&&netUpShown(g)&&!netUpHid(g)&&!netUpGone(g)) return netUpBody(g);
    }
  }
  if(e.boss&&NET.role==='host'&&e.ovDmg){
    var lead=null, high=0, tied=false;
    if(!best.downed&&!best.specOut&&(e.ovDmg[0]||0)>0){ lead=best; high=e.ovDmg[0]; }
    for(i=0;i<NET.up.length;i++){
      g=NET.up[i]; if(!netUpShown(g)||netUpHid(g)||netUpGone(g)) continue;
      b=netUpBody(g); if(b.downed||b.specOut) continue;
      d=e.ovDmg[g.seat|0]||0;
      if(d>high){ lead=b; high=d; tied=false; }
      else if(d>0&&d===high) tied=true;
    }
    if(lead&&!tied) return lead;
  }
  bd=dist(e,best); up=!best.downed;
  if(best.specOut){ bd=1e9; up=false; }
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    b=netUpBody(g); d=dist(e,b);
    if((!b.downed&&!up)||(((!b.downed)===up)&&d<bd)){ best=b; bd=d; up=!b.downed; }
  }
  return best;
}
'@

SubRx @'
  var k=NET_ENT_KINDS.indexOf(e.kind), s=NET_ENT_STATES.indexOf(e.state), mh=e.maxhp||1;
'@ @'
  var k=NET_ENT_KINDS.indexOf(e.kind), s=NET_ENT_STATES.indexOf(e.state), mh=e.maxhp||1;
  // v28.xx (cw-cx-overseertarget): bits 5-7 carry (seat+1), leaving the five existing status bits alone.
  var ot=(e.boss&&NET.on&&NET.role==='host')?netTargetFor(e):null;
'@

SubRx @'
((e.bigW&&e.windup>0)?16:0),animHitAngle(e)
'@ @'
((e.bigW&&e.windup>0)?16:0)|(ot?(((ot.net?ot.seat:0)+1)<<5):0),animHitAngle(e)
'@

SubRx @'
  e.seenYou=!!(f&256);
'@ @'
  e.seenYou=!!(f&256);
  // v28.xx (cw-cx-overseertarget): zero means an old row or no target; clear it rather than keeping a stale seat.
  e.ovTargetSeat=(typeof bx==='number')?((bx>>>5)&7)-1:-1;
'@

SubRx @'
var VER='37.51';
'@ @'
var VER='37.52';
'@

$pat = "(?m)^  now:'v37\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.52: In a party raid the Overseer pursues the standing player who dealt the most damage. Ties use the nearest player. Both windows use the host target. Check 37.52 fails on v37.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
