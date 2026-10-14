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

# SUSTAINED FIRE PINS A PILLAGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feudFoe(a,b){
'@ @'
// v26.xx (ai22), HIS YES (2026-10-14, suggestion 22): "ok as a pillager behavior mechanic". SUPPRESSION. Rounds of yours that go past a
// hostile pillager (inside SUPP_R of him) count against him; SUPP_N of them inside SUPP_WIN seconds pin him for SUPP_PIN seconds, and
// more fire keeps him pinned. A pinned pillager in a fight stops advancing and flanking, ducks (the crouched pose), slips to cover that is
// no nearer you if there is any, and what he fires is wild (two and a half times the usual error). A rate of fire matters because the
// count is rounds past him: a Support MG pins a man in half a second, a Magnum seldom. A round from player 2 that hits him counts too.
// The state is on the host (a linked window sees the duck through a flag bit). No random number is drawn: it is counting and a timer.
var SUPP_R=70, SUPP_N=4, SUPP_WIN=1.8, SUPP_PIN=2.6;
function suppHit(en){
  if(!en||en.kind!=='raider'||en.merc||en.friendlyPC||en.hostile===false||en.downed||en.finished||!(en.hp>0)) return false;
  en.supp=(en.supp||0)+1; en.suppT=SUPP_WIN;
  if(en.supp>=SUPP_N){ en.pinT=SUPP_PIN; en.supp=0; return true; }
  return false;
}
function feudFoe(a,b){
'@

SubRx @'
            if(en.roll>0.08) continue;
'@ @'
            // v26.xx (ai22): a round of yours past a hostile pillager is suppression (once per round per man).
            if(en.kind==='raider'&&en.suppB!==b&&dist(b,en)<en.r+SUPP_R){ en.suppB=b; suppHit(en); }
            if(en.roll>0.08) continue;
'@

SubRx @'
    if(_se.shotT>0){ _se.shotT-=dt; if(_se.shotT<0) _se.shotT=0; }
'@ @'
    if(_se.shotT>0){ _se.shotT-=dt; if(_se.shotT<0) _se.shotT=0; }
    if(_se.suppT>0){ _se.suppT-=dt; if(_se.suppT<=0) _se.supp=0; }   // v26.xx (ai22): the count of rounds past him runs out
    if(_se.pinT>0){ _se.pinT-=dt; if(_se.pinT<0) _se.pinT=0; }
'@

SubRx @'
        if((sees||!_cg)&&(d>e.rng*raiderApf(e)
'@ @'
        if(e.pinT>0){
          // v26.xx (ai22): PINNED. He holds where he is (ducked), or slips to cover that is no nearer you.
          var _pcv=raiderCoverSpot(e,p,d);
          if(_pcv&&dist(_pcv,p)>=d-20&&dist(e,_pcv)>8) moveToward(e,_pcv.x,_pcv.y,e.spd*.85,dt);
        }
        else if((sees||!_cg)&&(d>e.rng*raiderApf(e)
'@

SubRx @'
            var _rjit=Math.max(e.steady?8:16,
                               d*_rk*((e.steady?0.038:0.062)+_rmv));
'@ @'
            var _rjit=Math.max(e.steady?8:16,
                               d*_rk*((e.steady?0.038:0.062)+_rmv))*(e.pinT>0?2.5:1);   // v26.xx (ai22): a pinned man shoots wild
'@

SubRx @'
(raiderCrouched(e2)?'crouch':'')
'@ @'
((raiderCrouched(e2)||e2.pinT>0)?'crouch':'')
'@

SubRx @'
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
'@ @'
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
  if(e.pinT>0) f|=268435456;   // v26.xx (ai22): pinned, so player 2 sees him duck
'@

SubRx @'
  e.steady=!!(f&8192);
'@ @'
  e.pinT=(f&268435456)?0.5:0;   // v26.xx (ai22)
  e.steady=!!(f&8192);
'@

SubRx @'
e.hp-=d; e.hitT=.16; e.pHitT=.3; e.pHitSeat=s; hitStopOn(e,d);
'@ @'
e.hp-=d; e.hitT=.16; e.pHitT=.3; e.pHitSeat=s; hitStopOn(e,d); suppHit(e);   // v26.xx (ai22): and player 2's rounds that land pin him as yours do
'@

SubRx @'
var VER='26.61';
'@ @'
var VER='26.62';
'@

$pat = "(?m)^  now:'v26\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.62: Heavy fire near a pillager now pins him: he ducks, stops advancing and shoots wild. Check 26.62 fails on v26.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
