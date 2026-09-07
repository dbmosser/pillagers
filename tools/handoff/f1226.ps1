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

# v12.26 CHECK, inserted before the v12.25 entry. The smoke is selected on the
# belt with a smoke and a frag in the pouch; Q goes through the real key path
# and must turn the selector to the frag AND move the highlight to the frag
# cell, and a cook then produces a frag, so the belt and the trigger agree.
# Control: with the pouch empty Q says No throwables and moves nothing.
SubRx @'
  {v:'12.25',what:'standing in a second open ring while the ship is inbound to another leaves the called ring active with its own clock, and with no beacon anywhere the ring stood in still wins the pointer (2026-09-06 in-raid audit)',
'@ @'
  {v:'12.26',what:'Q moves the belt highlight to the throwable it makes ready, so the cell the belt lights is the one the trigger cooks; with an empty pouch it says No throwables and moves nothing (2026-09-06 in-raid audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof raidKey!=='function'||typeof hotbarSlots!=='function'||typeof hotSel!=='function'||typeof startCook!=='function'||typeof THROWKEYS==='undefined') return 'SKIP: no belt, key or cook path in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, sl=hotbarSlots(), iS=-1, iF=-1, i;
       for(i=0;i<sl.length;i++){ if(sl[i]&&sl[i].k==='throw:smoke') iS=i; if(sl[i]&&sl[i].k==='throw:frag') iF=i; }
       if(iS<0||iF<0) return 'SKIP: the belt has no smoke and frag cells to move between';
       var pb=document.getElementById('pausebox'); if(pb&&pb.classList.contains('on')&&typeof togglePauseBox==='function') togglePauseBox(false);
       g.pouch.smoke=1; g.pouch.frag=1; g.pouch.decoy=0;
       g.tsel=THROWKEYS.indexOf('smoke'); g.hot=iS; g.paused=false; g.over=false;
       p.downed=false; p.roll=0; p.cooking=0; p.cookT=0; p.cookKind=null; keys={};
       if(hotSel()!==iS) bad.push('control: the smoke cell could not be lit first (hotSel '+hotSel()+')');
       raidKey('KeyQ',false,null);
       if(g.tsel!==THROWKEYS.indexOf('frag')) bad.push('control: Q did not turn the selector to the frag (tsel '+g.tsel+')');
       if(hotSel()!==iF) bad.push('after Q the belt still lights cell '+hotSel()+' ('+(sl[hotSel()]?sl[hotSel()].k:'?')+') while the selector is on the frag');
       // The trigger agrees with the lit cell.
       if(!startCook()) bad.push('control: the pin did not come out');
       var lit=hotbarSlots()[hotSel()];
       if(p.cookKind&&lit&&lit.k!=='throw:'+p.cookKind) bad.push('the belt lights '+lit.k+' while the hand cooks a '+p.cookKind);
       p.cooking=0; p.cookT=0; p.cookKind=null;
       // CONTROL: nothing in the pouch; Q says so and moves nothing.
       g.pouch.smoke=0; g.pouch.frag=0; g.pouch.decoy=0; var hotBefore=hotSel(); window.__lastSay=null;
       raidKey('KeyQ',false,null);
       if(hotSel()!==hotBefore) bad.push('control: with an empty pouch Q moved the highlight');
       if(String(window.__lastSay||'').indexOf('No throwables')!==0) bad.push('control: with an empty pouch Q said "'+String(window.__lastSay||'')+'"');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ keys={}; try{ var g2=__state(); if(g2){ var p2=g2.player; p2.cooking=0; p2.cookT=0; p2.cookKind=null; if(!g2.over){ p2.downed=false; __endRaid('extract'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.25',what:'standing in a second open ring while the ship is inbound to another leaves the called ring active with its own clock, and with no beacon anywhere the ring stood in still wins the pointer (2026-09-06 in-raid audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
