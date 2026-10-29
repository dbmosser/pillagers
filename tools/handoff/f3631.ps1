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

if ($s.Contains("  {v:'36.31',what:")) { throw "check 36.31 is in the fixture already" }

SubRx @'
  {v:'36.30',what:
'@ @'
  {v:'36.31',what:'cw-cx-timelord: live settings, key lists, pause and toggle or host callouts call the existing mode timelord; saved superhot names stay intact',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy or draw';
     var bad=[], g=null, oldSay=say, oldSay2=say2, oldHost=netShHost, proto=CanvasRenderingContext2D.prototype, oldText=proto.fillText, drawn=[], said=[], rows, row, i, off;
     function noOld(s,where){ if(/superhot/i.test(s||'')) bad.push(where+' still says superhot'); }
     function capture(s){ said.push(String(s)); }
     function last(){ return String(said[said.length-1]||'').toLowerCase(); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       rows=GAMEOPTS.filter(function(o){ return o.k==='superhot'; });
       if(rows.length!==1||rows[0].label!=='timelord mode') bad.push('the saved superhot row is not labelled timelord mode');
       if(rows.length===1&&(rows[0].opts[0].cfg.superhot!==0||rows[0].opts[1].cfg.superhot!==1)) bad.push('the saved dial changed');
       noOld(JSON.stringify(KEYS_LOCKED),'change keys');
       if(!KEYS_LOCKED.some(function(r){ return r[0]==='timelord mode'&&r[1]==='LEFT OF 1'; })) bad.push('change keys has no timelord mode row');
       noOld(JSON.stringify(LEGEND),'controls list');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; g.legendOn=2;
       proto.fillText=function(){ drawn.push(String(arguments[0])); return oldText.apply(this,arguments); };
       try{ __frame(0.016); }finally{ proto.fillText=oldText; }
       noOld(drawn.join(' '),'drawn controls list');
       if(!drawn.some(function(s){ return /^timelord on\/off$/i.test(s); })) bad.push('the drawn controls list has no timelord toggle');
       g.legendOn=1;
       openSettings();
       row=document.getElementById('go_superhot');
       if(!row||!/timelord mode/i.test(row.parentNode.textContent)) bad.push('the live settings row has no timelord mode label');
       noOld(document.getElementById('settingsmodal').textContent,'settings');
       document.getElementById('settingsmodal').classList.remove('on');
       say=capture; say2=capture;
       shSay(1); if(last()!=='timelord on') bad.push('on callout reads '+last());
       shSay(0); if(last()!=='timelord off') bad.push('off callout reads '+last());
       netShHost=function(){ return 0; };
       cycleGameOpt('superhot'); if(last()!=='timelord follows the host') bad.push('raid host callout reads '+last());
       off=g.over; g.over='test';
       try{ cycleGameOpt('superhot'); if(last()!=='timelord follows the host while you are in a party.') bad.push('hub host callout reads '+last()); }finally{ g.over=off; }
       noOld(said.join(' '),'callouts');
       for(i=0;i<3;i++) if(!MSGKEEP.some(function(r){ return r[0]==='e'&&r[1].test(['TIMELORD ON','TIMELORD OFF','TIMELORD FOLLOWS THE HOST'][i]); })) bad.push('timelord callout lost its existing message classification');
       say=oldSay; say2=oldSay2; netShHost=oldHost;
       if(typeof togglePauseBox==='function'){
         togglePauseBox(true);
         if(typeof pauseSpSync==='function') pauseSpSync(true);
         noOld((document.getElementById('pausebox')||{}).textContent,'pause');
       }
       return bad.length?bad.join('; '):null;
     }finally{
       say=oldSay; say2=oldSay2; netShHost=oldHost; proto.fillText=oldText;
       try{ if(typeof togglePauseBox==='function') togglePauseBox(false); }catch(_p){}
       try{ document.getElementById('settingsmodal').classList.remove('on'); }catch(_s){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'36.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
