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

# A GUN KEEPS ITS QUALITY IN THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function takeRounds(id,mag){
  var m=G.stowAmmo, q=m&&m[id];
  if(q&&q.length) return Math.min(mag,Math.max(0,q.shift()|0));
  return Math.ceil(mag/2);
}
'@ @'
function takeRounds(id,mag){
  var m=G.stowAmmo, q=m&&m[id];
  if(q&&q.length) return Math.min(mag,Math.max(0,q.shift()|0));
  return Math.ceil(mag/2);
}
// v21.79, the four-gun belt, build 1: A GUN KEEPS ITS ROLLED QUALITY IN THE BACKPACK. The backpack holds a bare key string, so a gun
// put in it lost everything the roll gave it: its rolled name, grade, tint, damage, magazine, rate, reload and spread, and it came
// back out as a plain field gun with the base magazine (a rolled magazine of 31 came back as 25, and its rounds were cut to fit).
// The gun itself now rides here beside its rounds, a shallow copy per gun id, first in first out like G.stowAmmo, because two of
// the same gun in the backpack are indistinguishable. The list is trimmed to the copies of that gun still in the backpack, oldest
// first, so a gun that leaves by any other way (dropped, sold, given) takes its quality with it, and his own discards searched back
// up off a pile still come back at field grade (the anti-reroll rule in grantLoot). No seeded draw: a found gun pushes the roll
// grantLoot already made for it.
function gunQCount(id){
  var k='gun_'+id, n=0, b=(G&&G.bag)||[];
  for(var i=0;i<b.length;i++) if(b[i]===k) n++;
  return n;
}
function gunQTrim(id,n){
  var q=G.stowQ&&G.stowQ[id]; if(!q) return;
  if(n===undefined) n=gunQCount(id);
  while(q.length>Math.max(0,n)) q.shift();
}
// Called right after the gun's key went into G.bag.
function gunQPush(w){
  if(!w||!w.id||w.id==='fists'||w.mag===0) return;
  gunQTrim(w.id,gunQCount(w.id)-1);
  var c={}; for(var k in w) c[k]=w[k];
  var m=(G.stowQ=G.stowQ||{});
  (m[w.id]=m[w.id]||[]).push(c);
}
// The copy that comes out next, read only (the belt draws it).
function gunQPeek(id){
  var q=G&&G.stowQ&&G.stowQ[id], n=gunQCount(id);
  if(!q||!q.length||n<=0) return null;
  return q[Math.max(0,q.length-n)]||null;
}
function gunQTake(id){
  var q=G.stowQ&&G.stowQ[id];
  return (q&&q.length)?q.shift():null;
}
'@

SubRx @'
  stowRounds(g.id,isHand?p.ammo:p.secAmmo);   // v12.42: the load goes with it
'@ @'
  stowRounds(g.id,isHand?p.ammo:p.secAmmo);   // v12.42: the load goes with it
  gunQPush(g);   // v21.79: and its rolled quality
'@

SubRx @'
          G.bag.push('gun_'+p.sec.id);
          stowRounds(p.sec.id,p.secAmmo);
'@ @'
          G.bag.push('gun_'+p.sec.id);
          stowRounds(p.sec.id,p.secAmmo);
          gunQPush(p.sec);   // v21.79: with its rolled quality
'@

SubRx @'
            stowRounds(p.wep.id,p.ammo);   // v12.42: the gun a field pickup displaces keeps its load
'@ @'
            stowRounds(p.wep.id,p.ammo);   // v12.42: the gun a field pickup displaces keeps its load
            gunQPush(p.wep);   // v21.79: and its rolled quality
'@

SubRx @'
      } else { G.bag.push(key); _beltGot=autoBelt(key); if(_beltGot) _beltKeep.push(_beltGot); }
    }
'@ @'
      } else {
        G.bag.push(key);
        // v21.79: the roll above goes into the backpack with it. A pile he dropped was rolled at field grade above and keeps nothing:
        // the copy it left with is trimmed away, so a dropped Pristine gun searched back up is a field gun (the anti-reroll rule).
        if(ct&&ct.dropped) gunQTrim(itm.gk,gunQCount(itm.gk)-1); else gunQPush(found);
        _beltGot=autoBelt(key); if(_beltGot) _beltKeep.push(_beltGot);
      }
    }
'@

SubRx @'
  // A bagged gun carries no quality of its own, so it comes back at field grade,
  // matching the anti-reroll rule on dropped guns.

'@ @'
  // A bagged gun with no copy kept (v21.79, gunQPush) comes back at field grade,
  // matching the anti-reroll rule on dropped guns.

'@

SubRx @'
  G.bag.splice(ix,1);
  var _oldLine='';   // v12.84: what happened to the gun this one displaces
'@ @'
  gunQTrim(gk);   // v21.79: line the copies up with the guns still in the backpack
  G.bag.splice(ix,1);
  // v21.79: the gun comes back as it went in: rolled name, grade, tint and stats, and its rounds against its own magazine below.
  // Taken before the displaced gun goes in, so two of the same gun never trade copies.
  var _gq=gunQTake(gk);
  if(_gq){ g={}; for(var _gqk in _gq) g[_gqk]=_gq[_gqk]; }
  var _oldLine='';   // v12.84: what happened to the gun this one displaces
'@

SubRx @'
      G.bag.push('gun_'+oldW.id); stowRounds(oldW.id,toSec?p.secAmmo:p.ammo);
      if(!G.sim){ var _swi
'@ @'
      G.bag.push('gun_'+oldW.id); stowRounds(oldW.id,toSec?p.secAmmo:p.ammo); gunQPush(oldW);   // v21.79: with its quality
      if(!G.sim){ var _swi
'@

SubRx @'
    else { G.bag.push('gun_'+oldW.id); stowRounds(oldW.id,toSec?p.secAmmo:p.ammo); }   // v12.42: and the displaced gun keeps its load too
'@ @'
    else { G.bag.push('gun_'+oldW.id); stowRounds(oldW.id,toSec?p.secAmmo:p.ammo); gunQPush(oldW); }   // v12.42: and the displaced gun keeps its load too (v21.79: and its quality)
'@

SubRx @'
    } else {
      out[aix]={k:'item:'+akey,name:ait.name,icon:akey,
'@ @'
    } else {
      // v21.79: a gun in the backpack reads as the gun that will come out: its rolled name and tint, not the plain item name.
      var _sq=(_agk&&have>0)?gunQPeek(_agk):null;
      out[aix]={k:'item:'+akey,name:(_sq&&_sq.name)||ait.name,icon:akey,
'@

SubRx @'
count:have,c:ait.c||'#cdd6dd',assigned:1,itemKey:akey,empty:(have<=0)?1:0};
'@ @'
count:have,c:(_sq&&_sq.tint)||ait.c||'#cdd6dd',assigned:1,itemKey:akey,empty:(have<=0)?1:0};
'@

SubRx @'
var VER='21.78';
'@ @'
var VER='21.79';
'@

$pat = "(?m)^  now:'v21\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.79: A gun keeps its name, grade and rounds when it goes into the backpack and comes back out. Check 21.79 fails on v21.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
