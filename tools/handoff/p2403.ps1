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

# THE FORGE: THE UPGRADE MODEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  g.q=Q.q; g.qRank=Q.rank;
  return g;
}
var ITEMS={
'@ @'
  g.q=Q.q; g.qRank=Q.rank;
  return g;
}
// v23.xx, THE FORGE (2026-10-12), forge2. HIS IDEA: "a pack-a-punch mechanism to upgrade guns and add elemental damage would be
// cool", then "in-raid only", "yeah that sounds great" and "if you extract with an upgraded gun you get to keep it". THE MODEL, pure:
// no caller makes a forged gun yet (the station and the wheel are later builds). MK II (fk 1) is about +30 percent damage a round (a
// pellet gun per pellet), a quarter more magazine (at least one more round) and a fifth off the reload; MK III (fk 2) is the same plus
// an element (ELEM). Fire rate, spread, range, noise, pellets, burst and optic never change. forgeApply returns a fresh copy (WEAPONS
// is never touched) and always works from the gun as it was before any forge (f0), so forging twice never compounds and a rolled
// quality is kept. Guns never wear or jam: an upgrade never decays. The rank of a forged gun is its model tier plus its MK, so the stat
// card verdict and the DEMO routing never call a MK III rifle a downgrade against a plain Support MG. No draw on any stream.
var FORGE_COST=[2500,6000];
var FORGE_MUL={dmg:1.30,mag:1.25,reload:0.80};
var FORGE_GOLD='#ffc94a';
var ELEM={
  fire:{id:'fire',name:'FIRE',c:'#ff4f2a',snd:'elFire',w2:'BURN \u00b7 PANIC'},
  shock:{id:'shock',name:'SHOCK',c:'#5aa8ff',snd:'elShock',w2:'CHAIN \u00b7 STUN'},
  cryo:{id:'cryo',name:'CRYO',c:'#c8f0ff',snd:'elCryo',w2:'SLOW \u00b7 FREEZE'},
  acid:{id:'acid',name:'ACID',c:'#9cff4a',snd:'elAcid',w2:'SHRED \u00b7 ANTI-MACHINE'}
};
var ELEM_ORDER=['fire','shock','cryo','acid'];
function forgeMk(fk){ return fk===2?' MK III':(fk===1?' MK II':''); }
function forgeName(gk,fk){ var b=WEAPONS[gk]; return (b?b.name:String(gk||''))+forgeMk(fk|0); }
function gunTierOf(w){ return w?((WTIER[w.id]||0)+((w.fk===1||w.fk===2)?w.fk:0)):0; }
function forgeApply(w,fk,el){
  var base=w&&WEAPONS[w.id], g={}, k, s;
  if(!base||!(base.mag>0)) return w;
  fk=(fk===2)?2:((fk===1)?1:0);
  for(k in w) g[k]=w[k];
  s=w.f0||{dmg:w.dmg,mag:w.mag,reload:w.reload,name:w.name,tint:w.tint};
  g.dmg=s.dmg; g.mag=s.mag; g.reload=s.reload; g.name=s.name; g.tint=s.tint;
  delete g.fk; delete g.el; delete g.f0;
  if(!fk) return g;
  g.f0={dmg:s.dmg,mag:s.mag,reload:s.reload,name:s.name,tint:s.tint};
  g.dmg=Math.round(s.dmg*FORGE_MUL.dmg*10)/10;
  g.mag=Math.max(Math.ceil(s.mag*FORGE_MUL.mag),s.mag+1);
  g.reload=Math.round(s.reload*FORGE_MUL.reload);
  g.name=s.name+forgeMk(fk);
  g.fk=fk;
  if(fk===2&&ELEM[el]){ g.el=el; g.tint=ELEM[el].c; } else g.tint=FORGE_GOLD;
  return g;
}
var ITEMS={
'@

SubRx @'
tier:WTIER[w.id]||0,dmg:Math.round(per)
'@ @'
tier:gunTierOf(w),dmg:Math.round(per)
'@

SubRx @'
st=real(p.sec)?(WTIER[p.sec.id]||0):-1;
'@ @'
st=real(p.sec)?gunTierOf(p.sec):-1;   // v23.xx (forge2): a forged stowed gun ranks by its MK too
'@

SubRx @'
  if(real(p.wep)) worst=Math.min(worst,WTIER[p.wep.id]||0);
  if(real(p.sec)) worst=Math.min(worst,WTIER[p.sec.id]||0);
'@ @'
  if(real(p.wep)) worst=Math.min(worst,gunTierOf(p.wep));
  if(real(p.sec)) worst=Math.min(worst,gunTierOf(p.sec));
'@

SubRx @'
var VER='24.02';
'@ @'
var VER='24.03';
'@

$pat = "(?m)^  now:'v24\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.03: The upgrade model for the Forge is in, ready for the station. Check 24.03 fails on v24.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
