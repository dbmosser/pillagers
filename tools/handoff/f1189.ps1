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

# v11.89 CHECK, inserted before the v11.88 entry. A strike is forced to land
# away from the player with the find chance at 1, through the real strike
# tick, and the scorched cache it leaves is read.
SubRx @'
  {v:'11.88',what:'the raid conditions panel no longer prints the kill-nothing and three-minute contract verdicts, and still prints the no-heals one (his order of 2026-09-06)',
'@ @'
  {v:'11.89',what:'the scorched cache a lightning strike leaves holds one Fulgurite worth 2500 and nothing else (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof strikeTick!=='function'||typeof ITEMS==='undefined') return 'SKIP: no storm in this build';
     var bad=[], i;
     if(!ITEMS.fulgurite) bad.push('there is no Fulgurite item');
     else if(ITEMS.fulgurite.val!==2500) bad.push('Fulgurite is worth '+ITEMS.fulgurite.val+' and not 2500');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       // A STORM WITH LIGHTNING, installed the way check 11.56 does it (never by
       // renaming a shared WEATHER row): the strike tick empties the list without one.
       var storm=null; for(var w=0;w<WEATHER.length;w++) if(WEATHER[w].lightning){ storm=WEATHER[w]; break; }
       if(!storm) return 'SKIP: no weather row carries lightning';
       g.wx=storm; g.wxNext=null; g.wxT=0;
       CFG.strikeFind=1;
       var n0=g.containers.length, found=null;
       var spots=[[600,0],[-600,0],[0,600],[0,-600],[400,400],[-400,-400]];
       for(i=0;i<spots.length&&!found;i++){
         g.strikes=g.strikes||[];
         g.strikes.push({x:clamp(p.x+spots[i][0],120,WORLD_W-120),y:clamp(p.y+spots[i][1],120,WORLD_H-120),t:0.001,hit:0});
         strikeTick(0.01);
         for(var c=n0;c<g.containers.length&&!found;c++) if(g.containers[c].tag==='FULGURITE') found=g.containers[c];
       }
       if(!found) bad.push('control: no strike left a scorched cache in six tries, so nothing here can be measured');
       else {
         var loot=(found.loot||[]).slice();
         if(loot.length!==1||loot[0]!=='fulgurite') bad.push('the scorched cache holds '+(loot.join(',')||'nothing')+' and not one Fulgurite');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); __resetCfg(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.88',what:'the raid conditions panel no longer prints the kill-nothing and three-minute contract verdicts, and still prints the no-heals one (his order of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
