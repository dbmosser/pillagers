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

if ($s.Contains("  {v:'18.91',what:")) { throw "check 18.91 is in the fixture already" }

SubRx @'
  {v:'18.90',what:
'@ @'
  {v:'18.91',what:'on the Undercroft floor with the backpack open, gun 2 on belt key 2 picked up and dropped on key 1 trades places with gun 1: gun 2 becomes gun 1 and key 1 shows it, while a Medkit tile dropped on key 8 still binds it (his report 2026-10-07: cannot move a gun from slot 8 to slot 1)',
 run:function(){
   if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the floor and restore the profile';
   if(typeof hubBagOpenSet!=='function'||typeof drawHubBag!=='function'||typeof withHubBag!=='function'||typeof hotbarSlots!=='function'||typeof hubBagState!=='function') return 'SKIP: no Undercroft backpack or belt in this build';
   if(typeof cv==='undefined'||!cv||typeof mouse==='undefined'||!mouse) return 'SKIP: no canvas or mouse state in this build';
   if(typeof ITEMS==='undefined'||!ITEMS.medkit||typeof WEAPONS==='undefined') return 'SKIP: no Medkit or gun table in this build';
   if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live, so the floor backpack cannot be driven';
   var bad=[], snap=null, mx0=mouse.x, my0=mouse.y, a=null, b=null, k;
   for(k in WEAPONS){ if(k==='fists'||!WEAPONS[k]||!(WEAPONS[k].mag>0)||!ITEMS['gun_'+k]) continue; if(!a) a=k; else if(!b){ b=k; break; } }
   if(!a||!b) return 'SKIP: fewer than two guns with an item form in this build';
   function slots(){ var r=null; withHubBag(function(){ r=hotbarSlots(); }); return r||[]; }
   function cellAt(i){ var hc=hubBagG.hotCells||[]; for(var j=0;j<hc.length;j++) if(hc[j].i===i) return hc[j]; return null; }
   function press(x,y){ mouse.down=false; mouse.x=x; mouse.y=y; cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true})); }
   function release(x,y){ mouse.x=x; mouse.y=y; window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,cancelable:true})); }
   try{
     __topClear(); if(window.__runPrep) __runPrep(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
     snap=JSON.parse(JSON.stringify(__P()));
     hubBagG=null; hubBagOpen=false;
     try{ __hubEnter(); }catch(_h){}
     if(state!=='hub') return 'SKIP: the fixture did not reach the Undercroft floor (state '+state+')';
     [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
     var q=__P(); q.weapons=[a,b]; q.equipped=a; q.equippedSec=b; q.stash=['medkit']; q.kit=['medkit']; q.hotAssign={};
     hubBagOpenSet(true);
     if(!hubBagOpen||!hubBagG) return 'SKIP: the Undercroft backpack did not open';
     hubBagG.drag=null; drawHubBag();
     var sl=slots();
     if(!(sl[0]&&sl[0].k==='gunA'&&sl[0].icon===a&&sl[1]&&sl[1].k==='gunB'&&sl[1].icon===b)) return 'SKIP: staging: keys 1 and 2 of the floor belt do not show gun 1 and gun 2';
     var K1=cellAt(0), K2=cellAt(1), K8=cellAt(7);
     if(!K1||!K2||!K8||!(K1.w>0&&K1.h>0&&K2.w>0&&K2.h>0&&K8.w>0&&K8.h>0)) return 'SKIP: the floor belt drew no key 1, 2 or 8 to press';
     var tile=null, bc=hubBagG.bagCells||[], t;
     for(t=0;t<bc.length;t++) if(bc[t]&&bc[t].key==='medkit'){ tile=bc[t]; break; }
     if(!tile) return 'SKIP: the Undercroft backpack drew no Medkit tile to drag';
     // CONTROL: the Medkit tile dropped on key 8 binds it, so the floor press and drop are live, on either build.
     press(tile.x+tile.w/2,tile.y+tile.h/2);
     if(!hubBagG.drag||hubBagG.drag.key!=='medkit') return 'SKIP: a press on the Medkit tile started no drag here';
     release(K8.x+K8.w/2,K8.y+K8.h/2);
     if((__P().hotAssign||{})[7]!=='medkit') return 'SKIP: the Medkit tile dropped on key 8 did not bind it here';
     // THE FINDING: gun 2 on key 2 dragged onto key 1.
     q=__P(); q.hotAssign={}; hubBagG.hotAssign=q.hotAssign; hubBagG.drag=null; drawHubBag();
     K1=cellAt(0); K2=cellAt(1);
     if(!K1||!K2) return 'SKIP: the floor belt lost key 1 or 2 on the redraw';
     press(K2.x+K2.w/2,K2.y+K2.h/2);
     if(!hubBagG.drag) bad.push('a press on gun 2 on key 2 of the floor belt picked nothing up and said nothing');
     release(K1.x+K1.w/2,K1.y+K1.h/2);
     if(hubBagG) hubBagG.drag=null;
     if(__P().equipped!==b||__P().equippedSec!==a) bad.push('gun 2 ('+b+') dragged onto key 1 on the floor left gun 1 as '+__P().equipped+' and gun 2 as '+__P().equippedSec);
     sl=slots();
     if(!(sl[0]&&sl[0].icon===b)) bad.push('after the drop key 1 of the floor belt shows '+((sl[0]&&sl[0].icon)||'nothing')+', not '+b);
   }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
   finally{
     try{ if(hubBagG) hubBagG.drag=null; hubBagG=null; hubBagOpen=false; }catch(_hb){}
     try{ mouse.x=mx0; mouse.y=my0; mouse.down=false; }catch(_m){}
     try{ if(snap&&state==='hub'){ var mo=document.querySelectorAll('.modal.on'); for(var mj=0;mj<mo.length;mj++) mo[mj].classList.remove('on'); } }catch(_mo){}
     try{ if(snap) __applyLoaded(snap); }catch(_r){}
     try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
   }
   return bad.length?bad.join('; '):null; }},
  {v:'18.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
