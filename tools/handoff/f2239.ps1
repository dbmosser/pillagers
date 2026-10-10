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

if ($s.Contains("  {v:'22.39',what:")) { throw "check 22.39 is in the fixture already" }

SubRx @'
  {v:'22.38',what:
'@ @'
  {v:'22.39',what:'an old belt plan with a Medkit on key 8 and a Stim on key 9 slides without covering Medical or the plate: after the load the two bindings sit on gun keys 3 and 4, and in the raid the Medical cell (it uses the heals he did not bind) and the Armour Plate cell still show on keys 8 and 9',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||!window.__P||!window.__applyLoaded) return 'SKIP: this fixture cannot deploy a raid or load a profile';
     if(typeof beltSlidePlan!=='function'||typeof hotbarSlots!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4) return 'SKIP: no four gun keys here';
     if(!ITEMS.medkit||!ITEMS.stim||!ITEMS.bandage||!ITEMS.plate||!WEAPONS.rifle||!WEAPONS.smg) return 'SKIP: no medkit, stim, bandage, plate, rifle or smg here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], snap=null, g=null, sl, i, ha, got, heal=-1, plate=-1, keyOf={};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var old=JSON.parse(JSON.stringify(__P())); delete old.beltV; old.hotAssign={7:'medkit',8:'stim'};
       __applyLoaded(old);
       ha=__P().hotAssign||{}; got=JSON.stringify(ha);
       for(i=0;i<9;i++) if(ha[i]!==undefined) keyOf[ha[i]]=i;
       if(ha[7]!==undefined) bad.push('the old plan {8: Medkit, 9: Stim} loaded as '+got+', with '+ha[7]+' over Medical on key 8');
       if(ha[8]!==undefined) bad.push('the old plan {8: Medkit, 9: Stim} loaded as '+got+', with '+ha[8]+' over the plate key 9');
       for(i=4;i<7;i++) if(ha[i]!==undefined) bad.push('the old plan {8: Medkit, 9: Stim} loaded as '+got+', with '+ha[i]+' over a throw on key '+(i+1));
       if(!(keyOf.medkit===2||keyOf.medkit===3)||!(keyOf.stim===2||keyOf.stim===3)) bad.push('the old plan {8: Medkit, 9: Stim} loaded as '+got+', not the two of them on gun keys 3 and 4');
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg';
       __deploy({kit:['medkit','stim','bandage','plate'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.bag.indexOf('plate')<0||g.bag.indexOf('bandage')<0) return 'SKIP: staging: the plate or the bandage did not go up';
       sl=hotbarSlots();
       for(i=0;i<sl.length;i++){ if(sl[i]&&sl[i].k==='heal') heal=i; if(sl[i]&&sl[i].k==='plate') plate=i; }
       if(heal<0) bad.push('in the raid no key shows Medical, so the Bandage he did not bind cannot be used from the belt (keys: '+sl.map(function(c){ return c?c.k:'-'; }).join(', ')+')');
       if(plate<0) bad.push('in the raid no key shows the Armour Plate he carries (keys: '+sl.map(function(c){ return c?c.k:'-'; }).join(', ')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player) g2.player.downed=false; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
