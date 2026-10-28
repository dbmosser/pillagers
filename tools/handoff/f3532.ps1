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

if ($s.Contains("  {v:'35.32',what:")) { throw "check 35.32 is in the fixture already" }

SubRx @'
  {v:'35.31',what:
'@ @'
  {v:'35.32',what:'cw-shoff (his order of 10-27, superhot mode should be off by default): every sitting starts with superhot off: a save with superhot on (his saves since 10-25) loads with it off, the settings row still turns it on for the sitting, turned on and saved the next load is off again, and the 2 player demo starts with it off for both players and leaving it puts the sitting choice back',
   run:function(){
     if(typeof applyLoadedProfile!=='function'||typeof cycleGameOpt!=='function'||typeof gameOptIx!=='function'||typeof applyGameOpts!=='function'||typeof arcadeSandboxIn!=='function'||typeof arcadeSandboxOut!=='function') return 'SKIP: no profile loader, superhot row or demo sandbox in this build';
     if(typeof netShHost==='function'&&netShHost()!==null) return 'SKIP: a linked window, where the host word decides';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, bad=[], i;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     // The bytes saveProfile writes (P.cfg is the live dials), with the saved Superhot word set when one is given.
     function saveOf(on){ var s=JSON.parse(JSON.stringify(P)); s.gameOpts=s.gameOpts||{}; if(on!==undefined) s.gameOpts.superhot=on; s.cfg=JSON.parse(JSON.stringify(CFG)); s.cfgv=18; return JSON.stringify(s); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       // ONE: his save as his exports show it since 10-25, Superhot on in the row and in the dials, loads with it off
       CFG.superhot=1;
       applyLoadedProfile({value:saveOf(1)});
       need(CFG.superhot===0,'ONE: a save with superhot on loaded with the dial at '+CFG.superhot);
       need(gameOptIx('superhot')===0,'ONE: a save with superhot on loaded with the settings row at '+gameOptIx('superhot'));
       // TWO (control): the settings row still turns it on in the same sitting
       cycleGameOpt('superhot');
       need(CFG.superhot===1&&gameOptIx('superhot')===1,'TWO: the settings row did not turn superhot on for the sitting (dial '+CFG.superhot+', row '+gameOptIx('superhot')+')');
       // THREE: turned on in this sitting and saved as the game saves, the next load is off again
       applyLoadedProfile({value:saveOf()});
       need(CFG.superhot===0,'THREE: turned on in settings, the next load had the dial at '+CFG.superhot);
       need(gameOptIx('superhot')===0,'THREE: turned on in settings, the next load had the settings row at '+gameOptIx('superhot'));
       // FOUR: the 2 player demo starts with it off for either player, also when the sitting turned it on, and leaving puts the sitting choice back
       for(i=0;i<2;i++){
         P.gameOpts=P.gameOpts||{}; P.gameOpts.superhot=1; CFG.superhot=1;
         if(!arcadeSandboxIn(i?'p2':'host')) throw new Error('staging: the demo sandbox did not open');
         need(CFG.superhot===0,'FOUR: the demo started with superhot at '+CFG.superhot+' for '+(i?'player 2':'player 1'));
         applyGameOpts();
         need(CFG.superhot===0,'FOUR: in the demo the settings pass put the sitting choice back ('+CFG.superhot+') for '+(i?'player 2':'player 1'));
         arcadeSandboxOut();
         need(CFG.superhot===1&&P.gameOpts.superhot===1,'FOUR: leaving the demo did not put the sitting choice back (dial '+CFG.superhot+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(ARCADE.on) arcadeSandboxOut(); }catch(_a){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ KEYS.inv=null; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
