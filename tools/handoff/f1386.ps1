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
  {v:'13.85',what:
'@ @'
  {v:'13.86',what:'a pile you drop does not restock: a dropped pile searched back up and left 171 seconds stays opened and empty, while an ordinary opened crate left as long restocks (searching and loot audit 2026-09-14, finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof dropItem!=='function'||typeof openContainer!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function'||typeof updateEnts!=='function') return 'SKIP: no crates or world update in this build';
     var bad=[], X=null, k;
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&k!=='medkit'&&k!=='bandage'&&it.use!=='key'&&it.use!=='gun'&&it.use!=='heal'&&it.use!=='throw'&&ival(k)>=40&&(it.wt||1)<=2){ X=k; break; } }
     if(!X) return 'SKIP: nothing plain and light to drop';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.hotZone=null; g.hotAssign={}; g.hotAuto={}; g.issuedBandages=0;
       p.downed=false; p.iv=99;
       // THE FINDING: a dropped pile, searched back up, left 171 seconds.
       g.bag=[X];
       dropItem(0);
       var pile=g.containers[g.containers.length-1];
       if(!pile||!pile.dropped) return 'SKIP: dropping made no dropped pile';
       openContainer(pile);
       if(!pile.opened) return 'SKIP: searching the pile back up did not open it';
       // CONTROL: an ordinary crate, opened and left as long.
       var box=setLoot(mkContainer(p.x+900,p.y+900,'crate'),[X]);
       g.containers.push(box);
       openContainer(box);
       pile.openedAt=g.t-171; box.openedAt=g.t-171;
       updateEnts(0.001);
       if(!pile.opened) bad.push('a pile he dropped restocked after 171 seconds with '+(pile.loot||[]).join(',')+' in it');
       if(box.opened) bad.push('control: an ordinary opened crate did not restock after 171 seconds, so this check cannot see a restock');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
