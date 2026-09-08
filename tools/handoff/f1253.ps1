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

# v12.53 CHECK, inserted before the v12.52 entry. The unreachable point is the
# world corner outside the playable edge, which is unreachable by construction
# on every map and every seed rather than by picking a building this seed
# happens to have. The control is an open point found by asking the map itself,
# and it has to end by ARRIVING rather than by the clock, or the fix would have
# turned every search into a timer.
SubRx @'
  {v:'12.52',what:'a pillager whose whole reach is inside his own blast does not throw a charge at all, instead of throwing from a band one unit wide inside his own explosion; an ordinary pillager still throws from outside the blast and his charge still lands clear of him (2026-09-07 audit, my defect from v12.20)',
'@ @'
  {v:'12.53',what:'a machine searching for him gives up on a point it can never reach instead of pushing at the nearest wall for the rest of the raid, and the scatter that chooses that point no longer picks somewhere a body cannot stand; a search of open ground still ends by arriving (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__ents&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid and step the machines';
     if(typeof spotFree!=='function') return 'SKIP: this build has no open-ground test to hold the scatter to';
     var bad=[];
     function stage(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player, i, e=null;
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='crawler'&&!g.ents[i].downed&&!g.ents[i].finished) e=g.ents[i];
       if(!e) return {none:'no crawler on this map and seed to send searching'};
       g.ents.length=0; g.ents.push(e);
       p.downed=false; p.iv=99; p.hp=100;
       // Parked far away and out of the way, so nothing here is a chase.
       p.x=e.x+2600; p.y=e.y+2600;
       e.hp=e.maxhp||e.hp; e.downed=false; e.finished=false; e.alert=0; e.chaseHold=0;
       e.path=null; e.pathFail=false; e.invT=0; e.invGoal=null;
       return {g:g,e:e,p:p};
     }
     function search(st,tx,ty,secs){
       var e=st.e, g=st.g, i, x0=e.x, y0=e.y, last={x:e.x,y:e.y}, moved=0;
       e.state='investigate'; e.tx=tx; e.ty=ty; e.scattered=1;
       for(i=0;i<Math.round(secs/0.05);i++){
         __ents(0.05);
         if(e.state!=='investigate') break;
       }
       moved=Math.sqrt((e.x-x0)*(e.x-x0)+(e.y-y0)*(e.y-y0));
       return {state:e.state,secs:i*0.05,moved:moved,
               left:Math.sqrt((e.x-tx)*(e.x-tx)+(e.y-ty)*(e.y-ty))};
     }
     try{
       var st=stage();
       if(!st) return 'SKIP: no live raid to search in';
       if(st.none) return 'SKIP: '+st.none;
       // THE FINDING: a point outside the playable edge, which no map and no
       // seed can ever make reachable, so this arm is the same on every one.
       var A=search(st,-600,-600,30);
       if(A.state==='investigate')
         bad.push('a machine sent to search a point nothing can stand on was still searching it after '+Math.round(A.secs)+' seconds, '+Math.round(A.left)+' units short and unable to close, and nothing else in the game can free it: it pushes at that wall for the rest of the raid');
       // CONTROL ONE: an open point it CAN reach must still end by arriving, and
       // well inside the clock, or the fix has turned every search into a timer.
       var st2=stage();
       if(st2&&!st2.none){
         var e2=st2.e, g2=st2.g, ox=0, oy=0, sc;
         for(sc=1;sc<=14&&!ox;sc++){
           var cx=e2.x+sc*22, cy=e2.y;
           if(spotFree(g2.map,cx,cy,12)&&walkClearR&&walkClearR(e2.x,e2.y,cx,cy,e2.r)){ ox=cx; oy=cy; }
         }
         if(!ox) return 'SKIP: no open ground within 300 units of the crawler on this seed, so the control cannot be staged';
         var B=search(st2,ox,oy,30);
         if(B.state==='investigate') bad.push('control: a machine sent to open ground '+Math.round(Math.sqrt((ox-e2.x)*(ox-e2.x)))+' units away never got there in thirty seconds, so this check cannot see a search end at all');
         else if(B.secs>19) bad.push('control: a search of open ground ended after '+Math.round(B.secs)+' seconds, which is the clock rather than the arrival, so the fix has turned every search into a timer');
       }
       // CONTROL TWO: and the scatter itself now picks somewhere a body can
       // stand, which is the other half of the build.
       var st3=stage();
       if(st3&&!st3.none&&typeof packScatter==='function'){
         var e3=st3.e, g3=st3.g, badPts=0, k;
         for(k=0;k<40;k++){
           e3.state='investigate'; e3.scattered=0;
           e3.tx=e3.x; e3.ty=e3.y;
           packScatter();
           if(!spotFree(g3.map,e3.tx,e3.ty,12)) badPts++;
         }
         if(badPts) bad.push('the scatter still chose somewhere a body cannot stand on '+badPts+' of 40 tries, and that state has only one way out');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var gz=__state(); if(gz){ if(gz.ents) gz.ents.length=0; if(gz.player) gz.player.iv=0; } }catch(_a){}
       try{ var g4=__state(); if(g4&&!g4.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.52',what:'a pillager whose whole reach is inside his own blast does not throw a charge at all, instead of throwing from a band one unit wide inside his own explosion; an ordinary pillager still throws from outside the blast and his charge still lands clear of him (2026-09-07 audit, my defect from v12.20)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
