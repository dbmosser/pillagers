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
  {v:'15.09',what:
'@ @'
  {v:'15.10',what:'a note typed in the pause box survives an instant quit: typed right after ascending and abandoned before moving, the note is kept under the floor notes, filed after the unchanged run count, and the Undercroft says it was noted (quit audit finding 8)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof elapsed!=='function'||typeof say2!=='function') return 'SKIP: this build has no pause box';
     var cb=document.getElementById('confirmabandon'), ab=document.getElementById('abandonbtn'), pn=document.getElementById('pausenote');
     if(!cb||!ab||!pn||typeof cb.onclick!=='function') return 'SKIP: this build has no abandon confirm or note box in the page';
     var bad=[], g=null, snap=null, _s2=say2, said=[];
     var needle='QZX7'+'-spawn';
     var has=function(a){ return (a||[]).filter(function(x){ return String(x&&x.txt).indexOf(needle)>=0; }); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       if(CFG.raidSec>0) g.timeLeft=(g.raidLen===undefined?CFG.raidSec:g.raidLen); else g.t=0;
       var T0=g.tel||{}, n0=(__P().log||[]).length, runs0=__P().runs||0;
       // CONTROL: before the click this raid is an instant quit: no time on the clock, no steps, nothing looted, nothing fired.
       if(!(elapsed()<1.5&&(T0.distance||0)<8&&T0.containers===0&&T0.shots===0)) return 'SKIP: this raid is not an instant quit here (elapsed '+elapsed()+', distance '+T0.distance+')';
       if(has(__P().floorNotes).length) return 'SKIP: the floor notes already held the test note';
       togglePauseBox(true);
       pn.value=needle+' felt unfair';
       say2=function(t){ said.push(String(t)); };
       cb.onclick.call(cb);
       say2=_s2;
       // CONTROL: the close banked the note into the raid, the run ended as an abandon, and it was thrown away as never having happened.
       if(!has(g.tel&&g.tel.notes).length) return 'SKIP: closing the box did not bank the note into the raid here';
       if(g.over!=='abandon') return 'SKIP: the confirm did not abandon the run here';
       if(__state()!==null||(__P().log||[]).length!==n0) return 'SKIP: the abandon was not an instant quit here, so the run record keeps the note';
       var fn=__P().floorNotes||[], kept=has(fn);
       if(!kept.length) bad.push('a note typed in the pause box right after ascending was thrown away by the instant quit: it is in no run record and not under FLOOR NOTES ('+fn.length+' floor notes)');
       else if(kept[0].run!==runs0) bad.push('the kept note is filed after run #'+kept[0].run+' where the quit left the run count at '+runs0);
       var line=said.join(' | ');
       if(line.indexOf('Not'+'ed.')<0) bad.push('the instant quit said nothing about the note typed in the box (the Undercroft said: '+(line.slice(0,80)||'nothing')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say2=_s2;
       try{ pn.value=''; cb.style.display='none'; ab.textContent='Abandon run'; }catch(_b){}
       try{ if(g&&!g.over){ togglePauseBox(false); __endRaid('abandon'); } }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
