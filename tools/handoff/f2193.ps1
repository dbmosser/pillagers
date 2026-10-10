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

if ($s.Contains("  {v:'21.93',what:")) { throw "check 21.93 is in the fixture already" }

SubRx @'
  {v:'21.92',what:
'@ @'
  {v:'21.93',what:'four gun keys: with the rifle and SMG in his hands and a shotgun, a marksman rifle and a carbine packed, keys 1 to 4 show the rifle, the SMG, the shotgun and the marksman rifle on the Undercroft belt and at the raid start, Smoke, Decoy, Frag and Medical slide down two to keys 5 to 8, the fifth gun stays in the backpack with no key, a vacant gun key never takes the highlight and the pad walk steps over it, and an old saved belt plan slides down two once',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||!window.__P||!window.__applyLoaded) return 'SKIP: this fixture cannot deploy a raid or load a profile';
     if(typeof hotbarSlots!=='function'||typeof hubBagState!=='function'||typeof setHot!=='function') return 'SKIP: no belt here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.shotgun||!WEAPONS.dmr||!WEAPONS.carbine||!ITEMS.gun_shotgun||!ITEMS.gun_dmr||!ITEMS.gun_carbine||!ITEMS.gun_smg) return 'SKIP: no rifle, smg, shotgun, marksman rifle or carbine here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], snap=null, g=null, p=null, sl, fl, i, s0=say, o0, KIT=['gun_shotgun','gun_dmr','gun_carbine'], want=['rifle','smg','shotgun','dmr'], wk=['throw:smoke','throw:decoy','throw:frag','heal'];
     function gid(c){ return String((c&&c.icon)||'').replace(/^gun_/,''); }
     function desc(c){ return c?(String(c.k)+(c.icon?(' '+gid(c)):'')+(c.vacant?' (vacant)':'')):'nothing'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // 1. The Undercroft belt previews the packed guns on keys 3 and 4.
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={}; P.kit=KIT.slice();
       o0=G; try{ G=hubBagState(); fl=hotbarSlots(); } finally { G=o0; }
       for(i=0;i<4;i++) if(!(fl[i]&&fl[i].kind==='gun'&&gid(fl[i])===want[i])) bad.push('the Undercroft belt shows '+desc(fl[i])+' on key '+(i+1)+', not the '+want[i]);
       // 2. The raid starts on the same four gun keys, everything else two keys down, and the fifth gun has no key.
       __deploy({kit:KIT.slice(),safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(!(p.wep&&p.wep.id==='rifle'&&p.sec&&p.sec.id==='smg')) return 'SKIP: staging: did not deploy with the rifle up and the SMG stowed';
       for(i=0;i<KIT.length;i++) if(g.bag.indexOf(KIT[i])<0) return 'SKIP: staging: the '+KIT[i]+' did not go up in the backpack';
       sl=hotbarSlots();
       for(i=0;i<4;i++) if(!(sl[i]&&sl[i].kind==='gun'&&gid(sl[i])===want[i])) bad.push('at the raid start key '+(i+1)+' shows '+desc(sl[i])+', not the '+want[i]);
       for(i=0;i<4;i++) if(!(sl[4+i]&&sl[4+i].k===wk[i])) bad.push('key '+(5+i)+' shows '+desc(sl[4+i])+', not '+wk[i]);
       for(i=0;i<sl.length;i++) if(sl[i]&&gid(sl[i])==='carbine') bad.push('the fifth gun (the carbine) shows on key '+(i+1)+' instead of staying in the backpack with no key');
       if(!(sl[0]&&sl[0].inHand)) bad.push('key 1 does not show the rifle in his hands at the raid start');
       if(g.hot!==0) bad.push('the raid started on key '+(g.hot+1)+', not key 1 with the rifle');
       __endRaid('abandon'); __topClear();
       // 3. Two guns and none packed: keys 3 and 4 are vacant, never take the highlight, and the pad walk steps over them.
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid for the vacant keys';
       g.ents.length=0; p.iv=99; p.roll=0; p.downed=false; p.dying=false; g.paused=false;
       sl=hotbarSlots();
       if(!(sl[2]&&sl[2].kind==='gun'&&sl[2].vacant&&sl[3]&&sl[3].kind==='gun'&&sl[3].vacant)) bad.push('with two guns and none packed keys 3 and 4 show '+desc(sl[2])+' and '+desc(sl[3])+', not two vacant gun keys');
       g.hot=0; say=function(){}; setHot(2); say=s0;
       if(g.hot!==0) bad.push('pressing the vacant key 3 moved the highlight to key '+(g.hot+1));
       if(typeof beltStep!=='function') bad.push('no pad walk that steps over a vacant gun key (beltStep)');
       else {
         g.hot=1; say=function(){}; beltStep(1); say=s0;
         if(g.hot!==4) bad.push('RB from key 2 went to key '+(g.hot+1)+', not over the vacant keys 3 and 4 to key 5');
         g.hot=4; say=function(){}; beltStep(-1); say=s0;
         if(g.hot!==1) bad.push('LB from key 5 went to key '+(g.hot+1)+', not over the vacant keys 4 and 3 to key 2');
       }
       __endRaid('abandon'); __topClear();
       // 4. An old saved plan slides down two, once.
       var old=JSON.parse(JSON.stringify(__P())); delete old.beltV; old.hotAssign={2:'medkit',4:'frag',7:'stim',8:'gun_smg'};
       __applyLoaded(old);
       var ha=__P().hotAssign||{}, exp={2:'gun_smg',4:'medkit',6:'frag',8:'stim'}, ek, got=JSON.stringify(ha);
       if(Object.keys(ha).length!==4) bad.push('the old plan {3: Medkit, 5: Frag, 8: Stim, 9: SMG} loaded as '+got);
       else for(ek in exp) if(ha[ek]!==exp[ek]){ bad.push('the old plan {3: Medkit, 5: Frag, 8: Stim, 9: SMG} loaded as '+got+', not the SMG on key 3, Medkit 5, Frag 7, Stim 9'); break; }
       if(__P().beltV!==2) bad.push('the slid plan is not marked as slid (beltV '+__P().beltV+')');
       __applyLoaded(JSON.parse(JSON.stringify(__P())));
       if(JSON.stringify(__P().hotAssign||{})!==got) bad.push('a second load slid the plan again: '+JSON.stringify(__P().hotAssign));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
