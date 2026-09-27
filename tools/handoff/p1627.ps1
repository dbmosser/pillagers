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

# PAUSE AND SUPERHOT IN CO-OP, AND THE TEAMMATE ROWS MOVED. His notes of 2026-09-27.

SubRx @'
  if(CFG.superhot&&G.player&&!G.over&&!G.paused&&!netUpShared()){   // v16.04: Superhot is off in a shared co-op raid (one world cannot stop for one player)
'@ @'
  if(CFG.superhot&&G.player&&!G.over&&!G.paused){   // v16.27, his note: in co-op time runs while ANY player up top is acting (v16.04 had it off)
'@

SubRx @'
    if(!_shAct) dt=0;
'@ @'
    G.shAct=_shAct;
    if(!_shAct&&!netAnyActing()) dt=0;
'@

SubRx @'
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0),dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate
'@ @'
       hp:Math.round(p.hp||0),mh:Math.round(p.maxhp||100),ar:Math.round(p.armor||0),ac:Math.round(armorCap()||0),dt:p.downed?Math.max(0,Math.ceil(p.downT||0)):0,sa:(!CFG.superhot||G.shAct)?1:0};   // v16.20: pz, this player is paused; v16.23: health and armour, for a teammate's bandage or plate
'@

SubRx @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@ @'
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; g.pz=m.pz?1:0; g.hp=+m.hp||0; g.mh=+m.mh||100; g.ar=+m.ar||0; g.ac=+m.ac||0; g.dt=+m.dt||0; g.sa=(m.sa===undefined)?1:(m.sa?1:0); }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in; v16.20: paused; v16.23: health and armour
'@

SubRx @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; out.hp=g.hp; out.mh=g.mh; out.ar=g.ar; out.ac=g.ac; out.dt=g.dt; }   // v15.79: passed on as it came
'@ @'
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; out.pz=g.pz; out.hp=g.hp; out.mh=g.mh; out.ar=g.ar; out.ac=g.ac; out.dt=g.dt; out.sa=g.sa; }   // v15.79: passed on as it came
'@

SubRx @'
  if(typeof G==='undefined'||!G||!G.paused) return false;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(!netUpShown(g)) continue; if(!g.pz) return false; n++; }
  return n>0;
}
'@ @'
  if(typeof G==='undefined'||!G||!G.paused) return false;
  // v16.27, his note: any time every player is paused the game pauses. A teammate who is not up top (in the Undercroft, on the
  // run card, out) is not playing, so with nobody up top and unpaused the pause stops the world as in solo.
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(!netUpShown(g)) continue; if(!g.pz) return false; n++; }
  return true;
}
// v16.27: Superhot in co-op. Is any teammate up top acting (moving, shooting, rolling, reloading) and not paused? Then time runs.
function netAnyActing(){
  var i, g;
  if(typeof NET!=='object'||!NET||!NET.on||!netUpShared()) return false;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(netUpShown(g)&&g.sa&&!g.pz) return true; }
  return false;
}
'@

SubRx @'
    y=by-96-n*40; n++;
'@ @'
    y=Math.round(H*0.30)+n*44; n++;   // v16.27, his note: the rows sat on the belt help line; they now run down the left edge, clear of it
'@

SubRx @'
var VER='16.26';
'@ @'
var VER='16.27';
'@

$pat = "(?m)^  now:'v16\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.27: PAUSE AND SUPERHOT IN CO-OP, AND THE TEAMMATE ROWS MOVED. His notes. Any time every player is paused the game pauses, including when your teammate is not in the raid (before, a teammate in the Undercroft kept your world running). In Superhot, time runs while any player in the raid is acting and stops when nobody is. The teammate rows moved to the left edge, clear of the belt help line. No number moved. Check 16.27 fails on v16.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
