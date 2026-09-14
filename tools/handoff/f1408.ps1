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
  {v:'14.07',what:
'@ @'
  {v:'14.08',what:'going down lets go of the search and the door prompt: shot to the floor halfway through a search beside a locked door, both the search and the door prompt are cleared, while a hit that does not down him leaves the search running (raid HUD and map screen audit 2026-09-15, finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof damagePlayer!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function') return 'SKIP: no damage or crates in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0;
       var box=setLoot(mkContainer(p.x+20,p.y,'crate'),['scrap','wire','board']); g.containers.push(box);
       var door={doorX:p.x-30,doorY:p.y,x:p.x-40,y:p.y,w:20,h:4};
       function stand(){ p.downed=false; p.downT=0; p.revived=false; p.dying=false; p.hp=100; p.maxhp=100; p.armor=0; p.iv=0; }
       // CONTROL: a hit that does not down him leaves the search running.
       stand(); g.searching=box; g.searchT=0.3; g.nearDoor=door;
       damagePlayer(5,'sentry','PROBE UNIT NINE',p.x-2,p.y);
       if(p.downed) return 'SKIP: a five point hit downed him';
       if(g.searching!==box) return 'SKIP: an ordinary hit stopped the search, so nothing here can be measured';
       // THE FINDING: shot to the floor mid-search beside a door.
       stand(); p.hp=20; g.searching=box; g.searchT=0.3; g.nearDoor=door;
       damagePlayer(999,'sentry','PROBE UNIT NINE',p.x-2,p.y);
       if(!p.downed) return 'SKIP: the staged hit did not put him on the floor';
       if(g.searching) bad.push('going down halfway through a search left the search bar frozen on the crate');
       if(g.nearDoor) bad.push('going down beside a locked door left the unlock prompt up');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.searching=null; g2.nearDoor=null; if(g2.player){ g2.player.downed=false; g2.player.hp=100; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
