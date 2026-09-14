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
  {v:'13.68',what:
'@ @'
  {v:'13.69',what:'your own charge does not kill your hire: a charge of yours bursting 40 units from him leaves his health and the kill ledger untouched and does not set him chasing you, while an enemy charge in the same spot still wounds him (hire and peddler audit 2026-09-14, finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof explodeFrag!=='function'||typeof mkRaider!=='function'||typeof idRec!=='function') return 'SKIP: no charges or pillagers in this build';
     var bad=[], P2=__P(), keepRiv=JSON.stringify(P2.rivals||{});
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g.zones||!g.zones.length) return 'SKIP: no open ground to stage on';
       var Z=null, zi;
       for(zi=0;zi<g.zones.length&&!Z;zi++) if(losClear(g.zones[zi].x,g.zones[zi].y,g.zones[zi].x-40,g.zones[zi].y,g.map.segs)) Z=g.zones[zi];
       if(!Z) return 'SKIP: no clear spot beside a ring';
       var M=mkRaider(Z.x,Z.y,null,false); M.merc=1; M.hostile=false; M.grudge=false; M.friendly=1;
       var R=mkRaider(Z.x+900,Z.y+900,null,false); R.hostile=true;
       g.ents.length=0; g.ents.push(M); g.ents.push(R);
       p.x=Z.x+900; p.y=Z.y-900; p.iv=99;
       var kills0=idRec(M.ident).kills||0;
       // THE FINDING: your charge, 40 units from him.
       M.x=Z.x; M.y=Z.y; M.hp=78; M.maxhp=78; M.state='follow'; M.byPlayer=false;
       explodeFrag({x:Z.x-40,y:Z.y,t:0,fuse:0,by:null,r:0});
       if(M.hp<78) bad.push('your own charge 40 units from your hire took him from 78 to '+Math.round(M.hp));
       if(M.hp<=0&&M.byPlayer) bad.push('and his death is marked as your kill');
       if(M.state==='chase') bad.push('your charge set your hire chasing you');
       if((idRec(M.ident).kills||0)!==kills0) bad.push('a kill of him was written to the ledger');
       // CONTROL: an enemy charge in the same spot wounds him.
       M.x=Z.x; M.y=Z.y; M.hp=1000; M.maxhp=1000; M.state='follow';
       explodeFrag({x:Z.x-40,y:Z.y,t:0,fuse:0,by:R,r:0});
       if(!(M.hp<1000)) bad.push('control: an enemy charge 40 units from the hire did not hurt him, so this check cannot see a blast');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.rivals=JSON.parse(keepRiv); saveProfile(); }catch(_r){}
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; } if(g2){ g2.mercDead=0; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
