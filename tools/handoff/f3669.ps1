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

if ($s.Contains("  {v:'36.69',what:")) { throw "check 36.69 is in the fixture already" }

SubRx @'
  {v:'36.68',what:
'@ @'
  {v:'36.69',what:'timelord shortcut needs a continuous 0.6 second hold, ignores demo keys, preserves Shift tuning and host authority in both roles',
   run:function(){
     var bad=[], g, oldNow=statusNow, clock=100, oldArc=ARCADE.on, oldHost=NET.shHost, oldRole=NET.role, oldOn=NET.on, oldTune=toggleTune, tuneHits=0, role, i, cfg0=CFG.superhot;
     function key(type,repeat,shift){ window.dispatchEvent(new KeyboardEvent(type,{code:'Backquote',key:'`',repeat:!!repeat,shiftKey:!!shift,bubbles:true,cancelable:true})); }
     function step(dt){ clock+=dt; __loop(performance.now()); }
     function setOff(){ P.gameOpts=P.gameOpts||{}; P.gameOpts.superhot=0; CFG.superhot=0; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'staging: no live raid';
       if(document.activeElement&&document.activeElement.blur) document.activeElement.blur();
       g.paused=false; g.bagOpen=false; g.mapOpen=false; g.mapFirst=0; keys={}; mouse.down=false; ARCADE.on=0; g.arcade=0;
       statusNow=function(){ return clock; };
       // A real tap must fail on the old one-keydown shortcut, before any new helper is required.
       NET.on=false; setOff(); key('keydown'); key('keyup'); step(0.7);
       if(CFG.superhot!==0||P.gameOpts.superhot!==0) return 'a tap changed the live or saved timelord dial';
       if(typeof shKeyProgress!=='function') return 'missing hold progress';
       for(role=0;role<2;role++){
         NET.role=role?'join':'host'; NET.on=false; NET.shHost=null; setOff();
         key('keydown'); step(0.3);
         if(CFG.superhot!==0||Math.abs(shKeyProgress()-0.5)>0.02) bad.push('role '+role+': half hold changed dial or has no half fill');
         __frame(0);
         if(!ANSBOX.on||!/^timelord off$/i.test(ANSBOX.t)) bad.push('role '+role+': hold status not drawn');
         step(0.29); if(CFG.superhot!==0) bad.push('role '+role+': switched before 0.6 s');
         step(0.11); if(CFG.superhot!==1||P.gameOpts.superhot!==1) bad.push('role '+role+': 0.7 s hold did not switch and save');
         key('keydown',true); step(1); if(CFG.superhot!==1) bad.push('role '+role+': held key switched twice'); key('keyup');
         key('keydown'); step(0.7); key('keyup'); if(CFG.superhot!==0) bad.push('role '+role+': second hold did not switch off');
         key('keydown'); step(0.3); key('keyup'); key('keydown'); step(0.3); key('keyup'); step(0.7);
         if(CFG.superhot!==0) bad.push('role '+role+': separate short holds accumulated');
         key('keydown'); step(0.3); releaseAllKeys(true); step(0.7); key('keyup'); if(CFG.superhot!==0) bad.push('role '+role+': focus release completed a hold');
         for(i=0;i<2;i++){
           ARCADE.on=i?0:1; g.arcade=i?1:0;
           key('keydown'); clock+=0.7; shKeyTick(); key('keyup'); if(CFG.superhot!==0||P.gameOpts.superhot!==0) bad.push('role '+role+': demo hold changed timelord');
         }
         ARCADE.on=0; g.arcade=0;
       }
       NET.on=true; NET.role='join'; NET.shHost=0; setOff(); key('keydown'); step(0.7); key('keyup');
       if(CFG.superhot!==0||P.gameOpts.superhot!==0) bad.push('joining window overrode host');
       NET.on=false; toggleTune=function(){ tuneHits++; };
       ARCADE.on=1; key('keydown',false,true); step(0.7); key('keyup'); ARCADE.on=0;
       key('keydown',false,true); step(0.7); key('keyup');
       if(tuneHits!==2||CFG.superhot!==0) bad.push('Shift tuning changed in career or demo');
       if(!KEYS_LOCKED.some(function(r){ return r[0]==='timelord mode'&&/hold/i.test(r[1]); })) bad.push('key list omits hold');
       if(!LEGEND.some(function(s){ return s[1].some(function(r){ return /timelord on\/off/i.test(r[1])&&/hold/i.test(r[0]); }); })) bad.push('controls omit hold');
       return bad.length?bad.join('; '):null;
     }finally{
       key('keyup'); statusNow=oldNow; toggleTune=oldTune; ARCADE.on=oldArc; NET.shHost=oldHost; NET.role=oldRole; NET.on=oldOn;
       try{ __endRaid('abandon'); }catch(_e){} __topClear(); __resetCfg(); __cleanProfile(); CFG.superhot=cfg0;
     }
   }},
  {v:'36.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
