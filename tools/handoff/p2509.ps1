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

# A CRAWLER THAT CATCHES YOU HANGS ON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var MELEE_REACH=10;
'@ @'
var MELEE_REACH=10;
// crawlerlatch, HIS ORDER (2026-10-12): "when crawler catches player, it should continue to deal damage until it is killed, seeems
// too lenient right now". A CRAWLER THAT CATCHES YOU HANGS ON. Measured before this, one crawler touching a player on full health:
// standing still, a bite every 0.7 s (9 in 6 s); walking away, ONE bite in 6 s, because his walk (about 158 a second) is faster
// than a crawler (150), so it trailed 58 behind and never touched him again; sprinting, one bite and it lost him; rolling, no
// damage at all, the one bite it had landed inside the roll and its 0.3 s of immunity ate it. Now the body that touches you
// latches on: it stays at your side wherever you walk, sprint or roll, and keeps biting on its own 0.7 s clock (same bite, same
// rate: one crawler still takes about 5 s to kill a man on full health with no armour) until it is dead, or you go down (a
// downed man is not bitten, as before), or the raid ends. A latched bite lands through the roll, because the roll is a dodge
// and not a way out of something already on you; the two seconds after a revive still protect you. A wall between you breaks it.
// Two or three can hang on at once, each at its own side. It is still a body out in the world: shoot it, knife it, frag it.
// Player 2: the host runs the crawler, it hangs on to his body as his window reports it, and the bite goes to his window.
var LATCH_BITE=0;   // set only around a latched bite: damagePlayer lets it through the roll
// The body this crawler holds (the host player, or one of the party by seat), or null, and the hold let go, when it is gone.
function crawlerLatchBody(e){
  var b=null, i, q;
  if(!e||e.latchS===undefined||e.latchS===null) return null;
  if(e.latchS<0) b=G.player;
  else if(typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&NET.up){
    for(i=0;i<NET.up.length;i++){ q=NET.up[i]; if(q&&q.seat===e.latchS&&netUpShown(q)){ b=netUpBody(q); break; } }
  }
  if(!b||b.downed||b.dying||b.specOut||G.over||!(e.hp>0)||(dist(e,b)-(e.r+(b.r||11)))>60){ e.latchS=null; return null; }
  return b;
}
'@

SubRx @'
        if(!_cReach) navSeek(e,sees?p.x:e.tx,sees?p.y:e.ty,e.spd,dt);
        else if(e.cd<=0&&!p.downed){ netHitPlayer(p,e.dmg*(e.elite?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1),'crawler',e.name,e.x,e.y); e.cd=.7; }   // v15.80: the host player through damagePlayer as always; one of the party through a hit word to his window
'@ @'
        // crawlerlatch, HIS ORDER (2026-10-12): a crawler that catches you hangs on and keeps biting until it is killed (see LATCH_BITE).
        // It catches you the moment it is in reach with a clear line, as its bite always has; held, it is set at your side each frame
        // (it keeps the side it caught you from), stays in the chase, and bites on its own clock. crawlerLatch 0 restores the old chase.
        var _lOn=(CFG.crawlerLatch===undefined?1:CFG.crawlerLatch), _lb=_lOn?crawlerLatchBody(e):null;
        if(!_lb&&_lOn&&_cReach&&!p.downed&&!p.dying&&!p.specOut){ e.latchS=p.net?p.seat:-1; e.latchBlk=0; _lb=p; }
        if(_lb){
          var _la=Math.atan2(e.y-_lb.y,e.x-_lb.x), _lr=e.r+(_lb.r||11)+2;
          e.x=_lb.x+Math.cos(_la)*_lr; e.y=_lb.y+Math.sin(_la)*_lr;
          e.alert=2.4; e.tx=_lb.x; e.ty=_lb.y; e.chaseHold=0;
          want=Math.atan2(_lb.y-e.y,_lb.x-e.x);
          if(losClear(e.x,e.y,_lb.x,_lb.y,G.vseg)){
            e.latchBlk=0;
            if(e.cd<=0){ LATCH_BITE=1; try{ netHitPlayer(_lb,e.dmg*(e.elite?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1),'crawler',e.name,e.x,e.y); } finally{ LATCH_BITE=0; } e.cd=.7; }
          } else if((e.latchBlk=(e.latchBlk||0)+dt)>0.3) e.latchS=null;   // a wall came between: it lets go and hunts as before
        }
        else if(!_cReach) navSeek(e,sees?p.x:e.tx,sees?p.y:e.ty,e.spd,dt);
        else if(e.cd<=0&&!p.downed){ netHitPlayer(p,e.dmg*(e.elite?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1),'crawler',e.name,e.x,e.y); e.cd=.7; }   // v15.80: the host player through damagePlayer as always; one of the party through a hit word to his window
'@

SubRx @'
  if(p.iv>0) return;
'@ @'
  if(p.iv>0&&!(LATCH_BITE&&p.iv<=0.30)) return;   // crawlerlatch: a crawler hanging on bites through the roll (its 0.30 s), not through a revive
'@

SubRx @'
  m={t:'hit',seat:p.seat,dmg:+(+amt).toFixed(2),kind:netClean(src,16),name:netClean(srcName,24)};
'@ @'
  m={t:'hit',seat:p.seat,dmg:+(+amt).toFixed(2),kind:netClean(src,16),name:netClean(srcName,24)}; if(LATCH_BITE) m.pi=1;   // crawlerlatch
'@

SubRx @'
  damagePlayer(d,netClean(m.kind,16)||'other',netClean(m.name,24)||'',(typeof m.x==='number'&&isFinite(m.x))?m.x:undefined,(typeof m.y==='number'&&isFinite(m.y))?m.y:undefined);
'@ @'
  LATCH_BITE=m.pi?1:0;   // crawlerlatch: a crawler hanging on him bites through his roll too
  try{ damagePlayer(d,netClean(m.kind,16)||'other',netClean(m.name,24)||'',(typeof m.x==='number'&&isFinite(m.x))?m.x:undefined,(typeof m.y==='number'&&isFinite(m.y))?m.y:undefined); } finally{ LATCH_BITE=0; }
'@

SubRx @'
var VER='25.08';
'@ @'
var VER='25.09';
'@

$pat = "(?m)^  now:'v25\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.09: A crawler that catches you hangs on and keeps biting until you kill it. Walking, sprinting and rolling no longer shake it off. Check 25.09 fails on v25.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
