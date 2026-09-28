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

if ($s.Contains("  {v:'16.98',what:")) { throw "check 16.98 is in the fixture already" }

SubRx @'
  {v:'16.97',what:
'@ @'
  {v:'16.98',what:'a pillager player 2 downed who bleeds out keeps player 2 as his killer: in the frame he lies dead an enemy round, a host round and a host charge on the body leave the seat mark alone',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkRaider!=='function'||typeof updateEnts!=='function'||typeof updateBullets!=='function'||typeof explodeFrag!=='function'||typeof damagePlayer!=='function') return 'SKIP: no pillagers, rounds or charges in this build';
     var bad=[], g0=null, _say=say, _dp=damagePlayer, keepOn=(typeof NET==='object'&&NET)?NET.on:null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g0=g;
       if(keepOn!==null) NET.on=false;
       say=function(){}; damagePlayer=function(){};
       var M=null, Z=null, zi, q;
       for(zi=0;zi<g.ents.length&&!M;zi++){ q=g.ents[zi]; if(q&&q.kind!=='raider'&&q.kind!=='peddler'&&q.kind!=='stray'&&!q.merc) M=q; }
       if(!M) return 'SKIP: staging: no machine on the map to fire the enemy round';
       for(zi=0;zi<g.zones.length&&!Z;zi++) if(losClear(g.zones[zi].x,g.zones[zi].y,g.zones[zi].x+40,g.zones[zi].y,g.map.segs)) Z=g.zones[zi];
       if(!Z) return 'SKIP: no clear ground to stage the body on';
       var R=mkRaider(Z.x,Z.y,null,false);
       R.hostile=true; R.merc=0; R.roll=0;
       R.downed=1; R.downT=10; R.hp=0.000001; R.state='down'; R.finished=0; R.bySeat=1; R.byPlayer=false;
       g.ents.length=0; g.ents.push(R); g.bullets.length=0;
       p.x=Z.x+2000; p.y=Z.y+2000; p.iv=99;
       updateEnts(0.02);
       if(g.ents.indexOf(R)<0||!R.finished||R.hp>0) return 'SKIP: staging: the downed man did not bleed out and stay on the map for the frame (finished '+R.finished+', hp '+R.hp+')';
       if(R.bySeat!==1||R.byPlayer) return 'SKIP: staging: the bleed-out itself moved the kill mark (seat '+R.bySeat+', byPlayer '+!!R.byPlayer+')';
       function lay(){ R.hp=0; R.downed=0; R.finished=1; R.bySeat=1; R.byPlayer=false; R.roll=0; R.x=Z.x; R.y=Z.y; g.ents.length=0; g.ents.push(R); g.bullets.length=0; }
       function mark(){ return 'seat '+R.bySeat+', byPlayer '+!!R.byPlayer; }
       lay(); g.bullets.push({x:R.x,y:R.y,vx:0.01,vy:0,dmg:20,life:0.5,player:false,owner:M,tint:'#ffffff',thru:0}); updateBullets(0.001);
       if(R.bySeat!==1||R.byPlayer) bad.push('an enemy round on the bled-out body rewrote the kill mark ('+mark()+')');
       lay(); g.bullets.push({x:R.x,y:R.y,vx:0.01,vy:0,dmg:20,life:0.5,player:true,owner:p,tint:'#ffffff',thru:0}); updateBullets(0.001);
       if(R.bySeat!==1||R.byPlayer) bad.push('a host round on the bled-out body rewrote the kill mark ('+mark()+')');
       lay(); explodeFrag({x:R.x,y:R.y});
       if(R.bySeat!==1||R.byPlayer) bad.push('a host charge on the bled-out body rewrote the kill mark ('+mark()+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say; damagePlayer=_dp;
       try{ if(keepOn!==null) NET.on=keepOn; }catch(_n){}
       try{ if(g0){ g0.bullets.length=0; if(g0.player) g0.player.iv=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
