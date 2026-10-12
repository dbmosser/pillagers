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

if ($s.Contains("  {v:'23.62',what:")) { throw "check 23.62 is in the fixture already" }

SubRx @'
  {v:'23.61',what:
'@ @'
  {v:'23.62',what:'his order: the bigger map (THE COLD MILE) is frozen: it is not offered, the sector page shows only COLD STORAGE with no size tag, the arcade falls back to COLD STORAGE, and the mile still builds 374 and 593 for the tests',
   run:function(){
     if(typeof mapOffered!=='function'||typeof FIXED_MAPS==='undefined'||FIXED_MAPS.length<2||typeof offeredCount!=='function'||typeof renderSector!=='function') return 'SKIP: no sector table here';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy or restore the profile';
     var bad=[], big=0, best=0, i, A, host=document.getElementById('sectorlist'), snap=null, g;
     for(i=0;i<FIXED_MAPS.length;i++){ A=FIXED_MAPS[i].w*FIXED_MAPS[i].h; if(A>best){ best=A; big=i; } }
     if(big===0) return 'SKIP: the first map is the biggest here';
     try{
       __topClear(); __runPrep(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       if(mapOffered(FIXED_MAPS[big])) bad.push('the bigger map '+FIXED_MAPS[big].name+' is still offered');
       if(!mapOffered(FIXED_MAPS[0])) bad.push('COLD STORAGE is not offered');
       if(offeredCount()!==1) bad.push(offeredCount()+' sectors are offered, not 1');
       if(typeof sizeTag==='function'&&sizeTag(0)!=='') bad.push('the lone sector card still reads '+sizeTag(0));
       if(host){
         P.mapIx=0; renderSector();
         if(host.querySelector('.sectorpick[data-map="'+big+'"]')) bad.push('the sector page still shows a card for '+FIXED_MAPS[big].name);
         if(!host.querySelector('.sectorpick[data-map="0"]')) bad.push('the sector page lost the COLD STORAGE card');
       }
       if(typeof arcadeEnter==='function'&&typeof arcadeLeave==='function'&&typeof ARCADE==='object'&&!ARCADE.on){
         if(__state()&&!__state().over) __endRaid('abandon');
         P.mapIx=big;
         if(arcadeEnter('host')&&ARCADE.on){ if(ARCADE.mapIx!==0) bad.push('with his last sector on the mile the arcade took sector '+ARCADE.mapIx+', not COLD STORAGE'); }
         arcadeLeave();
       }
       __runPrep(); __resetCfg(); __pinDefaults(1);
       __deploy({kit:[],safe:null,mapIx:big,seed:4242});
       g=__state();
       if(!g||!g.ents) bad.push('the frozen mile no longer builds when asked for by number');
       else if(g.ents.length!==374||(g.containers||[]).length!==593) bad.push('the frozen mile at seed 4242 builds '+g.ents.length+' and '+(g.containers||[]).length+', not 374 and 593');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; } }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __resetCfg(); __pinDefaults(0); renderSector(); }catch(_s){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
