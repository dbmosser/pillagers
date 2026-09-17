$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.25',what:
'@ @'
  {v:'15.26',what:'a Bandage put on while a Medkit is still healing does not ride the Medkit up to 100: from 30, a Medkit and then a Bandage with about 6 of the Medkit left end no higher than 85 plus those 6, while three Bandages from 50 still stop at 85, a Medkit from 60 and a Bandage then a Medkit from 70 still reach 100, and with the heal ceilings off the two stack past it again (his ruling of 2026-09-16)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof applyHeal!=='function'||typeof tickHeal!=='function'||typeof healCeil!=='function'||typeof healAmt!=='function'||!ITEMS.bandage||!ITEMS.medkit) return 'SKIP: no heal over time or heal ceiling in this build';
     var bad=[], g=null, p=null, keep=null, keepBag=null, keepCaps=CFG.healCaps;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function fresh(hp){ p.hp=hp; p.healQ=0; p.healRate=0; p.healCap=undefined; p.healHi=0; p.healLo=undefined; p.prep=null; }
     function drain(left){ for(var i=0;i<4000&&p.healQ>left;i++) tickHeal(0.05); return p.hp; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       p=g.player;
       keep={hp:p.hp,healQ:p.healQ,healRate:p.healRate,healCap:p.healCap,healHi:p.healHi,healLo:p.healLo,combatT:p.combatT,prep:p.prep};
       keepBag=(g.bag||[]).slice();
       var top=p.maxhp, lo=healCeil(ITEMS.bandage), aB=healAmt(ITEMS.bandage), aM=healAmt(ITEMS.medkit);
       // CONTROL: full health is 100, a Bandage stops at 85, and the items heal enough for every case below to reach its ceiling.
       if(top!==100||lo!==85) return 'SKIP: full health is '+top+' and the Bandage ceiling '+lo+' here';
       if(!(aB>=15&&aM>=40)) return 'SKIP: a Bandage heals '+aB+' and a Medkit '+aM+' here';
       // CONTROL A: three Bandages at once from 50 stop at 85, so the Bandage ceiling works at all.
       fresh(50); applyHeal('bandage'); applyHeal('bandage'); applyHeal('bandage');
       if(!(p.healQ>0)) return 'SKIP: a Bandage healed at once rather than over time here';
       var a=drain(0);
       if(a>lo+0.01) return 'SKIP: three Bandages from 50 reached '+a+', so the Bandage ceiling does not hold here';
       if(a<lo-0.01) bad.push('three Bandages from 50 stopped at '+a+', short of '+lo);
       // CONTROL B: a Medkit alone from 60 still reaches 100.
       fresh(60); applyHeal('medkit');
       var b=drain(0);
       if(b<top-0.01) bad.push('a Medkit from 60 stopped at '+b+', short of '+top);
       // THE FIX: a Medkit from 30 with about 6 left, then a Bandage. The Bandage may take him to 85 and the Medkit on by what it had left.
       fresh(30); applyHeal('medkit'); drain(6);
       var r=p.healQ;
       if(!(r>5&&r<=6&&p.hp<lo-5)) return skip('the Medkit from 30 did not leave about 6 below 85 here (left '+r+' at '+p.hp+')');
       applyHeal('bandage');
       var f=drain(0);
       if(f>lo+r+0.01) bad.push('from 30, a Bandage put on with '+r.toFixed(2)+' of a Medkit left ended at '+f.toFixed(2)+', past the '+(lo+r).toFixed(2)+' of 85 plus what the Medkit had left');
       if(f<lo+r-0.01) bad.push('from 30, a Bandage put on with '+r.toFixed(2)+' of a Medkit left stopped at '+f.toFixed(2)+', short of '+(lo+r).toFixed(2));
       // A Bandage from 70, part spent, then a Medkit: the Medkit still takes him to 100.
       fresh(70); applyHeal('bandage'); drain(10); applyHeal('medkit');
       var d=drain(0);
       if(d<top-0.01) bad.push('a Bandage from 70 and then a Medkit stopped at '+d.toFixed(2)+', short of '+top);
       // With the heal ceilings off, the same Medkit then Bandage stacks past 85 plus the Medkit left, as it always did.
       CFG.healCaps=0;
       fresh(30); applyHeal('medkit'); drain(6);
       var r2=p.healQ;
       applyHeal('bandage');
       var e=drain(0);
       if(!(e>lo+r2+0.01)) bad.push('with the heal ceilings off, a Medkit from 30 and then a Bandage stopped at '+e.toFixed(2)+', not past '+(lo+r2).toFixed(2));
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       CFG.healCaps=keepCaps;
       try{ if(p&&keep){ p.hp=keep.hp; p.healQ=keep.healQ; p.healRate=keep.healRate; p.healCap=keep.healCap; p.healHi=keep.healHi; p.healLo=keep.healLo; p.combatT=keep.combatT; p.prep=keep.prep; } }catch(_k){}
       try{ if(g&&keepBag) g.bag=keepBag; }catch(_b){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
