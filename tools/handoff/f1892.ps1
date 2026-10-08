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

if ($s.Contains("  {v:'18.92',what:")) { throw "check 18.92 is in the fixture already" }

SubRx @'
  {v:'18.91',what:
'@ @'
  {v:'18.92',what:'on the Stash screen a belt key left on an armoury gun that is no longer in his hands, dragged from key 8 to key 1, moves to key 1 and packs that gun instead of being refused as not in the stash, while a key on the gun in his hands still moves alone (his report 2026-10-07: cannot move a gun from slot 8 to slot 1)',
 run:function(){
   if(typeof renderHub!=='function'||typeof planPut!=='function'||typeof rackPut!=='function'||typeof packedCount!=='function'||typeof heldCount!=='function') return 'SKIP: no belt plan or backpack count in this build';
   if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen and restore the profile';
   if(typeof ITEMS==='undefined'||!ITEMS.gun_smg||!ITEMS.gun_pistol||typeof WEAPONS==='undefined'||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: no Scav Pistol or Compact SMG in this build';
   if(typeof say2!=='function') return 'SKIP: no say2 in this build';
   if(typeof G!=='undefined'&&G&&!G.over) return 'SKIP: a raid is running';
   var hub=document.getElementById('hub');
   if(!hub||!document.getElementById('hotplanwrap')) return 'SKIP: no Stash screen or tactical belt in the page';
   var bad=[], snap=null, hubWas=hub.classList.contains('on'), s2Was=say2, said=[], stale=['no longer in ','your stash'].join('');
   function plan(){ return JSON.stringify(__P().hotAssign||{}); }
   function only(ix,key){ var h=__P().hotAssign||{}, n=0, s; for(s in h) n++; return n===1&&h[ix]===key; }
   function stage(hot,eq){ var q=__P(); q.stash=[]; q.kit=[]; q.hotAssign=JSON.parse(JSON.stringify(hot)); q.freeKit=0; q.weapons=['pistol','smg']; q.equipped=eq; q.equippedSec='none'; renderHub(); hub.classList.add('on'); said.length=0; }
   function cell(ix){ var all=document.querySelectorAll('#hotplanwrap [data-plan]'), i; for(i=0;i<all.length;i++) if(all[i].getAttribute('data-plan')===String(ix)) return all[i]; return null; }
   try{
     __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile();
     snap=JSON.parse(JSON.stringify(__P()));
     try{ __hubEnter(); }catch(_h){}
     [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
     say2=function(t){ said.push(String(t)); };
     // CONTROL: the key on the SMG in his hands moves from key 8 to key 1 alone, on either build.
     stage({7:'gun_smg'},'smg');
     if(!only(7,'gun_smg')) return 'SKIP: the key on the SMG in his hands did not stay on key 8 when the Stash screen was drawn (plan '+plan()+')';
     var c1=cell(0); if(!c1||typeof c1.__grabDrop!=='function') return 'SKIP: belt key 1 on the Stash screen is not a drop target';
     c1.__grabDrop('gun_smg','plan:7');
     if(!only(0,'gun_smg')) return 'SKIP: control: the key on the SMG in his hands did not move from key 8 to key 1 (plan '+plan()+')';
     // THE FINDING: key 8 on the Scav Pistol, which is on the rack and in neither hand.
     stage({7:'gun_pistol'},'smg');
     if(!only(7,'gun_pistol')) return 'SKIP: the Stash screen dropped the key on the rack pistol when it was drawn (plan '+plan()+'), so the stale key cannot be staged';
     c1=cell(0); if(!c1||typeof c1.__grabDrop!=='function') return 'SKIP: belt key 1 is not a drop target after the redraw';
     c1.__grabDrop('gun_pistol','plan:7');
     if(!only(0,'gun_pistol')) bad.push('the key on the Scav Pistol on the rack, dragged from key 8 to key 1, left the plan '+plan()+(said.length?(' and said: '+said.join(' | ')):''));
     if(packedCount('gun_pistol')!==1) bad.push('after the move '+packedCount('gun_pistol')+' Scav Pistols are packed, not one, so key 1 has nothing to bring up');
     for(var i=0;i<said.length;i++) if(said[i].indexOf(stale)>=0) bad.push('it told him the rack pistol is not in his stash: '+said[i]);
   }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
   finally{
     try{ say2=s2Was; }catch(_s){}
     try{ if(typeof GRAB!=='undefined'&&GRAB&&typeof grabEnd==='function') grabEnd(); }catch(_g){}
     try{ if(typeof mouse!=='undefined'&&mouse) mouse.down=false; }catch(_m){}
     try{ if(snap) __applyLoaded(snap); }catch(_r){}
     try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
     try{ __topClear(); if(window.__resetCfg) __resetCfg(); __cleanProfile(); }catch(_c){}
   }
   return bad.length?bad.join('; '):null; }},
  {v:'18.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
