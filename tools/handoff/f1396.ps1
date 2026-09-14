$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'13.95',what:
'@ @'
  {v:'13.96',what:'an enemy charge does not turn your hire on you: an enemy pillager charge bursting 40 units from your hire leaves him out of chase, while an ordinary pillager beside the same blast gives chase (machine and pillager AI audit 2026-09-14, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof explodeFrag!=='function'||typeof mkRaider!=='function') return 'SKIP: no charges or pillagers in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       var Z=null, zi;
       for(zi=0;zi<g.zones.length&&!Z;zi++) if(losClear(g.zones[zi].x,g.zones[zi].y,g.zones[zi].x-40,g.zones[zi].y,g.map.segs)&&losClear(g.zones[zi].x,g.zones[zi].y,g.zones[zi].x-40,g.zones[zi].y+40,g.map.segs)) Z=g.zones[zi];
       if(!Z) return 'SKIP: no clear spot beside a ring';
       var M=mkRaider(Z.x,Z.y,null,false); M.merc=1; M.hostile=false; M.grudge=false; M.friendly=1; M.hp=1000; M.maxhp=1000; M.state='follow';
       var R=mkRaider(Z.x,Z.y+40,null,false); R.hostile=true; R.hp=1000; R.maxhp=1000; R.state='loot';
       var H=mkRaider(Z.x+1500,Z.y+1500,null,false); H.hostile=true;
       g.ents.length=0; g.ents.push(M); g.ents.push(R); g.ents.push(H);
       p.x=Z.x+900; p.y=Z.y-900; p.iv=99;
       explodeFrag({x:Z.x-40,y:Z.y+20,t:0,fuse:0,by:H,r:0});
       // CONTROL: an ordinary pillager in the blast gives chase.
       if(R.state!=='chase') return 'SKIP: the enemy charge did not set an ordinary pillager in its blast to chase, so nothing here can be measured';
       // THE FINDING: your hire in the same blast.
       if(M.state==='chase') bad.push('an enemy charge 40 units from your hire set him chasing, which the pillager chase branch turns on you');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
