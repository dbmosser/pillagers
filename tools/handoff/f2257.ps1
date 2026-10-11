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

if ($s.Contains("  {v:'22.57',what:")) { throw "check 22.57 is in the fixture already" }

SubRx @'
  {v:'22.56',what:
'@ @'
  {v:'22.57',what:'a gun key that only repeats a gun he put on a later key is free (from the review of the four-gun belt, build 5): with gun 1 in his hands on his key 6 and still shown on key 1, guns on keys 2 to 4, a fifth gun picked up takes key 1 instead of GUN SLOTS FULL, gun 1 stays on key 6 in his hands, a truly free gun key still comes first, and the highlight never stays on key 1 once it shows a backpack gun',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof autoBelt!=='function'||typeof gunCell!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4) return 'SKIP: no four gun keys here';
     var bad=[], s0=say, said=[], g=null, p=null, ids=[], k, a, b, c, d2, e, sl;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function gid(x){ return (x&&x.kind==='gun'&&!x.vacant)?String(x.icon||'').replace(/^gun_/,''):''; }
     function desc(x){ if(!x) return 'nothing'; return (x.itemKey&&!/^gun_/.test(x.itemKey))?x.itemKey:((gid(x)||x.k||x.kind)+(x.vacant?' (vacant)':(x.inHand?' in hand':''))); }
     function stage(full){
       p.wep=cl(a); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cl(b); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.reloading=0; p.roll=0; p.downed=false; p.dying=false;
       g.bag=full?['gun_'+c,'gun_'+d2]:['gun_'+c];
       g.hotAssign=full?{1:'gun_'+b,2:'gun_'+c,3:'gun_'+d2,5:'gun_'+a}:{1:'gun_'+b,2:'gun_'+c,5:'gun_'+a};
       g.hotAuto=full?{1:1,2:1,3:1}:{1:1,2:1}; g.hotPruned={}; g.drag=null; g.paused=false;
       g.hot=5;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; keys={};
       for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&ITEMS['gun_'+k]&&ITEMS['gun_'+k].gk===k) ids.push(k);
       if(ids.length<5) return 'SKIP: staging: fewer than five guns in this build';
       a=ids[0]; b=ids[1]; c=ids[2]; d2=ids[3]; e=ids[4];
       say=function(t){ said.push(String(t)); };
       // ONE (the guard, both builds): key 4 truly free, so a fifth gun takes key 4 and key 1 keeps showing gun 1.
       stage(false); sl=hotbarSlots();
       if(!(gid(sl[0])===a&&sl[0].inHand&&!sl[0].assigned&&gid(sl[5])===a&&sl[5].assigned&&sl[5].inHand)) return 'SKIP: staging: gun 1 is not on his key 6 and shown on key 1 too ('+desc(sl[0])+' / '+desc(sl[5])+')';
       g.bag.push('gun_'+e); autoBelt('gun_'+e);
       if(g.hotAssign[3]!=='gun_'+e) return 'SKIP: staging: with key 4 free the picked-up gun did not take key 4 (keys '+JSON.stringify(g.hotAssign)+')';
       if(g.hotAssign[0]!==undefined) bad.push('with key 4 free the picked-up gun still took key 1 (keys '+JSON.stringify(g.hotAssign)+')');
       // TWO: keys 2 to 4 hold guns; key 1 only repeats gun 1, which is on his key 6.
       stage(true); said.length=0; sl=hotbarSlots();
       if(!(gid(sl[0])===a&&sl[0].inHand&&!sl[0].assigned&&gid(sl[1])===b&&gid(sl[2])===c&&gid(sl[3])===d2)) return bad.length?bad.join('; '):'SKIP: staging: keys 1 to 4 are not gun 1 repeated and three guns ('+desc(sl[0])+' / '+desc(sl[1])+' / '+desc(sl[2])+' / '+desc(sl[3])+')';
       g.bag.push('gun_'+e); autoBelt('gun_'+e); sl=hotbarSlots();
       if(g.hotAssign[0]!=='gun_'+e) bad.push('a fifth gun picked up did not take key 1, which only repeated gun 1 on his key 6 (keys '+JSON.stringify(g.hotAssign)+'; said '+(said.join(' / ')||'nothing')+')');
       if(!(gid(sl[5])===a&&sl[5].inHand)) bad.push('key 6 shows '+desc(sl[5])+' after the pickup, not gun 1 in his hands');
       if(g.hotAssign[5]!=='gun_'+a) bad.push('gun 1 lost his key 6 (keys '+JSON.stringify(g.hotAssign)+')');
       if(!(p.wep&&p.wep.id===a&&p.sec&&p.sec.id===b)) bad.push('the pickup changed the guns in his hands to '+(p.wep&&p.wep.id)+'/'+(p.sec&&p.sec.id));
       // THREE: the same, with the highlight on key 1.
       stage(true); g.hot=0; said.length=0;
       g.bag.push('gun_'+e); autoBelt('gun_'+e); sl=hotbarSlots();
       if(g.hotAssign[0]==='gun_'+e&&!(sl[g.hot]&&sl[g.hot].kind==='gun'&&sl[g.hot].inHand)) bad.push('with the highlight on key 1 the pickup left it on key '+(g.hot+1)+', which shows '+desc(sl[g.hot])+', not the gun in his hands');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
