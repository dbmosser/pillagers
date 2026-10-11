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

if ($s.Contains("  {v:'22.43',what:")) { throw "check 22.43 is in the fixture already" }

SubRx @'
  {v:'22.42',what:
'@ @'
  {v:'22.43',what:'the belt lines read like a shooter HUD (his order of 2026-10-09): a vacant key 2 says GUN SLOT 2 EMPTY, the trigger on an empty key says EMPTY SLOT with the gun key under it, a found gun on a gun key says SHOTGUN ON KEY 2, a fifth gun says GUN SLOTS FULL with the gun IN BACKPACK under it, and none of the old belt sentences is left in the game',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||!window.__sim) return 'SKIP: this fixture cannot deploy or step a raid';
     if(typeof autoBelt!=='function'||typeof setHot!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4) return 'SKIP: no four gun keys here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!ITEMS.gun_shotgun||!ITEMS.gun_dmr||!ITEMS.gun_carbine||!ITEMS.gun_smg) return 'SKIP: no rifle, smg, shotgun, marksman rifle or carbine here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, s0=say, md0=mouse.down, heard=[], r, h, i, src='', OLD;
     function said(re){ for(var j=0;j<heard.length;j++) if(re.test(heard[j].m)) return heard[j]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // ONE: one gun up, nothing stowed
       P.weapons=['rifle']; P.equipped='rifle'; P.equippedSec=null; P.hotAssign={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(p.sec&&p.sec.id==='fists'){ p.sec=null; p.secAmmo=0; }   // no second slot at all (Bare Hands would fill key 2)
       var sl=hotbarSlots();
       if(!(sl[1]&&sl[1].vacant)) return 'SKIP: staging: key 2 is not a vacant gun key with one gun';
       g.ents.length=0; p.iv=99; p.roll=0; p.downed=false; g.paused=false; g.bagOpen=false; g.mapOpen=false; keys={};
       say=function(m,k,o){ heard.push({m:String(m),sub:String((o&&o.sub)||'')}); };
       heard=[]; setHot(1);
       if(!said(/^GUN SLOT 2 EMPTY$/)) bad.push('the vacant key 2 says '+JSON.stringify(heard.map(function(x){ return x.m; }))+', not GUN SLOT 2 EMPTY');
       heard=[]; g.hot=2; p.fired=false; mouse.down=true; __sim(0.016); mouse.down=false; __sim(0.016);
       h=said(/^EMPTY SLOT$/);
       if(!h) bad.push('the trigger on the vacant key 3 says '+JSON.stringify(heard.map(function(x){ return x.m; }))+', not EMPTY SLOT');
       else if(!/^(PRESS \S+ FOR YOUR GUN|.+ TO YOUR GUN)$/.test(h.sub)) bad.push('EMPTY SLOT has '+JSON.stringify(h.sub)+' under it, not the key of the gun in capitals');
       g.hot=0;
       heard=[]; g.bag.push('gun_shotgun'); r=autoBelt('gun_shotgun');
       if(!/^[^a-z]+ ON KEY 2$/.test(String(r||''))||!said(/ ON KEY 2$/)) bad.push('a shotgun found onto key 2 says '+JSON.stringify(r)+', not SHOTGUN ON KEY 2');
       heard=[]; g.bag.push('gun_dmr'); autoBelt('gun_dmr'); g.bag.push('gun_smg'); autoBelt('gun_smg');
       heard=[]; g.bag.push('gun_carbine'); r=autoBelt('gun_carbine');
       h=said(/^GUN SLOTS FULL$/);
       if(!h) bad.push('a fifth gun says '+JSON.stringify(heard.map(function(x){ return x.m; }))+', not GUN SLOTS FULL');
       else if(!/ IN BACKPACK$/.test(h.sub)||h.sub!==h.sub.toUpperCase()) bad.push('GUN SLOTS FULL has '+JSON.stringify(h.sub)+' under it, not the gun IN BACKPACK');
       for(i=0;i<heard.length;i++) if(heard[i].m.length>34) bad.push('the headline '+JSON.stringify(heard[i].m)+' is longer than 34 characters');
       // TWO: no old belt sentence is left in the game
       [].slice.call(document.scripts).forEach(function(s){ src+=s.textContent||''; });
       OLD=[['No second',' weapon. Drag one'],['Nothing in',' that cell. '],[' is a weapon',' slot. Guns only'],['its own key',' brings it up'],[' to your empty',' slot. '],[' is issued',' kit; it stays'],['He puts',' his '],[' to belt',' slot '],['Gun slots full','. '],['Cannot equip'," \u0027+s2.name"],[' to backpack',", key "]];
       for(i=0;i<OLD.length;i++){ var nd=OLD[i][0]+OLD[i][1]; if(src.indexOf(nd)>=0) bad.push('the game still says '+JSON.stringify(nd)); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0; mouse.down=md0; keys={};
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
