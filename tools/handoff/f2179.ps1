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

if ($s.Contains("  {v:'21.79',what:")) { throw "check 21.79 is in the fixture already" }

SubRx @'
  {v:'21.78',what:
'@ @'
  {v:'21.79',what:'the four-gun belt, build 1: a gun keeps its rolled quality and its rounds in the backpack (a Pristine Auto Rifle bagged and drawn again, a rolled pistol found into the backpack; control: a dropped pile comes back field grade)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof bagHeldGun!=='function'||typeof equipFromBag!=='function'||typeof grantLoot!=='function'||typeof dropItem!=='function'||typeof rollFieldGun!=='function'||typeof hotbarSlots!=='function') return 'SKIP: no backpack guns here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.pistol||!ITEMS.gun_rifle||!ITEMS.gun_pistol) return 'SKIP: no rifle, smg or pistol here';
     var bad=[], g, p, realRoll=rollFieldGun, ki=-1;
     function cp(id){ var o={}, b=WEAPONS[id]; for(var k in b) o[k]=b[k]; return o; }
     function held(id){ return (p.wep&&p.wep.id===id)?{w:p.wep,am:p.ammo,hand:1}:((p.sec&&p.sec.id===id)?{w:p.sec,am:p.secAmmo,hand:0}:null); }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       var RM=WEAPONS.rifle.mag+6;
       var r=cp('rifle'); r.name='Pristine Auto Rifle'; r.q='pristine'; r.qRank=3; r.mag=RM; r.tint='#12ab34';
       p.wep=r; p.ammo=29; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=cp('smg'); p.secAmmo=11; p.secIssued=false; p.secFromArmory=false;
       p.swapped=false; p.roll=0; p.reloading=0; p.downed=false; p.dying=false; G.paused=false;
       G.bag=G.bag.filter(function(k){ return !/^gun_/.test(k); });
       if(!bagHeldGun('gunA')||G.bag.indexOf('gun_rifle')<0) return 'SKIP: the rifle would not go into the backpack';
       var sl=hotbarSlots();
       for(var i=sl.length-1;i>=2;i--) if(sl[i]&&sl[i].kind==='empty'&&!(G.hotAssign&&G.hotAssign[i]!==undefined)){ ki=i; break; }
       if(ki>=0){
         G.hotAssign=G.hotAssign||{}; G.hotAssign[ki]='gun_rifle';
         var c=hotbarSlots()[ki];
         if(!c||c.name!=='Pristine Auto Rifle') bad.push('the backpack rifle on key '+(ki+1)+' reads '+(c&&c.name)+', not its rolled name');
         else if(c.c!=='#12ab34') bad.push('the backpack rifle on its key lost its tint ('+c.c+')');
         delete G.hotAssign[ki]; if(G.hotAuto) delete G.hotAuto[ki]; ki=-1;
       }
       if(!equipFromBag(G.bag.indexOf('gun_rifle'),1)) return 'SKIP: the rifle would not come out of the backpack';
       var b=held('rifle'); if(!b) return 'SKIP: the rifle did not reach a hand slot';
       if(b.w.name!=='Pristine Auto Rifle') bad.push('the rifle came back as '+b.w.name);
       if(b.w.qRank!==3) bad.push('the rifle came back at grade '+b.w.qRank);
       if(b.w.mag!==RM) bad.push('the rifle came back with a magazine of '+b.w.mag+', not its rolled '+RM);
       if(b.am!==29) bad.push('the rifle came back with '+b.am+' rounds, not the 29 it went in with');
       rollFieldGun=function(gk){ var o=cp(gk); o.name='Pristine '+o.name; o.q='pristine'; o.qRank=3; o.mag=o.mag+2; o.tint='#34ab12'; return o; };
       try{ grantLoot({x:p.x,y:p.y,loot:[]},['gun_pistol'],0); } finally { rollFieldGun=realRoll; }
       var pi=G.bag.indexOf('gun_pistol');
       if(pi<0) return 'SKIP: the found pistol did not go into the backpack ('+(p.wep&&p.wep.id)+' / '+(p.sec&&p.sec.id)+')';
       if(!equipFromBag(pi,1)) return 'SKIP: the pistol would not come out of the backpack';
       var pw=held('pistol'); if(!pw) return 'SKIP: the pistol did not reach a hand slot';
       if(pw.w.qRank!==3||pw.w.name!=='Pristine Scav Pistol') bad.push('a pistol found into the backpack came out as '+pw.w.name+' grade '+pw.w.qRank+', not its Pristine roll');
       // CONTROL (both builds): his own discard searched back up off the pile is field grade.
       var sw=!!p.swapped, hs=pw.hand?(sw?'gunB':'gunA'):(sw?'gunA':'gunB');
       if(!bagHeldGun(hs)) return 'SKIP: the pistol would not go back into the backpack';
       var di=G.bag.indexOf('gun_pistol'); if(di<0) return 'SKIP: the pistol is not in the backpack';
       var nc=G.containers.length;
       if(!dropItem(di)) return 'SKIP: the pistol would not drop';
       var pile=G.containers[G.containers.length-1];
       if(G.containers.length!==nc+1||!pile||!pile.dropped) return 'SKIP: the drop made no pile here';
       grantLoot(pile,['gun_pistol'],0);
       G.containers.splice(G.containers.indexOf(pile),1);
       var pj=G.bag.indexOf('gun_pistol'); if(pj<0) return 'SKIP: the dropped pistol did not go back into the backpack';
       if(!equipFromBag(pj,1)) return 'SKIP: the dropped pistol would not come out of the backpack';
       var pd=held('pistol'); if(!pd) return 'SKIP: the dropped pistol did not reach a hand slot';
       if((pd.w.qRank===undefined?1:pd.w.qRank)!==1||pd.w.name!==WEAPONS.pistol.name) bad.push('a pistol he dropped and searched back up came back as '+pd.w.name+' grade '+pd.w.qRank+' (his discards come back at field grade)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ rollFieldGun=realRoll; if(ki>=0&&G.hotAssign) delete G.hotAssign[ki]; var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
