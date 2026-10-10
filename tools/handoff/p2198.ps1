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

# EVERYONE SEES THE CHARGES AND THE SHELLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netThrSend(k,x,y){
  var i, m;
  if(!netUpShared()) return false;
  if(k==='nz'&&NET.role==='host') return false;   // the host own blast already reached the enemies it runs
  m={t:'thr',k:k,x:Math.round(x),y:Math.round(y)};
'@ @'
function netThrSend(k,x,y,ex){
  var i, m, f;
  if(!netUpShared()) return false;
  if(k==='nz'&&NET.role==='host') return false;   // the host own blast already reached the enemies it runs
  m={t:'thr',k:k,x:Math.round(x),y:Math.round(y)};
  if(ex) for(f in ex) if(Object.prototype.hasOwnProperty.call(ex,f)) m[f]=ex[f];   // v21.98 (K8, K15): a charge carries its fuse, a shell where it was fired from and its time in the air
'@

SubRx @'
function netThrTake(peer,m){
  var i, q, x, y, k=m.k;
  if(!peer||peer.state!=='in') return 'ignored';
  if(!netUpShared()) return 'off';
  if(k!=='smoke'&&k!=='decoy'&&k!=='nz') return 'bad';
  if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
  x=clamp(m.x,-9000,NET_UP_MAX); y=clamp(m.y,-9000,NET_UP_MAX);
  if(k==='nz'){ if(NET.role!=='host') return 'ignored'; ping(x,y,560,false,false,'env','fire'); return 'thr:nz'; }
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q!==peer&&q.state==='in') netSend(q,{t:'thr',k:k,x:x,y:y}); }
'@ @'
function netThrTake(peer,m){
  var i, q, x, y, k=m.k, w, fu, x0, y0;
  if(!peer||peer.state!=='in') return 'ignored';
  if(!netUpShared()) return 'off';
  if(k!=='smoke'&&k!=='decoy'&&k!=='nz'&&k!=='frag'&&k!=='sh') return 'bad';   // v21.98 (K8, K15): and a charge or a Howler shell, drawn here only
  if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
  x=clamp(m.x,-9000,NET_UP_MAX); y=clamp(m.y,-9000,NET_UP_MAX);
  if(k==='nz'){ if(NET.role!=='host') return 'ignored'; ping(x,y,560,false,false,'env','fire'); return 'thr:nz'; }
  if(k==='sh'){
    if(NET.role==='host') return 'ignored';   // only the host runs the Howlers
    x0=(typeof m.x0==='number'&&isFinite(m.x0))?clamp(m.x0,-9000,NET_UP_MAX):x; y0=(typeof m.y0==='number'&&isFinite(m.y0))?clamp(m.y0,-9000,NET_UP_MAX):y;
    G.shells.push({mortar:1,fx:1,x0:x0,y0:y0,tx:x,ty:y,t:0,air:clamp(+m.air||2.1,0.2,5),dmg:0});
    return 'thr:sh';
  }
  w={t:'thr',k:k,x:x,y:y};
  if(k==='frag'){ fu=clamp(+m.f||FRAG_FUSE,0.05,3); w.f=fu; }
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q!==peer&&q.state==='in') netSend(q,w); }
  if(k==='frag'){ G.frags.push({x:x,y:y,t:0,fuse:fu,fx:1}); return 'thr:frag'; }
'@

SubRx @'
    if(SH.t>=SH.air){ G.shells.splice(shI,1); howlerImpact(SH); }
'@ @'
    // v21.98, from the whole-game bug hunt of 2026-10-08 (K8, K15): EVERY WINDOW SEES THE SHELLS, THE CHARGES AND THE SMOKE. A
    // Howler shell, a pillager charge and a pillager smoke were only ever made in the host window, and a charge a player threw only
    // in his own, so player 2 saw no landing ring, no charge at his feet and no cloud, yet the blast still reached him. Each shell
    // and charge is now told to the party the first frame it exists, and the other windows draw a copy (fx) that only shows the
    // ring, the charge and the flash. The real one, in the window that made it, still does the damage, the sound and the noise, so
    // nothing lands twice, and a copy is never told on again. Solo play sends nothing (netThrSend returns at once).
    if(!SH.fx&&!SH.nsent){ SH.nsent=1; netThrSend('sh',SH.tx,SH.ty,{x0:Math.round(SH.x0),y0:Math.round(SH.y0),air:+Math.max(0.2,SH.air-SH.t).toFixed(2)}); }
    if(SH.t>=SH.air){
      G.shells.splice(shI,1);
      if(SH.fx){ if(!G.sim){ spark(SH.tx,SH.ty,'#ff9a5c',22,300); decal(SH.tx,SH.ty,'#181310',fxn(14,20)); G.puffs.push({x:SH.tx,y:SH.ty,t:0,life:.5,c:'#ff9a5c',r:40}); } G.shake=Math.max(G.shake,6); flash(SH.tx,SH.ty,220,'#ff9a5c',.4); }   // a copy only shows the burst
      else howlerImpact(SH);
    }
'@

SubRx @'
    if(fr.t>=fr.fuse){ explodeFrag(fr); G.frags.splice(i,1); }
'@ @'
    if(!fr.fx&&!fr.nsent){ fr.nsent=1; netThrSend('frag',fr.x,fr.y,{f:+Math.max(0.05,fr.fuse-fr.t).toFixed(2)}); }   // v21.98 (K8, K15): the party sees it lie there
    if(fr.t>=fr.fuse){
      if(fr.fx){ if(!G.sim){ spark(fr.x,fr.y,'#ffcf7a',34,340); decal(fr.x,fr.y,'#141210',fxn(20,30)); G.puffs.push({x:fr.x,y:fr.y,t:0,life:.6,c:'#ffb267',r:52}); } G.shake=Math.max(G.shake,9); flash(fr.x,fr.y,310,'#ffb267',.45); }   // a copy only shows the blast
      else explodeFrag(fr);
      G.frags.splice(i,1);
    }
'@

SubRx @'
    e.smkT=14;
    G.smokes.push({x:e.x,y:e.y,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
'@ @'
    e.smkT=14;
    G.smokes.push({x:e.x,y:e.y,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
    netThrSend('smoke',e.x,e.y);   // v21.98 (K8, K15): the party sees his cloud too, as the host enemies already do
'@

SubRx @'
          e.smkT=14;
          G.smokes.push({x:e.x,y:e.y,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
'@ @'
          e.smkT=14;
          G.smokes.push({x:e.x,y:e.y,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
          netThrSend('smoke',e.x,e.y);   // v21.98 (K8, K15): and the cloud he drops as he runs
'@

SubRx @'
var VER='21.97';
'@ @'
var VER='21.98';
'@

$pat = "(?m)^  now:'v21\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.98: In co-op, both players now see Howler shells landing, every charge on the ground and pillager smoke. Check 21.98 fails on v21.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
