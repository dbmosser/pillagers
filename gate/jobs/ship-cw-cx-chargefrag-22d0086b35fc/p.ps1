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

# HURT PILLAGERS CHARGE OR FLEE AND EVADE GRENADES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(e.kind==='raider'&&!e.golden&&e.state!=='extract'&&!e.cornered&&e.hp<e.maxhp*0.3){   // v23.xx: a man who turned on the one shooting him (runnerTurns) does not bolt again
      e.state='extract';
      if(!e.fled){
        e.fled=1;
        if(CFG.raiderKit!==0&&(e.smkT===undefined||e.smkT<=0)){
          e.smkT=14;
          G.smokes.push({x:e.x,y:e.y,r:smokeRad(),t:0,life:12});
          netThrSend('smoke',e.x,e.y);   // v21.98 (K8, K15): and the cloud he drops as he runs
          if(!G.sim) sfx('clank',e.x,e.y);
        }
        if(!G.sim&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)) label(e.x,e.y-18,e.name+' IS RUNNING','#ffc04a',0,true);
      }
    }
'@ @'
if(e.kind==='raider'&&!e.golden&&e.state!=='extract'&&!e.cornered&&e.hp<e.maxhp*0.3){   // v23.xx: a man who turned on the one shooting him (runnerTurns) does not bolt again
      // v28.xx (cw-cx-chargefrag): his g-23 answer, "Some back off, some charge". No seeded draw.
      if(e.hostile&&!e.merc&&!e.friendlyPC){
        if(e.brave===undefined) e.brave=((Math.imul((e.nid|0)||Math.round(e.x*7+e.y),2654435761)>>>0)%10<4)?1:0;
      }
      if(e.hostile&&!e.merc&&!e.friendlyPC&&e.brave&&runnerTurns(e,p.x,p.y)){
        e.rushT=4;
      } else {
      e.state='extract';
      if(!e.fled){
        e.fled=1;
        if(CFG.raiderKit!==0&&(e.smkT===undefined||e.smkT<=0)){
          e.smkT=14;
          G.smokes.push({x:e.x,y:e.y,r:smokeRad(),t:0,life:12});
          netThrSend('smoke',e.x,e.y);   // v21.98 (K8, K15): and the cloud he drops as he runs
          if(!G.sim) sfx('clank',e.x,e.y);
        }
        if(!G.sim&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)) label(e.x,e.y-18,e.name+' IS RUNNING','#ffc04a',0,true);
      }
      }
    }
'@

SubRx @'
    if(_se.shotT>0){ _se.shotT-=dt; if(_se.shotT<0) _se.shotT=0; }
'@ @'
    // v28.xx (cw-cx-chargefrag): four real seconds, even while dodging or outside chase.
    if(_se.rushT>0) _se.rushT=Math.max(0,_se.rushT-dt);
    if(_se.shotT>0){ _se.shotT-=dt; if(_se.shotT<0) _se.shotT=0; }
'@

SubRx @'
        if(e.pinT>0){
'@ @'
        // v28.xx (cw-cx-chargefrag): a brave hurt pillager commits to the charge before cover or retreat.
        if(e.rushT>0) navSeek(e,sees?p.x:e.tx,sees?p.y:e.ty,e.spd*1.25,dt);
        else if(e.pinT>0){
'@

SubRx @'
    if(sees&&!(e.merc&&!e.downed&&(
'@ @'
    // v28.xx (cw-cx-chargefrag): his g-28 answer, "They run from it". Hires and party fx copies too; no dice or sim fence.
    if(e.kind==='raider'&&!e.downed&&G.frags&&G.frags.length){
      var _fgR=(CFG.fragR===undefined?190:CFG.fragR),_fgHit=false;
      for(var _fgi=0;_fgi<G.frags.length;_fgi++){
        var _fg=G.frags[_fgi];
        if(_fg.by===e||_fg.t<0.15||_fg.t>=_fg.fuse) continue;
        var _fgD=Math.hypot(e.x-_fg.x,e.y-_fg.y);
        if(_fgD>=_fgR+16||(_fgD>120&&!losClear(e.x,e.y,_fg.x,_fg.y,G.vseg))) continue;
        var _fgA=_fgD>0.5?Math.atan2(e.y-_fg.y,e.x-_fg.x):e.face;
        moveToward(e,_fg.x+Math.cos(_fgA)*(_fgR+30),_fg.y+Math.sin(_fgA)*(_fgR+30),e.spd*1.35,dt);
        e.moving=true; _fgHit=true; break;
      }
      if(_fgHit){ collide(e,G.map.walls); continue; }
    }
    if(sees&&!(e.merc&&!e.downed&&(
'@

SubRx @'
var VER='37.49';
'@ @'
var VER='37.50';
'@

$pat = "(?m)^  now:'v37\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.50: About forty percent of hurt hostile pillagers charge for four seconds rather than smoke and flee. All standing pillagers run from live grenades after a short reaction, including hires, simulated raids and party copies. Golden pillagers keep their exemption. LINKED REVIEW NEEDED: synced; host movement reaches the peer through netEntRow positions and state. Check 37.50 fails on v37.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
