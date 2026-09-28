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

if ($s.Contains("  {v:'16.99',what:")) { throw "check 16.99 is in the fixture already" }

SubRx @'
  {v:'16.98',what:
'@ @'
  {v:'16.99',what:'a pick-up clears the player 2 kill mark: a pillager player 2 downed who is picked up by you with E or by his crewmate no longer carries player 2 as his killer, so a later shell or bleed-out is not sent to player 2 as a kill',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkRaider!=='function'||typeof updateEnts!=='function'||typeof updatePlayer!=='function'||typeof keys==='undefined'||typeof mouse==='undefined') return 'SKIP: no pillagers, player update or key state in this build';
     var bad=[], g0=null, _say=say, keepOn=(typeof NET==='object'&&NET)?NET.on:null, mine=false;
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g0=g;
       if(keepOn!==null) NET.on=false;
       say=function(){};
       p.downed=false; p.roll=0; p.iv=99;
       var R=mkRaider(p.x+24,p.y,null,false);
       R.downed=1; R.downT=60; R.state='down'; R.hp=1; R.maxhp=R.maxhp||78; R.merc=0; R.finished=0; R.net=0;
       R.paidRevive=0; R.ident=null; R.bag=[]; R.byPlayer=false; R.bySeat=1;
       g.ents.length=0; g.ents.push(R); g.revLock=0;
       clearKeys(); mouse.down=false; keys['KeyE']=true; updatePlayer(0.016); clearKeys();
       if(!R.downed){ mine=true; if(R.bySeat) bad.push('a pillager player 2 downed and you picked up still carries player 2 as his killer (seat '+R.bySeat+')'); }
       var Z=null, zi;
       for(zi=0;zi<g.zones.length&&!Z;zi++) if(losClear(g.zones[zi].x,g.zones[zi].y,g.zones[zi].x+40,g.zones[zi].y,g.map.segs)) Z=g.zones[zi];
       if(!Z){ if(!mine) return 'SKIP: neither pick-up could be staged here'; }
       else {
         var A=mkRaider(Z.x,Z.y,null,false), B=mkRaider(Z.x+30,Z.y,null,false);
         B.crew=A.crew; A.hostile=true; B.hostile=true;
         A.downed=1; A.downT=10; A.hp=1; A.state='down'; A.byPlayer=false; A.bySeat=1;
         B.state='loot'; B.reviving=A; B.revProg=3.19; B.alert=0; B.goal=null;
         g.ents.length=0; g.ents.push(A); g.ents.push(B);
         p.x=Z.x+2000; p.y=Z.y+2000;
         for(var f=0;f<3&&A.downed;f++) updateEnts(0.02);
         if(A.downed){ if(!mine) return 'SKIP: neither pick-up ran in the staged frames, so nothing here can be measured'; }
         else if(A.bySeat) bad.push('a pillager player 2 downed and his crewmate picked up still carries player 2 as his killer (seat '+A.bySeat+'), so a later shell or bleed-out is sent to player 2 as his kill');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say;
       try{ clearKeys(); mouse.down=false; }catch(_k){}
       try{ if(keepOn!==null) NET.on=keepOn; }catch(_n){}
       try{ if(g0){ g0.revLock=0; if(g0.player){ g0.player.iv=0; g0.player.downed=false; } if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
