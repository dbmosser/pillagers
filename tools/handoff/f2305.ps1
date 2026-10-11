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

if ($s.Contains("  {v:'23.05',what:")) { throw "check 23.05 is in the fixture already" }

SubRx @'
  {v:'23.04',what:
'@ @'
  {v:'23.05',what:'tactical belt and gun lines in the slot word: a Medkit dropped on slot 9 says MEDKIT TO SLOT 9, dragged off says MEDKIT OFF SLOT 9, a tired roll, a throwable select with none, an empty throwable slot and an issued gun put away each say a caps headline, and no belt or gun line says cell, belt slot without tactical, key and a number, a semicolon, weapon slot or kit',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof hotbarSlots!=='function'||typeof tryRoll!=='function'||typeof cycleThrow!=='function'||typeof emptyThrowCell!=='function'||typeof bagHeldGun!=='function'||typeof cv==='undefined'||!cv||typeof mouse!=='object'||!mouse||!ITEMS.medkit) return 'SKIP: no belt drags, rolls or throwables here';
     var bad=[], P2=__P(), ha0=P2.hotAssign?JSON.parse(JSON.stringify(P2.hotAssign)):P2.hotAssign, mx0=mouse.x, my0=mouse.y, md0=mouse.down, realSay=say, said=[],
         g=null, p=null, MK=ITEMS.medkit.name.toUpperCase(), K9={x:900,y:700,w:40,h:40,i:8}, K1={x:100,y:700,w:40,h:40,i:0}, k, l, all=[];
     function up(C){ if(C){ mouse.x=C.x+20; mouse.y=C.y+20; } else { mouse.x=1500; mouse.y=300; } window.dispatchEvent(new MouseEvent('mouseup',{button:0})); }
     function last(){ return said.length?said[said.length-1]:null; }
     function need(tag,want){ var L=last(); if(!L) bad.push(tag+': said nothing'); else if(want&&!want.test(L.m)) bad.push(tag+': said '+JSON.stringify(L.m)); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; p.iv=99; keys={}; p.roll=0; p.downed=false; p.dying=false;
       say=function(t,kd,o){ said.push({m:String(t),sub:(o&&o.sub)?String(o.sub):''}); all.push(said[said.length-1]); };
       g.bag=['medkit']; g.drag=null; g.hotPruned={};
       g.bagOpen=true; g.bagCells=[]; g.bagPanel=null; g.mapOpen=false; g.trade=null; g.paused=false;
       g.hotCells=[K1,K9];
       // ONE: a Medkit dropped on slot 9, then dragged off
       said.length=0; g.drag={key:'medkit',bagIx:0,px:0,py:0}; up(K9); g.drag=null;
       if(g.hotAssign&&g.hotAssign[8]==='medkit'){
         need('a Medkit dropped on slot 9',new RegExp('^'+MK+' TO SLOT 9$'));
         said.length=0; g.drag={key:'medkit',fromHot:8,px:K9.x+20,py:K9.y+20}; up(null); g.drag=null;
         need('slot 9 dragged off the belt',new RegExp('^'+MK+' OFF SLOT 9$'));
       } else bad.push('staging: the Medkit did not go on slot 9 ('+JSON.stringify(g.hotAssign)+')');
       g.bagOpen=false; g.hotCells=[];
       // TWO: a tired roll
       p.stam=0; p.rollCd=0; p.roll=0; g.rollSayT=0; said.length=0; tryRoll(); need('a roll with no stamina',/^TOO TIRED TO ROLL$/); p.stam=100;
       // THREE: a throwable select with none, and an empty throwable slot
       if(g.pouch) for(k in g.pouch) g.pouch[k]=0;
       said.length=0; cycleThrow(); need('a throwable select with none',/^NO THROWABLE/);
       said.length=0; emptyThrowCell('frag'); need('an empty throwable slot',/ LEFT$/);
       // FOUR: the issued gun put away
       if(!p.wep||p.wep.id==='fists'||!(p.wep.mag>0)){ for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0){ var cw={}, f; for(f in WEAPONS[k]) cw[f]=WEAPONS[k][f]; p.wep=cw; p.ammo=cw.mag; break; } }
       p.swapped=false; p.wepIssued=true; said.length=0; bagHeldGun('gunA'); need('an issued gun put away',/^ISSUED GEAR/); p.wepIssued=false;
       // every line said: caps, and the slot word
       for(k=0;k<all.length;k++){
         l=all[k]; var s=l.m+' '+l.sub;
         if(l.m==='Nothing to '+'pick up.') continue;   // his word (v14.78), never reworded
         if(l.m!==l.m.toUpperCase()||l.m.length>34||(/[.!?;:]$/).test(l.m)) bad.push(JSON.stringify(l.m)+' is not a caps headline of at most 34');
         if((/\bcell\b/i).test(s)) bad.push(JSON.stringify(s)+' says cell');
         if((/belt slot/i).test(s)&&!(/tactical belt slot/i).test(s)) bad.push(JSON.stringify(s)+' says belt slot');
         if((/\bkey \d/i).test(s)) bad.push(JSON.stringify(s)+' names a key and a number, not a slot');
         if(s.indexOf(';')>=0) bad.push(JSON.stringify(s)+' has a semicolon');
         if((/weapon slot/i).test(s)) bad.push(JSON.stringify(s)+' says weapon slot');
         if((/\bkit\b/i).test(s)) bad.push(JSON.stringify(s)+' says kit, not issued gear');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; mouse.x=mx0; mouse.y=my0; mouse.down=md0; keys={};
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; g2.player.wepIssued=false; __endRaid('abandon'); } } }catch(_e){}
       try{ var P3=__P(); P3.hotAssign=ha0; }catch(_h){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
