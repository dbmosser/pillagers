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

if ($s.Contains("  {v:'25.95',what:")) { throw "check 25.95 is in the fixture already" }

SubRx @'
  {v:'25.94',what:
'@ @'
  {v:'25.95',what:'his decision (tap H uses the cheapest heal that helps): with a Bandage on key 7, a Medkit on key 8 and a Stim in the backpack, a tap uses the Bandage; at 90 health, past the Bandage ceiling, it uses the Medkit; it never uses the Stim; with only a Stim and an empty Medkit key on the belt and a Bandage in the backpack it says NO HEAL ON BELT with the backpack key under it and spends nothing; with nothing at all it says NO MEDICAL SUPPLIES',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof quickHeal!=='function'||typeof hotbarSlots!=='function'||!ITEMS.bandage||!ITEMS.medkit||!ITEMS.stim) return 'SKIP: no quick heal, belt or medical items here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], s0=say, said=[], g=null, p=null, n0;
     function cnt(k){ var c=0, j; for(j=0;j<g.bag.length;j++) if(g.bag[j]===k) c++; return c; }
     function hurt(hp){ p.hp=hp; p.healQ=0; p.healRate=0; p.healCap=undefined; p.prep=null; p.downed=false; p.dying=false; said.length=0; }
     function line(re){ for(var j=0;j<said.length;j++) if(re.test(said[j].m)) return said[j]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; p.maxhp=100; keys={}; g.paused=false; g.trade=null;
       say=function(m,k,o){ said.push({m:String(m),k:k,o:o||{}}); };
       // ONE: the cheapest that helps
       g.bag=['bandage','bandage','medkit','stim']; g.hotAssign={6:'bandage',7:'medkit'}; g.hotAuto={}; g.hotPruned={};
       hurt(50); quickHeal();
       if(cnt('bandage')!==1||cnt('medkit')!==1) bad.push('ONE: a tap at 50 health left '+cnt('bandage')+' Bandage and '+cnt('medkit')+' Medkit, not 1 and 1 (the Bandage is the cheapest)');
       // TWO: past the Bandage ceiling the Medkit is the one that helps
       hurt(90); quickHeal();
       if(cnt('bandage')!==1||cnt('medkit')!==0) bad.push('TWO: a tap at 90 health left '+cnt('bandage')+' Bandage and '+cnt('medkit')+' Medkit, not 1 and 0');
       if(cnt('stim')!==1) bad.push('TWO: the Stim was used');
       // THREE: no heal on the belt, a heal in the backpack
       g.bag=['bandage','stim']; g.hotAssign={6:'stim',7:'medkit'}; g.hotAuto={};
       hurt(50); quickHeal();
       n0=cnt('bandage');
       if(n0!==1||cnt('stim')!==1) bad.push('THREE: with no heal on the belt a tap spent something (bandage '+cnt('bandage')+', stim '+cnt('stim')+')');
       if(!line(/^NO HEAL ON BELT$/)) bad.push('THREE: a tap with no heal on the belt said '+JSON.stringify(said.map(function(x){ return x.m; })));
       else if(!/BACKPACK/.test(String(line(/^NO HEAL ON BELT$/).o.sub||''))) bad.push('THREE: NO HEAL ON BELT has '+JSON.stringify(line(/^NO HEAL ON BELT$/).o.sub)+' under it, not the backpack key');
       // FOUR: nothing but a Stim
       g.bag=['stim']; g.hotAssign={6:'stim'}; g.hotAuto={};
       hurt(50); quickHeal();
       if(cnt('stim')!==1) bad.push('FOUR: a tap used the Stim');
       if(!line(/^NO MEDICAL SUPPLIES$/)) bad.push('FOUR: a tap with only a Stim said '+JSON.stringify(said.map(function(x){ return x.m; })));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.hotAssign={}; g2.hotAuto={}; if(g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.prep=null; g2.player.healQ=0; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_m){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
