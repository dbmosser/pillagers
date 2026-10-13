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

# GRENADES AND THE TRIPWIRE SOUND LIKE THEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function throwFrom(tk,cookT){
'@ @'
// v25.25 (usefoleye), HIS ORDER 2026-10-12 (about 21:10): "add sounds for bandaging, applying armor, etc". GRENADES AND THE TRIPWIRE
// SOUND LIKE THEM. The cook played one quiet synth clank, a quick throw pulled no pin at all, the throw left the hand in silence,
// a frag landed in silence until it blew, a smoke opened with no hiss, and a tripwire went down with the same clank as a smoke.
// Now (the v25.20 bank): the pin click and the spoon as the pin comes out (the cook and the quick throw), an arm whoosh as it
// leaves your hand, a metal knock where a frag lands, a pressure hiss where a smoke opens, a latch as a tripwire strings, and two
// short beeps at the mine the moment it arms (read off its own arming clock, never scheduled). Yours is centred; your teammates
// hear the pin and the throw where you stand, and anyone near the landing hears it there. Cosmetic only: no seeded draw, nothing
// under G.sim, no game state, and no noise ring (foley leaves none; the clank that draws the ring is kept).
function throwFoley(kind,x,y){
  if((G&&G.sim)||typeof foley!=='function') return false;
  if(kind==='pin'){ foley('pinClick',null,null,{rate:1.15}); foley('pinClick',null,null,{rate:1.9,g:0.45,dur:0.12,at:0.11,gap:0,local:1}); return true; }
  if(kind==='throw'){ foley('bandageWrap',null,null,{rate:1.7,g:0.8,dur:0.16}); return true; }
  if(kind==='land'){ foley('lmgClack',x,y,{rate:1.7,g:0.55}); return true; }
  if(kind==='smoke'){ foley('injector',x,y,{rate:0.55,g:1.2,at:0.08}); return true; }
  if(kind==='trip'){ foley('boltLatch',x,y,{rate:1.5,g:0.8}); return true; }
  if(kind==='armed'){ foley('keyBeep',x,y,{rate:1.25,g:0.9,dur:0.12,local:1}); foley('keyBeep',x,y,{rate:1.25,g:0.9,dur:0.12,at:0.16,gap:0,local:1}); return true; }
  return false;
}
function throwFrom(tk,cookT){
'@

SubRx @'
  G.throws.push({x:p.x,y:p.y,sx:p.x,sy:p.y,tx:tx,ty:ty,t:0,dur:Math.max(.25,rngT/430),kind:tk,cook:cookT||0});
'@ @'
  G.throws.push({x:p.x,y:p.y,sx:p.x,sy:p.y,tx:tx,ty:ty,t:0,dur:Math.max(.25,rngT/430),kind:tk,cook:cookT||0});
  throwFoley('throw');   // v25.25 (usefoleye): the arm whoosh
'@

SubRx @'
  G.pouch[tk]--; G.tel.thr[tk]++;
  throwFrom(tk,0);
'@ @'
  G.pouch[tk]--; G.tel.thr[tk]++;
  throwFoley('pin');   // v25.25 (usefoleye): a quick throw pulls the pin too
  throwFrom(tk,0);
'@

SubRx @'
  if(!G.sim) blip('clank');
  return true;
'@ @'
  if(!G.sim&&!throwFoley('pin')) blip('clank');   // v25.25 (usefoleye): the pin and the spoon
  return true;
'@

SubRx @'
sfx("clank",th.tx,th.ty); netThrSend('smoke',th.tx,th.ty); }
'@ @'
sfx("clank",th.tx,th.ty); throwFoley('smoke',th.tx,th.ty); netThrSend('smoke',th.tx,th.ty); }
'@

SubRx @'
    G.frags.push({x:th.tx,y:th.ty,t:0,fuse:Math.max(0.08,FRAG_FUSE-(th.cook||0)),mine:1});
'@ @'
    G.frags.push({x:th.tx,y:th.ty,t:0,fuse:Math.max(0.08,FRAG_FUSE-(th.cook||0)),mine:1});
    throwFoley('land',th.tx,th.ty);   // v25.25 (usefoleye): it lands with a knock
'@

SubRx @'
  if(!G.sim&&!seat) say('TRIPWIRE SET','info');
'@ @'
  if(!G.sim&&!seat) say('TRIPWIRE SET','info');
  if(!seat) throwFoley('trip',tr.x,tr.y);   // v25.25 (usefoleye): the latch as it strings
'@

SubRx @'
T=G.trips[i]; if(T.arm>0) T.arm-=dt; T.life-=dt;
'@ @'
T=G.trips[i]; if(T.arm>0){ T.arm-=dt; if(T.arm<=0) throwFoley('armed',T.x,T.y); } T.life-=dt;
'@

SubRx @'
var VER='25.24';
'@ @'
var VER='25.25';
'@

$pat = "(?m)^  now:'v25\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.25: Grenades now pull a pin, whoosh, knock where they land and hiss for smoke, and a tripwire latches and beeps as it arms. Check 25.25 fails on v25.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
