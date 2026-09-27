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

if ($s.Contains("  {v:'16.79',what:")) { throw "check 16.79 is in the fixture already" }

SubRx @'
  {v:'16.78',what:
'@ @'
  {v:'16.79',what:'with the backpack open on a controller, A picks up the item under the highlight, D-DOWN still walks the stacks and past the last one lands on the tactical belt row, D-LEFT walks the belt keys, A places the item on the key under the highlight, A picks it back up, D-DOWN returns to the backpack and A puts it back there, as the mouse drag does; with the backpack shut A starts no drag',
   run:function(){
     if(typeof pollPad!=='function'||typeof raidKey!=='function'||typeof hotbarSlots!=='function'||typeof bagStacks!=='function'||typeof saveProfile!=='function'||!window.__deploy||!window.__endRaid||!window.__frame||!window.__P) return 'SKIP: this build has no controller raid path';
     var NGA=navigator.getGamepads, _sp=saveProfile, bad=[], down={}, k0=null, keepPHA=null, k1=null, g0=null;
     function pad(){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:!!down[q],value:down[q]?1:0,touched:!!down[q]}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function tap(q){ down={}; pollPad(); down[q]=1; pollPad(); down={}; pollPad(); __frame(0); }
     function cnt(k){ var n=0; for(var i=0;i<G.bag.length;i++) if(G.bag[i]===k) n++; return n; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: no live raid';
       g0=G; k0=keys; keys={};
       keepPHA=JSON.stringify(__P().hotAssign||{});
       saveProfile=function(){};   // the belt drop writes the plan and saves; stubbed as the 14.61 check stubs it
       navigator.getGamepads=pad;
       G.player.iv=99; G.player.downed=false;
       G.bag=['medkit','bandage']; G.hotAssign={}; G.hotAuto={}; G.drag=null; G.mapOpen=false; G.trade=null;
       G.bagOpen=true; G.bagSel=0; G.bagBelt=false; G.bagBeltSel=0;
       down={}; pollPad(); __frame(0);
       var N=hotbarSlots().length, last=N-1;
       if(!(G.hotCells&&G.hotCells.length===N&&N>=2)) return 'SKIP: the belt drew '+(G.hotCells?G.hotCells.length:0)+' cells for '+N+' keys';
       if(!(G.bagCells&&G.bagCells.length===2)) return 'SKIP: the backpack drew '+(G.bagCells?G.bagCells.length:0)+' cells for two stacks';
       k1=G.bagCells[0].key;
       tap(0);
       if(!(G.drag&&G.drag.key===k1)) bad.push('A did not pick up the item under the highlight ('+JSON.stringify(G.drag||null)+')');
       tap(13);
       if(G.bagBelt||G.bagSel!==1) bad.push('D-DOWN from the first stack did not step to the second, the v14.59 walk (belt '+(!!G.bagBelt)+', stack '+G.bagSel+')');
       tap(13);
       if(!G.bagBelt) bad.push('D-DOWN past the last stack did not move the highlight onto the tactical belt row');
       tap(14);
       if(G.bagBeltSel!==last) bad.push('D-LEFT on the belt row did not walk round to the last key ('+G.bagBeltSel+')');
       tap(0);
       if(G.drag) bad.push('A on a belt key did not place the item');
       if(!G.hotAssign||G.hotAssign[last]!==k1) bad.push('the item was not bound to the belt key under the highlight ('+JSON.stringify(G.hotAssign||{})+')');
       if(cnt(k1)!==1) bad.push('placing on the belt changed how many are carried ('+cnt(k1)+')');
       tap(0);
       if(!(G.drag&&G.drag.key===k1&&G.drag.fromHot===last)) bad.push('A on the bound key did not pick the item back up ('+JSON.stringify(G.drag||null)+')');
       tap(13);
       if(G.bagBelt||G.bagSel!==0) bad.push('D-DOWN from the belt row did not return to the first stack (belt '+(!!G.bagBelt)+', stack '+G.bagSel+')');
       tap(0);
       if(G.drag) bad.push('A in the backpack did not place the item');
       if(G.hotAssign&&G.hotAssign[last]!==undefined) bad.push('the item was not taken off its belt key ('+JSON.stringify(G.hotAssign)+')');
       if(cnt(k1)!==1) bad.push('unpacking changed how many are carried ('+cnt(k1)+')');
       // CONTROL: with the backpack shut A is the roll, not a pick-up.
       G.bagOpen=false; G.drag=null; down={}; pollPad(); tap(0);
       if(G.drag) bad.push('control: with the backpack shut A started a drag');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally { navigator.getGamepads=NGA; saveProfile=_sp; try{ down={}; keys=k0||{}; mouse.down=false; PAD.on=false; PAD.prev=[]; PAD.bagBtn=null; if(g0){ g0.drag=null; g0.bagOpen=false; g0.bagBelt=false; g0.bagBeltSel=0; g0.bag=[]; g0.hotAssign={}; g0.hotAuto={}; if(g0.player) g0.player.iv=0; } if(keepPHA!==null) __P().hotAssign=JSON.parse(keepPHA); if(g0&&!g0.over) __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
