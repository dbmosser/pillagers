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
  {v:'15.16',what:
'@ @'
  {v:'15.17',what:'a restocked crate or locker drops off the Data Core key marks: with a core burned at seed 4242, a crate and a locker that each held a key, were opened and restock on one frame leave the key list and the sector map draws no KEY on them, while a shut container still holding its key stays on the list and keeps its KEY (mainframe audit finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof updateEnts!=='function'||typeof mkContainer!=='function'||typeof drawMapOverlay!=='function'||typeof mapLabel!=='function'||typeof mapProj!=='function') return 'SKIP: this build has no container restock or sector map';
     var bad=[], snap=null, g=null, _ml=mapLabel, drawn=[];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var hasKey=function(x){ var l=(x&&x.loot)||[]; for(var q=0;q<l.length;q++) if(String(l[q]).indexOf('key_')===0) return true; return false; };
     var shut=function(x){ return !!x&&!x.dropped&&!x.opened&&Array.isArray(x.loot); };
     var apart=function(a,b){ return Math.abs(a.x-b.x)>40||Math.abs(a.y-b.y)>40; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __P().intel=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       // CONTROL: the ascent burned the core and built the key list the sector map draws its KEY marks from.
       if(!g.intel||!Array.isArray(g.intelKeys)||__P().intel) return 'SKIP: the Data Core did not burn on this ascent here';
       if(typeof g.t!=='number'||!isFinite(g.t)) return 'SKIP: this raid has no clock to restock against';
       var i, j, x, kid='', cr=null, lo=null, kp=null;
       for(i=0;i<g.intelKeys.length&&!kid;i++){ x=g.intelKeys[i]; for(j=0;j<(x.loot||[]).length;j++) if(String(x.loot[j]).indexOf('key_')===0){ kid=String(x.loot[j]); break; } }
       if(!kid&&g.map&&g.map.locked&&g.map.locked.length) kid='key_'+g.map.locked[0].id;
       if(!kid||!ITEMS[kid]) return 'SKIP: no locked room key to stage on this map ('+kid+')';
       for(i=0;i<g.containers.length;i++){
         x=g.containers[i];
         if(!shut(x)) continue;
         if(!cr&&x.type==='crate') cr=x;
         else if(!lo&&x.type==='locker') lo=x;
       }
       if(!cr||!lo) return 'SKIP: this raid has no shut crate and shut locker to stage';
       // The third container prefers one the game itself marked, and sits apart from the other two so its KEY is not theirs.
       for(i=0;i<g.intelKeys.length&&!kp;i++){ x=g.intelKeys[i]; if(x!==cr&&x!==lo&&shut(x)&&hasKey(x)&&apart(x,cr)&&apart(x,lo)) kp=x; }
       for(i=0;i<g.containers.length&&!kp;i++){ x=g.containers[i]; if(x!==cr&&x!==lo&&shut(x)&&apart(x,cr)&&apart(x,lo)) kp=x; }
       if(!kp) return 'SKIP: no third shut container to hold a key';
       // THE STAGE: the crate, the locker and the third container each hold the key and sit on the list. The crate and the
       // locker were opened 200 s ago, past the 170 s restock; the third stays shut.
       var stage=[cr,lo,kp];
       for(i=0;i<stage.length;i++){
         if(!hasKey(stage[i])) stage[i].loot.push(kid);
         if(g.intelKeys.indexOf(stage[i])<0) g.intelKeys.push(stage[i]);
       }
       var crL=cr.loot, loL=lo.loot, due=(g.t-200)||-200;
       cr.opened=true; cr.openedAt=due; lo.opened=true; lo.openedAt=due;
       updateEnts(0.016);
       // CONTROL: the frame restocked both: new loot, shut again, the clock cleared, and no key rolled into either.
       if(cr.opened!==false||cr.openedAt!==null||cr.loot===crL) return 'SKIP: the crate opened 200 s ago was not restocked on this frame';
       if(lo.opened!==false||lo.openedAt!==null||lo.loot===loL) return 'SKIP: the locker opened 200 s ago was not restocked on this frame';
       if(hasKey(cr)||hasKey(lo)) return 'SKIP: a restock rolled a key here, so its KEY mark would be true';
       // CONTROL: the third container is still shut and still holds its key.
       if(kp.opened||!hasKey(kp)) return 'SKIP: the third container was opened or emptied on this frame';
       var listed=[cr,lo].filter(function(c){ return g.intelKeys.indexOf(c)>=0; });
       if(listed.length) bad.push('the Data Core key list still holds the restocked '+listed.map(function(c){ return c.type; }).join(' and ')+', shut again with no key inside');
       // THE FIX IS NARROW: a container that did not restock keeps its place on the list.
       if(g.intelKeys.indexOf(kp)<0) bad.push('a shut container still holding its key left the Data Core key list on a frame that did not restock it');
       // THE MAP: what he reads. Every KEY label the sector map places is recorded where it is placed.
       if(!window.innerWidth||!window.innerHeight) return skip('the pane is 0x0, so the sector map cannot be drawn');
       var derr='';
       mapLabel=function(t,lx,ly){ try{ if(String(t)==='KEY') drawn.push({x:lx,y:ly}); }catch(_q){} return _ml.apply(this,arguments); };
       try{ drawMapOverlay(); }catch(de){ derr=' ('+(de&&de.message||de)+')'; }
       mapLabel=_ml;
       var M=mapProj();
       var at=function(c){ var ex=M.ox+c.x*M.sc, ey=M.oy+c.y*M.sc-9; for(var d=0;d<drawn.length;d++) if(Math.abs(drawn[d].x-ex)<0.5&&Math.abs(drawn[d].y-ey)<0.5) return true; return false; };
       // CONTROL: the map drew the intel marks: the third container carries its KEY.
       if(!at(kp)) return skip('the sector map drew no KEY on the shut container still holding its key, so the intel marks were not drawn here'+derr);
       var marked=[cr,lo].filter(function(c){
         if(!at(c)) return false;
         // A KEY on that spot that belongs to another shut container on the list is that container's mark.
         for(var o=0;o<g.intelKeys.length;o++){ var ot=g.intelKeys[o]; if(ot!==cr&&ot!==lo&&!ot.opened&&Math.abs((ot.x-c.x)*M.sc)<0.5&&Math.abs((ot.y-c.y)*M.sc)<0.5) return false; }
         return true;
       });
       if(marked.length) bad.push('the sector map draws KEY on the restocked '+marked.map(function(c){ return c.type; }).join(' and ')+' with no key inside');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       mapLabel=_ml;
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
