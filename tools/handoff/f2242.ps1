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

if ($s.Contains("  {v:'22.42',what:")) { throw "check 22.42 is in the fixture already" }

SubRx @'
  {v:'22.41',what:
'@ @'
  {v:'22.42',what:'a Stim keeps a belt key when key 9 is the plate: a Stim pinned to key 9 moves to a free gun key when he picks up an Armour Plate instead of leaving the belt, and a Stim found while carrying a plate goes on a vacant gun key; Medical and the plate keep their keys',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof autoBelt!=='function'||typeof hotbarSlots!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4) return 'SKIP: no four gun keys here';
     if(!ITEMS.stim||!ITEMS.plate||!WEAPONS.rifle||!WEAPONS.smg) return 'SKIP: no stim, plate, rifle or smg here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, sl, s0=say;
     function find(s,k){ for(var i=0;i<s.length;i++) if(s[i]&&(s[i].k===k||s[i].itemKey===k)) return i; return -1; }
     function keysOf(s){ return s.map(function(c){ return c?c.k:'-'; }).join(', '); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       say=function(){};
       // ONE: a Stim pinned with no plate, then a plate picked up
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.bag.indexOf('plate')>=0||g.bag.indexOf('stim')>=0) return 'SKIP: staging: a plate or a stim went up with an empty kit';
       g.bag.push('stim'); autoBelt('stim');
       sl=hotbarSlots();
       if(find(sl,'stim')<0) return 'SKIP: staging: the found Stim took no key with no plate carried ('+keysOf(sl)+')';
       g.bag.push('plate');
       sl=hotbarSlots(); sl=hotbarSlots();
       if(find(sl,'stim')<0) bad.push('picking up an Armour Plate took the Stim off the belt: its pin found no empty key and was deleted ('+keysOf(sl)+')');
       if(find(sl,'plate')<0) bad.push('the Armour Plate has no key ('+keysOf(sl)+')');
       if(find(sl,'heal')<0) bad.push('Medical has no key ('+keysOf(sl)+')');
       if(!(sl[0]&&sl[0].icon==='rifle'&&sl[1]&&sl[1].icon==='smg')) bad.push('keys 1 and 2 no longer show the rifle and the SMG ('+keysOf(sl)+')');
       __endRaid('abandon'); __topClear();
       // TWO: carrying a plate, a Stim found
       __cleanProfile(); P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={};
       __deploy({kit:['plate'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid with a plate';
       if(g.bag.indexOf('plate')<0) return 'SKIP: staging: the plate did not go up';
       g.bag.push('stim'); autoBelt('stim');
       sl=hotbarSlots();
       if(find(sl,'stim')<0) bad.push('a Stim found while carrying a plate got no belt key ('+keysOf(sl)+')');
       if(find(sl,'plate')<0) bad.push('with a plate and a found Stim the plate has no key ('+keysOf(sl)+')');
       if(find(sl,'heal')<0) bad.push('with a plate and a found Stim Medical has no key ('+keysOf(sl)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0;
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player) g2.player.downed=false; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
