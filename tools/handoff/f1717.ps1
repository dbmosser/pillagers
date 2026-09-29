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

if ($s.Contains("  {v:'17.17',what:")) { throw "check 17.17 is in the fixture already" }

SubRx @'
  {v:'17.16',what:
'@ @'
  {v:'17.17',what:'an item bound to belt key 1 does not bury the gun: the raid starts on a key holding the gun in his hands, and after key 2 brings Bare Hands up a key still shows the gun and brings it back (belt hunt 2026-09-28)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof setHot!=='function'||typeof gunCell!=='function'||typeof hotSel!=='function'||!ITEMS.medkit) return 'SKIP: this build has no belt or no Medkit';
     var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, g0=G, st0=state, pk0={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),dropKit:(P2.dropKit||[]).slice(),kitChosen:P2.kitChosen,freeKit:P2.freeKit}, g=null, p=null, gid=null, gname='', sl, c, i, back=-1;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.hotAssign={0:'medkit'};
       __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player;
       if(!p.wep||!p.wep.id||p.wep.id==='fists') return 'SKIP: no gun in hand at the drop';
       gid=p.wep.id; gname=p.wep.name; g.ents.length=0; p.downed=false; p.roll=0; p.iv=99;
       // The play path first (the plan carried up); staged the same way startRaid does it when the plan did not carry.
       if(!(g.hotAssign&&g.hotAssign[0]==='medkit')){ g.hotAssign={0:'medkit'}; g.hotAuto={}; if(g.bag.indexOf('medkit')<0) g.bag.push('medkit'); g.hot=gunCell(); }
       sl=hotbarSlots();
       if(!(sl[0]&&sl[0].itemKey==='medkit')) return 'SKIP: staging: the Medkit did not take key 1';
       c=sl[hotSel()];
       if(!(c&&c.kind==='gun'&&c.inHand&&c.icon===gid)) bad.push('with a Medkit on key 1 the raid started on key '+(hotSel()+1)+' ('+((c&&c.name)||'nothing')+') and no key holds the '+gname+' in his hands, so the trigger cannot fire it');
       // Key 2: Bare Hands (or the second gun) comes up.
       g.hot=-1; setHot(1);
       if(p.wep.id===gid) return bad.length?bad.join('; '):'SKIP: key 2 did not change the gun in hand, so nothing is stowed to look for';
       sl=hotbarSlots();
       for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='gun'&&sl[i].icon===gid&&!sl[i].inHand){ back=i; break; }
       if(back<0) bad.push('after key 2 brought '+p.wep.name+' up, no belt key shows the stowed '+gname+', so nothing can bring it back for the rest of the raid');
       else { setHot(back); if(p.wep.id!==gid) bad.push('key '+(back+1)+' shows the '+gname+' but pressing it left '+p.wep.name+' in his hands'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.downed=false; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
       P2.hotAssign=ha0; P2.stash=pk0.stash; P2.kit=pk0.kit; P2.dropKit=pk0.dropKit; P2.kitChosen=pk0.kitChosen; P2.freeKit=pk0.freeKit;
       G=g0; state=st0;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
