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

# v11.59 CHECK, inserted before the v11.58 entry. Driven through the real belt
# functions: hotbarSlots builds the bar, setHot selects, useHot acts.
SubRx @'
  {v:'11.58',what:'the extraction inbound pulse, touchdown and last call and the storm telegraph draw the heard-not-seen noise ring like every other sound (his note of 2026-09-05): ring sizes exist, an unseen source rings and a seen one does not, and the four call sites are positioned',
'@ @'
  {v:'11.59',what:'a Frag Charge put on a tactical belt key is a live throwable cell: it shows the pouch count, it is the only cell for that grenade, selecting it points the throw selector at it, and the key throws it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     if(typeof hotbarSlots!=='function'||typeof setHot!=='function'||typeof useHot!=='function') return 'SKIP: no tactical belt in this build';
     var bad=[], SLOT=1;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.over=false; p.downed=false; p.roll=0;
       g.pouch=g.pouch||{}; g.pouch.frag=2;
       g.hotAssign={}; g.hotAssign[SLOT]='frag';
       g.hot=0;
       var sl=hotbarSlots();
       if(!sl||sl.length<=SLOT) return 'SKIP: the belt has no slot '+SLOT+' on this build';
       var cell=sl[SLOT];
       // THE CELL IS A THROWABLE, not the dead item cell the trigger treats as a gun.
       if(cell.kind!=='throw') bad.push('a Frag Charge on belt key '+(SLOT+1)+' builds a "'+cell.kind+'" cell, so the trigger fires your gun instead of cooking it and the key does nothing');
       if(cell.count!==2) bad.push('the belted Frag Charge reads x'+cell.count+' while the pouch holds 2');
       // AND IT IS THE ONLY ONE. The dedupe must blank the derived cell, not this.
       var live=0;
       for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].k==='throw:frag') live++;
       if(live!==1) bad.push('the bar carries '+live+' cells for the same Frag Charge');
       // SELECTING IT POINTS THE THROW SELECTOR AT IT.
       if(cell.kind==='throw'){
         setHot(SLOT);
         var want=THROWKEYS.indexOf('frag');
         if(g.tsel!==want) bad.push('selecting the belted Frag Charge left the throw selector on '+THROWKEYS[g.tsel]+' instead of frag');
         // AND THE KEY THROWS IT.
         var n0=(g.throws||[]).length, q0=g.pouch.frag;
         useHot();
         if((g.pouch.frag|0)!==q0-1) bad.push('the key did not spend a Frag Charge (pouch '+q0+' then '+g.pouch.frag+')');
         if((g.throws||[]).length<=n0) bad.push('the key threw nothing');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2){ g2.hotAssign={}; g2.throws=[]; } }catch(_r){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.58',what:'the extraction inbound pulse, touchdown and last call and the storm telegraph draw the heard-not-seen noise ring like every other sound (his note of 2026-09-05): ring sizes exist, an unseen source rings and a seen one does not, and the four call sites are positioned',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
