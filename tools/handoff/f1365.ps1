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
  {v:'13.64',what:
'@ @'
  {v:'13.65',what:'a Medkit bound to its own belt key is used when the Bandage heal queued ahead of it stops at 85, the same as the Medical cell, instead of being refused as Already healing (in-raid audit 2026-09-14, finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof useHot!=='function'||typeof setHot!=='function'||typeof hotbarSlots!=='function'||!ITEMS.medkit) return 'SKIP: no belt in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.ents.length=0; p.iv=99; p.prep=null; p.downed=false;
       g.bag=['medkit'];
       var last=hotbarSlots().length-1;
       g.hotAssign={}; g.hotAssign[last]='medkit'; if(g.hotAuto) g.hotAuto={};
       var s2=hotbarSlots()[last];
       if(!(s2&&s2.assigned&&s2.itemKey==='medkit')) return 'SKIP: the Medkit did not take the key';
       // THE FINDING: Bandage heal queued past full, stopping at 85.
       p.hp=50; p.healQ=60; p.healRate=10; p.healCap=85;
       setHot(last); useHot();
       if(g.bag.indexOf('medkit')>=0) bad.push('with Bandage heal queued past full under an 85 ceiling at 50 health, the Medkit on its own key was refused');
       // CONTROL: nothing running at 50, the same key uses it.
       p.hp=50; p.healQ=0; p.healRate=0; p.healCap=undefined; p.prep=null; g.bag=['medkit'];
       g.hot=-1; setHot(last); useHot();
       if(g.bag.indexOf('medkit')>=0) bad.push('control: at 50 health with nothing running the Medkit key did not use it, so this check cannot see a use');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.prep=null; } if(g2) g2.hotAssign={}; if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
