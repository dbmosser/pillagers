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

# v12.20 CHECK, inserted before the v12.19 entry. The backpack is opened in
# a raid, an arrow is pressed through raidKey and one real player update is
# run: the selection must move and the operator must not; with the backpack
# closed the same arrow must still walk.
SubRx @'
  {v:'12.19',what:'the trigger on an empty grenade cell selects the gun and says so, fires nothing on that same hold, and a loaded cell still cooks (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.20',what:'an arrow key with the backpack open moves the selection and does not walk the operator, and still walks with it closed (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof raidKey!=='function'||typeof updatePlayer!=='function') return 'SKIP: no raid keys in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.bag=['bandage','medkit','plate']; g.bagOpen=true; g.bagSel=0; keys={}; mouse.down=false; p.downed=false; p.roll=0;
       var x0=p.x, y0=p.y;
       raidKey('ArrowRight',false,null);
       if(g.bagSel!==1) bad.push('control: the arrow did not move the selection (bagSel '+g.bagSel+')');
       if(keys['ArrowRight']) bad.push('the arrow is still in the movement state with the backpack open');
       updatePlayer(0.05);
       var moved=Math.hypot(p.x-x0,p.y-y0);
       if(moved>0.01) bad.push('browsing the backpack walked the operator '+moved.toFixed(1)+' units');
       // CONTROL: with the backpack closed the arrow still walks.
       keys={}; g.bagOpen=false; x0=p.x; y0=p.y;
       raidKey('ArrowRight',false,null);
       if(!keys['ArrowRight']) bad.push('control: the arrow is not in the movement state with the backpack closed');
       updatePlayer(0.05);
       if(Math.hypot(p.x-x0,p.y-y0)<0.01) bad.push('control: the arrow with the backpack closed did not walk the operator');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.bagOpen=false; g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.19',what:'the trigger on an empty grenade cell selects the gun and says so, fires nothing on that same hold, and a loaded cell still cooks (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
