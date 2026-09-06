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

# v11.83 CHECK, inserted before the v11.82 entry. The stim is used through the
# real belt path (key 3, useHot), then the real player update is stepped with
# Shift and a movement key held, twice from the same ring along the same
# clear line: once under the stim, once without it.
SubRx @'
  {v:'11.82',what:'the next bandage goes on while the prior one is still healing and a plate goes on while a bandage is being applied; the one-at-a-time refusal and its countdown are gone (his notes of 2026-09-06)',
'@ @'
  {v:'11.83',what:'a stim is ten seconds of unlimited stamina and a fifth more speed, used through the belt key: the bar stays full through a sprint and the same sprint covers 1.2x the ground (his spec of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof useHot!=='function'||typeof setHot!=='function'||typeof updatePlayer!=='function') return 'SKIP: no belt or player update in this build';
     var bad=[], k;
     function clearKeys(){ for(k in keys) delete keys[k]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, P=__P();
       if(!g.zones||!g.zones.length) return 'SKIP: no extraction ring to sprint from';
       var Z=g.zones[0];
       // A CLEAR LINE FROM THE RING, 220 units, in whichever direction has one.
       var dirs=[['KeyD',1,0],['KeyA',-1,0],['KeyS',0,1],['KeyW',0,-1]], dir=null;
       for(var d=0;d<dirs.length&&!dir;d++) if(losClear(Z.x,Z.y,Z.x+dirs[d][1]*220,Z.y+dirs[d][2]*220,g.map.segs)) dir=dirs[d];
       if(!dir) return 'SKIP: no clear line from the ring to sprint along';
       function sprintRun(){
         p.x=Z.x; p.y=Z.y; p.downed=false; p.roll=0; p.reloading=0; g.crouchTog=false; p.stamLock=0; p.stamRelease=0;
         clearKeys(); keys['ShiftLeft']=true; keys[dir[0]]=true;
         var x0=p.x,y0=p.y;
         for(var i=0;i<8;i++) updatePlayer(0.05);
         clearKeys();
         return Math.hypot(p.x-x0,p.y-y0);
       }
       // THE STIM, THROUGH THE REAL KEY.
       g.bag=['stim']; g.hotAssign={2:'stim'}; P.hotAssign={2:'stim'}; p.stam=20; p.stimT=0;   // the raid reads its own plan
       setHot(2); useHot();
       if(g.bag.indexOf('stim')>=0) bad.push('control: key 3 did not use the stim (bag '+g.bag.join(',')+')');
       if(!(p.stimT>=9.9)) bad.push('the stim did not start its ten seconds (stimT '+p.stimT+')');
       var dStim=sprintRun();
       if(p.stam<99.9) bad.push('the bar drained to '+p.stam.toFixed(1)+' during a sprint under the stim; it should be unlimited');
       if(!(p.stimT>0&&p.stimT<9.9)) bad.push('the stim clock did not run down during the sprint (stimT '+p.stimT+')');
       // THE SAME SPRINT WITHOUT IT.
       p.stimT=0; p.stam=100;
       var dPlain=sprintRun();
       if(!(dPlain>20)) bad.push('control: the plain sprint covered only '+dPlain.toFixed(0)+' units, so the line was not clear');
       if(p.stam>95) bad.push('control: the plain sprint drained nothing ('+p.stam.toFixed(1)+'), so sprint was not running');
       var ratio=dPlain>0?dStim/dPlain:0;
       if(!(ratio>1.12&&ratio<1.28)) bad.push('under the stim the sprint covered '+dStim.toFixed(0)+' against '+dPlain.toFixed(0)+' without, a ratio of '+ratio.toFixed(2)+' and not 1.2');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ clearKeys(); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.82',what:'the next bandage goes on while the prior one is still healing and a plate goes on while a bandage is being applied; the one-at-a-time refusal and its countdown are gone (his notes of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
