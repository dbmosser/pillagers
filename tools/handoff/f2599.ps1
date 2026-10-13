$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'25.99',what:")) { throw "check 25.99 is in the fixture already" }

SubRx @'
  {v:'25.98',what:
'@ @'
  {v:'25.99',what:'his order (redo the bar at the bottom), the pad walk: with two guns, a Frag on key 5, a Bandage on key 7 and nothing else, RB from key 2 goes over the vacant gun keys 3 and 4 to key 5, RB from key 5 goes over the empty key 6 to key 7, RB from key 7 goes over the empty keys 8 and 9 round to key 1, and LB from key 1 goes back over keys 9 and 8 to key 7',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof beltStep!=='function'||typeof hotbarSlots!=='function'||!WEAPONS.rifle||!WEAPONS.smg||!ITEMS.bandage||!ITEMS.frag) return 'SKIP: no pad walk or belt items here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], s0=say, g=null, p=null;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function walk(from,dir){ g.hot=from; beltStep(dir); return g.hot; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; say=function(){};
       p.wep=cl('rifle'); p.ammo=p.wep.mag; p.sec=cl('smg'); p.secAmmo=p.sec.mag; p.swapped=false; p.reloading=0; p.roll=0; p.downed=false;
       g.bag=['bandage']; g.pouch.frag=1; g.pouch.smoke=0; g.pouch.decoy=0; g.pouch.trip=0; g.hotAssign={}; g.hotAuto={}; g.hotPruned={};
       var sl=hotbarSlots();
       if(!(sl[4]&&sl[4].k==='throw:frag'&&sl[5]&&sl[5].kind==='empty'&&sl[6]&&sl[6].itemKey==='bandage'&&sl[7]&&sl[7].kind==='empty'&&sl[8]&&sl[8].kind==='empty'&&sl[2]&&sl[2].vacant&&sl[3]&&sl[3].vacant)) return 'SKIP: staging: the belt is not two guns, a Frag on key 5, a Bandage on key 7 and nothing else ('+sl.map(function(c){ return c?c.k:'-'; }).join(', ')+')';
       if(walk(1,1)!==4) bad.push('RB from key 2 landed on key '+(g.hot+1)+', not key 5');
       if(walk(4,1)!==6) bad.push('RB from key 5 landed on key '+(g.hot+1)+', not key 7 (over the empty key 6)');
       if(walk(6,1)!==0) bad.push('RB from key 7 landed on key '+(g.hot+1)+', not key 1 (over the empty keys 8 and 9)');
       if(walk(0,-1)!==6) bad.push('LB from key 1 landed on key '+(g.hot+1)+', not key 7 (over keys 9 and 8)');
       if(walk(6,-1)!==4) bad.push('LB from key 7 landed on key '+(g.hot+1)+', not key 5');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hot=0; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
