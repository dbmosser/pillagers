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

# THE PIN TABLE FOLLOWS THE DEFAULT: healSolo is gone from DEF, so it goes
# from the fixture's pin table too.
SubRx @'
smokeR:165,fragR:190,healSolo:1
'@ @'
smokeR:165,fragR:190
'@

# v11.82 CHECK, inserted before the v11.81 entry. The real verbs are driven
# on a real raid: useMedical twice, useArmor between, the game's own tickHeal
# for the timers, and say() captured to prove the refusal is never printed.
SubRx @'
  {v:'11.81',what:'the KILLED IN ACTION card no longer says how many seconds of cutting were lost with you, and an extraction still banks the cut (his order of 2026-09-06)',
'@ @'
  {v:'11.82',what:'the next bandage goes on while the prior one is still healing and a plate goes on while a bandage is being applied; the one-at-a-time refusal and its countdown are gone (his notes of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof useMedical!=='function'||typeof useArmor!=='function'||typeof tickHeal!=='function') return 'SKIP: no medical verbs in this build';
     var bad=[], said=[], realSay=say, refusal='Still '+'applying prior';
     say=function(m){ said.push(String(m)); return realSay.apply(null,arguments); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       p.hp=30; p.armor=0; p.healQ=0; p.healRate=0; p.healCap=undefined; p.prep=null; p.prepA=null; p.downed=false;
       g.bag=['bandage','bandage','plate'];
       useMedical();
       if(!p.prep||g.bag.length!==2) bad.push('control: the first bandage did not start applying (bag '+g.bag.join(',')+')');
       tickHeal(1.6);   // the 1.5 s application finishes and the bandage starts healing
       var q1=p.healQ||0;
       if(!(q1>0)) bad.push('control: after the application the first bandage is not healing (queue '+q1.toFixed(1)+')');
       // THE NEXT BANDAGE WHILE THE PRIOR ONE HEALS.
       useMedical();
       if(!p.prep) bad.push('the second bandage was refused while the first was still healing');
       if(g.bag.indexOf('bandage')>=0) bad.push('the second bandage is still in the bag');
       // A PLATE WHILE THE BANDAGE IS BEING APPLIED.
       useArmor();
       if(!p.prepA) bad.push('the plate was refused while a bandage was being applied');
       if(g.bag.indexOf('plate')>=0) bad.push('the plate is still in the bag');
       for(var i=0;i<said.length;i++) if(said[i].indexOf(refusal)===0) bad.push('the game still said "'+said[i].slice(0,40)+'"');
       tickHeal(2.2);   // both timers finish (1.5 and 2.0)
       var q2=p.healQ||0;
       if(p.prep||p.prepA) bad.push('control: a timer is still running after 2.2 s');
       if(!(q2>q1)) bad.push('the second bandage did not add to the heal queue ('+q1.toFixed(1)+' before, '+q2.toFixed(1)+' after)');
       if(!(p.armor>=19)) bad.push('the plate did not go on (armour '+p.armor+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say=realSay; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.81',what:'the KILLED IN ACTION card no longer says how many seconds of cutting were lost with you, and an extraction still banks the cut (his order of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
