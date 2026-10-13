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

if ($s.Contains("  {v:'25.76',what:")) { throw "check 25.76 is in the fixture already" }

SubRx @'
  {v:'25.75',what:
'@ @'
  {v:'25.76',what:'his order (hold H = armour plate, tap H = heal): a tap of H quick-heals and slots no plate, a half second hold slots a plate and does not heal, and a plate going on plays the armour clack of the foley bank (plateClack) at the start and at the landing, not the pick chirp',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updatePlayer!=='function'||typeof useArmor!=='function'||typeof tickPrepSlot!=='function'||!ITEMS.plate||!ITEMS.bandage) return 'SKIP: this fixture cannot stage the H key';
     var bad=[], g=null, p=null, kBlip=blip, kFoley=foley, kSay=say, kv=null, rec=[], k0=null;
     function dn(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function upk(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     function fr(n,dt){ for(var j=0;j<n;j++) updatePlayer(dt||0.05); }
     function clr(){ for(var z in keys) keys[z]=false; if(typeof HHOLD==='object'&&HHOLD) HHOLD.arm=0; }
     function stage(){ clr(); p.hp=50; p.maxhp=100; p.healQ=0; p.prep=null; p.prepA=null; p.armor=0; p.armorCap=60; g.bag.length=0; g.bag.push('bandage','plate'); g.paused=false; g.trade=null; p.downed=false; p.dying=false; p.roll=0; p.iv=99; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||g.sim) return 'SKIP: no live raid';
       k0={hp:p.hp,maxhp:p.maxhp,healQ:p.healQ,prep:p.prep,prepA:p.prepA,armor:p.armor,armorCap:p.armorCap,iv:p.iv}; kv=g.bag.slice();
       say=function(m){ return true; };
       // 1. a tap of H heals and slots no plate
       stage(); dn('KeyH'); fr(1); upk('KeyH'); fr(2);
       if(!p.prep||p.prep.kind!=='heal') bad.push('a tap of H did not start the heal ('+JSON.stringify(p.prep)+')');
       if(p.prepA) bad.push('a tap of H started a plate');
       // 2. a half second hold slots a plate and does not heal, and letting go after it does nothing more
       stage(); dn('KeyH'); fr(10);
       if(!p.prepA) bad.push('a half second hold of H slotted no plate');
       if(p.prep) bad.push('a hold of H also started the heal');
       upk('KeyH'); fr(3);
       if(p.prep) bad.push('letting go after a hold started the heal');
       if(g.bag.indexOf('plate')>=0) bad.push('the plate stayed in the backpack after the hold');
       // 3. the plate plays the armour clack, at the start and at the landing, and never the pick chirp
       stage(); rec=[];
       blip=function(t){ rec.push('b:'+t); }; foley=function(r){ rec.push('f:'+r); return true; };
       useArmor();
       if(!p.prepA) bad.push('useArmor started no plate wind-up here');
       if(rec.indexOf('f:plateClack')<0) bad.push('a plate going on played no armour clack ('+rec.join(',')+')');
       if(rec.indexOf('b:pick')>=0) bad.push('a plate going on still played the pick chirp ('+rec.join(',')+')');
       rec=[]; if(p.prepA) tickPrepSlot(p,'prepA',5);
       if(rec.indexOf('f:plateClack')<0) bad.push('the plate landing played no armour clack ('+rec.join(',')+')');
       if(rec.indexOf('b:pick')>=0) bad.push('the plate landing still played the pick chirp ('+rec.join(',')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ blip=kBlip; foley=kFoley; say=kSay; }catch(_b){}
       try{ clr(); if(p&&k0){ for(var f2 in k0){ if(k0[f2]===undefined) delete p[f2]; else p[f2]=k0[f2]; } } if(g&&kv) g.bag=kv; }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
