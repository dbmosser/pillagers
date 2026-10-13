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

# LIGHT BLOOD: PILLAGERS AND PLAYERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function spark(x,y,col,n,spread){
'@ @'
// 2026-10-12 (blood), HIS ANSWER 37 a: light blood, "only from pillager bots and players". A pillager hit by any round, and a player
// taking any damage, now bleeds a little: a few dark red droplets, a short red mist and, now and then, a small drop on the ground
// that fades with the other ground marks. Machines never bleed: a round on a machine throws the same yellow sparks as before. Light on
// purpose: a few pixels, never a pool. Cosmetic only, every draw from the cosmetic stream.
var BLOOD_SPRAY='#b3241b', BLOOD_MIST='#7a1612', BLOOD_DROP='#5c1310';
function bloodFx(x,y,sx,sy,amt){
  if(typeof G==='undefined'||!G||G.sim||!isFinite(x)||!isFinite(y)) return;
  var k=Math.max(0.4,Math.min(1,(+amt||10)/30)), a=(isFinite(sx)&&isFinite(sy))?Math.atan2(y-sy,x-sx):fxn(0,6.283), d;
  spark(x,y,BLOOD_SPRAY,Math.round(3+4*k),150);
  G.puffs.push({x:x+Math.cos(a)*4,y:y+Math.sin(a)*3,t:0,life:.22,c:BLOOD_MIST,r:5+4*k});
  if(fxr()<0.55){ d=fxn(6,14); decal(x+Math.cos(a)*d,y+16+Math.sin(a)*d*0.5,BLOOD_DROP,fxn(2.2,4)*(0.7+0.5*k)); }
}
function spark(x,y,col,n,spread){
'@

SubRx @'
              spark(b.x,b.y,en.kind==='raider'?'#ff5a4a':'#ffc25c',9,220);
'@ @'
              if(en.kind==='raider') bloodFx(en.x,en.y-14,b.x-b.vx*0.05,b.y-b.vy*0.05,b.dmg); else spark(b.x,b.y,'#ffc25c',9,220);   // 2026-10-12 (blood): a pillager bleeds, a machine sparks
'@

SubRx @'
spark(b.x,b.y,'#ffc25c',8,200); hit=true; break;
'@ @'
if(en3.kind==='raider') bloodFx(en3.x,en3.y-14,b.x-b.vx*0.05,b.y-b.vy*0.05,b.dmg); else spark(b.x,b.y,'#ffc25c',8,200); hit=true; break;
'@

SubRx @'
if(!G.sim){ spark(e.x,e.y,e.kind==='raider'?'#ff5a4a':'#ffc25c',9,220); sfxHere('hit',e.x,e.y); }
'@ @'
if(!G.sim){ if(e.kind==='raider') bloodFx(e.x,e.y-14,sx,sy,10); else spark(e.x,e.y,'#ffc25c',9,220); sfxHere('hit',e.x,e.y); }
'@

SubRx @'
damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
'@ @'
damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); hit=true; }   // 2026-10-12 (blood): damagePlayer bleeds
'@

SubRx @'
if(!hit&&!_mOwn&&NET.on&&netBulletPeer(b)){ spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
'@ @'
if(!hit&&!_mOwn&&NET.on&&netBulletPeer(b)){ bloodFx(b.x,b.y,b.x-b.vx*0.05,b.y-b.vy*0.05,b.dmg); hit=true; }
'@

SubRx @'
    p.lastDmg=Math.round(amt); p.dmgPopT=1.05;
'@ @'
    p.lastDmg=Math.round(amt); p.dmgPopT=1.05;
    if(!G.sim) bloodFx(p.x,p.y-16,sx,sy,amt);   // 2026-10-12 (blood): a player bleeds, a little
'@

SubRx @'
var VER='25.50';
'@ @'
var VER='25.51';
'@

$pat = "(?m)^  now:'v25\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.51: Pillagers and players now bleed a little when hit; machines throw sparks as before. Check 25.51 fails on v25.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
