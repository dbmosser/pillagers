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

# v12.73 CHECK, inserted before the v12.72 entry. It drives the real loot grant
# in a real raid and then reads the ONE line the player is left holding, because
# the whole defect is about which of two lines survives the frame. The gun goes
# into an EMPTY second slot, which is the state a new profile is in, and the
# branch is reachable for a human whatever the Settings dial says, because the
# automatic equip is forced on for anyone who is not the bot. Two controls: a
# pull with no gun in it must say exactly what it always said, and a gun pulled
# alongside other items must still list them.
SubRx @'
  {v:'12.72',what:'the run report the game saves to his Downloads is named after the game he is playing and not after the retired project, and the run number still rides in the name so one report does not overwrite the last (2026-09-08 first-hour audit)',
'@ @'
  {v:'12.73',what:'a found gun that changes what is in his hands still says so after the pull is summarised: the line naming the slot it armed and the key that swaps to it survives the Found line instead of being overwritten in the same frame, a gun pulled beside other items keeps both facts, and a pull with no gun in it says exactly what it always said (2026-09-08 first-hour audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof grantLoot!=='function'||typeof WTIER==='undefined'||typeof WEAPONS==='undefined') return 'SKIP: this build has no loot grant to drive';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to pull in';
       if(g.sim) return 'SKIP: this raid is a sim, where the grant says nothing at all';
       var p=g.player, k, it;
       // A gun better than what he is holding, and something that is not a gun.
       var gunK=null, plainK=null;
       for(k in ITEMS){ it=ITEMS[k]; if(!it||!it.name) continue;
         if(it.gk&&WEAPONS[it.gk]&&gunK===null&&(WTIER[it.gk]||0)>(WTIER[p.wep.id]||0)) gunK=k;
         if(!it.gk&&plainK===null&&it.use!=='gun') plainK=k;
       }
       if(!gunK||!plainK) return 'SKIP: this build has no better gun or no plain item to pull';
       function pull(list){
         // The second slot is empty, which is what a new profile deploys with.
         p.sec=WEAPONS.fists; p.secAmmo=0; p.downed=false;
         g.msg=''; g.msgT=0;
         grantLoot({x:p.x+20,y:p.y+20,c:'#ffffff',loot:list.slice()},list.slice());
         return String(g.msg||'');
       }
       // THE FINDING: one gun, into the empty slot.
       var m1=pull([gunK]);
       if(!m1) return 'SKIP: the grant said nothing at all, so there is no line to read';
       if(m1.indexOf('swaps')<0)
         bad.push('after pulling a gun into his empty second slot the only line left on screen was ['+m1+']: the line telling him the slot is armed and which key swaps to it was written and then written over in the same frame, so a number key went live under his finger and nothing ever said so');
       // AND WITH COMPANY: both facts have to survive, the gun and the list.
       var m2=pull([gunK,plainK]);
       if(m2.indexOf('swaps')<0)
         bad.push('pulling that gun alongside another item lost the gun line again ['+m2+']');
       if(m2.indexOf(ITEMS[plainK].name)<0)
         bad.push('pulling that gun alongside another item lost the list of what he took ['+m2+']');
       // CONTROL: a pull with no gun in it must be untouched.
       var m3=pull([plainK]);
       if(m3!=='Found: '+ITEMS[plainK].name)
         bad.push('control: a pull with no gun in it no longer says what it always said, it says ['+m3+'] instead of the plain found line');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.72',what:'the run report the game saves to his Downloads is named after the game he is playing and not after the retired project, and the run number still rides in the name so one report does not overwrite the last (2026-09-08 first-hour audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
