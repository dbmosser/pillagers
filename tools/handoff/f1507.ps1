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
  {v:'15.06',what:
'@ @'
  {v:'15.07',what:'a grenade a pillager pays for a revive goes where the belt throws from: a downed pillager carrying only a Frag Charge, picked up with E, adds one to the Frag count and leaves no Frag Charge in the backpack (throwables audit finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof keys==='undefined'||typeof mouse==='undefined') return 'SKIP: no player update or key state in this build';
     if(!(ITEMS.frag&&ITEMS.frag.use==='throw'&&ITEMS.frag.tk&&ITEMS.medkit)) return 'SKIP: no Frag Charge or Medkit in this build';
     var bad=[], g0=null, _say=say, said=[];
     function countIn(a,k){ var c=0; for(var i=0;i<a.length;i++) if(a[i]===k) c++; return c; }
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     function stage(g,R,items){
       var q=g.player;
       R.x=q.x+24; R.y=q.y; R.downed=1; R.downT=60; R.state='down'; R.hp=1; R.maxhp=R.maxhp||78;
       R.paidRevive=0; R.ident=null; R.merc=0; R.finished=0; R.bag=items.slice();
       g.ents.length=0; g.ents.push(R); g.revLock=0;
     }
     function pressE(){ clearKeys(); mouse.down=false; keys['KeyE']=true; updatePlayer(0.016); clearKeys(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       g0=g;
       var p=g.player, tk=ITEMS.frag.tk;
       if(!g.pouch||typeof g.pouch[tk]!=='number') return 'SKIP: no Frag count in this raid';
       p.downed=false; p.roll=0; p.iv=99;
       var R=null, i;
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].kind==='raider'){ R=g.ents[i]; break; }
       if(!R) R={kind:'raider',x:0,y:0,r:11,hp:1,maxhp:78,face:0,state:'down',tx:0,ty:0,cd:1,alert:0,spd:122,wep:WEAPONS.pistol,dmg:(WEAPONS.pistol?WEAPONS.pistol.dmg:10),rng:200,cone:0.8,bag:[],looted:0,goal:null,skips:[],goalT:0,goalD:0,extracting:0,hitT:0,step:0,crew:0,hostile:true,armor:0,armorCap:0,bulk:0};
       say=function(m){ said.push(String(m)); };
       // CONTROL: a pillager carrying only a Medkit gets up with E and the Medkit reaches the backpack.
       g.bag=[]; stage(g,R,['medkit']);
       pressE();
       if(R.downed) return 'SKIP: E next to a downed pillager did not pick him up here';
       if(countIn(g.bag,'medkit')!==1) return 'SKIP: the Medkit he paid did not reach the backpack here ('+JSON.stringify(g.bag)+')';
       // THE FINDING: the same pillager carrying only a Frag Charge, with 2 Frag carried.
       g.bag=[]; g.pouch[tk]=2; said.length=0; stage(g,R,['frag']);
       pressE();
       if(R.downed) return 'SKIP: the second pick up did not run here';
       if(R.bag.length) return 'SKIP: he did not pay the Frag Charge here ('+JSON.stringify(R.bag)+')';
       if(countIn(g.bag,'frag')) bad.push('the Frag Charge he paid went into the backpack, where no throw can use it (backpack '+JSON.stringify(g.bag)+')');
       if(g.pouch[tk]!==3) bad.push('the Frag count is '+g.pouch[tk]+' after he paid a Frag Charge on top of 2 (said: '+said.join(' | ').slice(0,80)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say;
       try{ clearKeys(); mouse.down=false; }catch(_k){}
       try{ if(g0){ g0.revLock=0; if(g0.player){ g0.player.iv=0; g0.player.downed=false; } if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
