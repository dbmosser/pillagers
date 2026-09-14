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
  {v:'13.84',what:
'@ @'
  {v:'13.85',what:'a pile you drop earns no hot zone bonus: one item dropped inside the hot zone and searched back up leaves exactly that item in the backpack, while an ordinary crate in the zone still pays the bonus (searching and loot audit 2026-09-14, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof dropItem!=='function'||typeof openContainer!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function') return 'SKIP: no crates in this build';
     var bad=[], X=null, k;
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&k!=='medkit'&&k!=='bandage'&&it.use!=='key'&&it.use!=='gun'&&it.use!=='heal'&&it.use!=='throw'&&ival(k)>=40&&(it.wt||1)<=2){ X=k; break; } }
     if(!X) return 'SKIP: nothing plain and light to drop';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.hotAssign={}; g.hotAuto={}; g.issuedBandages=0;
       p.downed=false; p.iv=99;
       g.hotZone={x:p.x,y:p.y,r:620};
       // THE FINDING: drop one item in the zone and search the pile back up.
       g.bag=[X];
       dropItem(0);
       var pile=g.containers[g.containers.length-1];
       if(!pile||!pile.dropped) return 'SKIP: dropping made no dropped pile';
       openContainer(pile);
       if(g.bag.length!==1) bad.push('dropping one '+X+' in the hot zone and searching it back up left '+g.bag.length+' items in the backpack: '+g.bag.join(','));
       // CONTROL: an ordinary crate in the zone still pays the bonus.
       g.bag=[];
       var box=setLoot(mkContainer(p.x+8,p.y+8,'crate'),[X]);
       g.containers.push(box);
       openContainer(box);
       if(!(g.bag.length>=2)) bad.push('control: an ordinary crate in the hot zone paid no bonus ('+g.bag.length+' items), so this check cannot see one');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.hotZone=null; if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
