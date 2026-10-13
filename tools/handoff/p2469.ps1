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

# KEYCARDS IN THE WORLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
function arcadePostBuild(g){
'@ @'
// v23.9x (feat4c), HIS ORDER (2026-10-12): "32 more interiors". KEYCARDS IN THE WORLD. Built with the vaults (feat4b), one Vault Keycard
// per vault goes into an ordinary box (crate, locker or safe) that can be reached and stands clear of every locked room, drawn on its
// own side stream, so both windows put it in the same box and nothing else moves. And the fight pays one out: while a vault is
// shut, every elite (or the boss) a player kills drops a KEYCARD box where it fell, and so does every 12th kill when no keycard is
// left in the world. Only the run authority drops it (the host, or the player 2 that took the raid over); the box reaches the other
// window as any new box does. The drop rolls on the cosmetic stream (fxBorrow), never the seeded one. Opening a vault pays the
// opener VAULT OPEN +$500 on his own score.
var ARCADE_KEYCARD_TAG=8, ARCADE_KEYCARD_EVERY=12, ARCADE_VAULT_PAY=500;
function arcadeKeycards(g){
  var m=g&&g.map, V, L, out=0, cands=[], i, j, c, ok;
  if(!m||!ITEMS.keycard||!Array.isArray(g.containers)) return 0;
  L=m.locked||[]; V=L.filter(function(R){ return R.arc; });
  if(!V.length) return 0;
  for(i=0;i<g.containers.length;i++){
    c=g.containers[i];
    if(!c||c.cache||c.strong||c.opened||c.dropped||(c.type!=='crate'&&c.type!=='locker'&&c.type!=='safe')) continue;
    ok=true;
    for(j=0;j<L.length&&ok;j++){ if(c.x>L[j].x-40&&c.x<L[j].x+L[j].w+40&&c.y>L[j].y-40&&c.y<L[j].y+L[j].h+40) ok=false; }
    if(ok&&typeof navReachable==='function'&&!navReachable(m,c.x,c.y)) ok=false;
    if(ok) cands.push(c);
  }
  if(!cands.length) return 0;
  sideStream(g.seed,ARCADE_KEYCARD_TAG,function(){
    for(var q=0;q<V.length&&cands.length;q++){ var b=cands.splice(ri(0,cands.length-1),1)[0]; b.loot.push('keycard'); setLoot(b,b.loot); out++; }
  });
  return out;
}
function arcadeKeycardOut(){
  var i, c;
  for(i=0;i<G.containers.length;i++){ c=G.containers[i]; if(c&&c.loot&&c.loot.indexOf('keycard')>=0) return true; }
  return !!(G.bag&&G.bag.indexOf('keycard')>=0);
}
function arcadeKeycardDrop(e){
  var L, i, shut=false, ct=null;
  if(!G||!G.arcade||G.sim||G.over||!e||!ITEMS.keycard||!ARCADE.on) return null;
  if((ARCADE.role==='p2'&&!G.netWasJoin)||(typeof netEntsPeer==='function'&&netEntsPeer())) return null;   // the run authority only
  L=G.map.locked||[]; for(i=0;i<L.length;i++) if(L[i].arc&&!L[i].open) shut=true;
  if(!shut) return null;
  G.arcKillN=(G.arcKillN|0)+1;
  if(!(e.elite||e.boss)&&((G.arcKillN%ARCADE_KEYCARD_EVERY)!==0||arcadeKeycardOut())) return null;
  fxBorrow(function(){ ct=setLoot(mkContainer(e.x+16,e.y+10,'botwreck'),['keycard']); });
  ct.time=.6; ct.tag='KEYCARD'; G.containers.push(ct);
  try{ say('KEYCARD DROPPED','obj'); }catch(_kd){}
  return ct;
}
function arcadeVaultPay(R){
  if(!ARCADE.on||!G||!G.arcade||!R) return undefined;
  ARCADE.mine=(ARCADE.mine|0)+ARCADE_VAULT_PAY;
  try{ label(R.doorX,R.doorY-30,'+'+arcadeCr(ARCADE_VAULT_PAY),'#ffc04a',0,true); }catch(_vl){}
  try{ arcadeScSend(); }catch(_vs){}
  return {sub:'+'+arcadeCr(ARCADE_VAULT_PAY)};
}
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
function arcadePostBuild(g){
'@

SubRx @'
  try{ arcadeVaults(g); }catch(_av){}   // v23.9x (feat4b): two strongrooms sealed into vaults (side stream)
'@ @'
  try{ arcadeVaults(g); }catch(_av){}   // v23.9x (feat4b): two strongrooms sealed into vaults (side stream)
  try{ arcadeKeycards(g); }catch(_ak){}   // v23.9x (feat4c): a keycard per vault in a box outside (side stream)
'@

SubRx @'
        G.containers.push(c3);
      }
      // Only announce a kill you could actually witness. Machines and raiders
'@ @'
        G.containers.push(c3);
      }
      if(G.arcade&&!G.sim&&(e.byPlayer||e.bySeat>0)){ try{ arcadeKeycardDrop(e); }catch(_akd){} }   // v23.9x (feat4c): an elite, or every 12th kill, drops a keycard
      // Only announce a kill you could actually witness. Machines and raiders
'@

SubRx @'
      say((doorNear.name+' open').toUpperCase(),'obj'); blip('pick'); ping(p.x,p.y,340,false,false,'player','move');   // v22.xx (R53): an objective row in caps
'@ @'
      var _vop=(G.arcade&&doorNear.arc)?arcadeVaultPay(doorNear):undefined;   // v23.9x (feat4c): VAULT OPEN +$500 to the opener
      say((doorNear.name+' open').toUpperCase(),'obj',_vop); blip('pick'); ping(p.x,p.y,340,false,false,'player','move');   // v22.xx (R53): an objective row in caps
'@

SubRx @'
var VER='24.68';
'@ @'
var VER='24.69';
'@

$pat = "(?m)^  now:'v24\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.69: Keycards hide in boxes and drop from elites, and a vault pays 500 when opened. Check 24.69 fails on v24.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
