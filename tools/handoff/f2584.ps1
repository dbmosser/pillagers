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

if ($s.Contains("  {v:'25.84',what:")) { throw "check 25.84 is in the fixture already" }

SubRx @'
  {v:'25.83',what:
'@ @'
  {v:'25.84',what:'his order: SETTINGS opens from the DEMO pause box and shows the Settings screen, a change applies in the DEMO and is put back when the demo is left, and CLOSE and ESC return to the pause box',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||typeof togglePauseBox!=='function'||typeof escCloseTopModal!=='function') return 'SKIP: no arcade here';
     var bad=[], g, sb, fx0, fx1, go0, rs=say, ownS=false;
     function el(id){ return document.getElementById(id); }
     function shown(e){ try{ return !!e&&e.style.display!=='none'&&getComputedStyle(e).display!=='none'; }catch(_s){ return false; } }
     function boxOn(){ var x=el('pause'+'box'); return !!x&&x.classList.contains('on'); }
     function setOn(){ var x=el('settingsmodal'); return !!x&&x.classList.contains('on'); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       say=function(){}; ownS=true;
       fx0=CFG.fxLevel; go0=P.gameOpts?P.gameOpts.fxLevel:undefined;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!g||!g.arcade) return 'SKIP: no arcade raid';
       togglePauseBox(true);
       if(!boxOn()) return 'SKIP: the arcade pause box does not open';
       sb=el('pausesetbtn');
       if(!shown(sb)) bad.push('the DEMO pause box has no SETTINGS button');
       else {
         sb.click();
         if(!setOn()) bad.push('SETTINGS in the DEMO pause box did not show the Settings screen');
         else {
           if(!el('go_fxLevel')) bad.push('the DEMO Settings screen has no Effects row');
           else {
             fx1=CFG.fxLevel; el('go_fxLevel').click();
             if(CFG.fxLevel===fx1) bad.push('a Settings change in the DEMO did not apply (Effects stayed '+fx1+')');
           }
           el('closesettings').click();
           if(setOn()) bad.push('CLOSE left the Settings screen up');
           if(!boxOn()||!ARCADE.on||__state()!==g) bad.push('CLOSE did not return to the DEMO pause box');
           sb.click();
           if(!setOn()) bad.push('SETTINGS did not open a second time');
           escCloseTopModal();
           if(setOn()) bad.push('ESC left the Settings screen up');
           if(!boxOn()||!ARCADE.on||__state()!==g) bad.push('ESC did not return to the DEMO pause box');
         }
       }
       togglePauseBox(false);
       arcadeLeave();
       if(CFG.fxLevel!==fx0) bad.push('the DEMO Settings change was not put back when the demo was left (Effects '+CFG.fxLevel+', was '+fx0+')');
       if((P.gameOpts?P.gameOpts.fxLevel:undefined)!==go0) bad.push('the DEMO Settings change reached the profile (gameOpts.fxLevel '+(P.gameOpts?P.gameOpts.fxLevel:undefined)+', was '+go0+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownS) say=rs;
       keys={};
       try{ var sm=el('settingsmodal'); if(sm) sm.classList.remove('on'); }catch(_m){}
       try{ togglePauseBox(false); }catch(_t){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; }catch(_x){}
       try{ CFG.fxLevel=fx0; }catch(_f){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
