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

# v11.97 CHECK, inserted before the v11.96 entry. Four cases through the
# real verb, reading what it says through the fixture's say capture.
SubRx @'
  {v:'11.96',what:'dying with the free kit does not delete the Scav Pistol you own, and the loaner is not counted as a gun you lost (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'11.97',what:'the heal verb says Only bandages left above their reach, says Already at full with a Medkit at full health, and keeps a second Bandage that cannot raise you past what is already inbound, while a Medkit over running Bandages is still taken (2026-09-06 audits)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof useMedical!=='function'||typeof healCeil!=='function') return 'SKIP: no heal verb in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, cap=healCeil(ITEMS.bandage);
       if(!(cap<p.maxhp)) return 'SKIP: bandages have no ceiling under this profile';
       p.downed=false; p.prep=null; p.healQ=0;
       // ONE: two Bandages, health at their ceiling.
       g.bag=['bandage','bandage']; p.hp=cap; window.__lastSay=null;
       var r1=useMedical(), s1=String(window.__lastSay||'');
       if(r1||g.bag.length!==2) bad.push('at '+cap+' health with only Bandages the verb spent one');
       if(!/Only bandages left/.test(s1)) bad.push('at '+cap+' health with only Bandages the verb said "'+s1+'"');
       // TWO: a Medkit at full health.
       g.bag=['medkit']; p.hp=p.maxhp; p.healQ=0; window.__lastSay=null;
       var r2=useMedical(), s2=String(window.__lastSay||'');
       if(r2||g.bag.length!==1) bad.push('at full health the verb spent the Medkit');
       if(!/Already at full/.test(s2)) bad.push('at full health with a Medkit the verb said "'+s2+'"');
       // THREE: a Bandage already inbound reaches the ceiling; the second is kept.
       g.bag=['bandage']; p.hp=cap-20; p.healQ=25; p.healCap=cap; p.prep=null; window.__lastSay=null;
       var r3=useMedical();
       if(r3||g.bag.length!==1) bad.push('a second Bandage was spent although the first already reaches '+cap+' (bag now '+g.bag.join(',')+')');
       // FIVE: a Medkit over running Bandages is still taken; the queue delivers only to their ceiling.
       g.bag=['medkit']; p.hp=cap-20; p.healQ=25; p.healCap=cap; p.prep=null; window.__lastSay=null;
       var r5=useMedical();
       if(!r5||g.bag.length!==0) bad.push('a Medkit over running Bandages was refused ("'+String(window.__lastSay||'')+'")');
       p.healQ=0; p.healCap=undefined; p.prep=null;
       // CONTROL: a Bandage under the ceiling with nothing inbound is used.
       g.bag=['bandage']; p.hp=cap-30; p.healQ=0; p.prep=null; window.__lastSay=null;
       var r4=useMedical();
       if(!r4||g.bag.length!==0) bad.push('control: a Bandage at '+(cap-30)+' health was refused ("'+String(window.__lastSay||'')+'")');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.prep=null; g2.player.healQ=0; g2.player.healCap=undefined; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.96',what:'dying with the free kit does not delete the Scav Pistol you own, and the loaner is not counted as a gun you lost (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
