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

if ($s.Contains("  {v:'32.74',what:")) { throw "check 32.74 is in the fixture already" }

SubRx @'
  {v:'32.73',what:
'@ @'
  {v:'32.74',what:'polling a lost pad immediately clears its pause glyphs and held input; same-slot A still resumes and is spent',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof padLostPoll!=='function'||typeof pollPad!=='function'||typeof indevSet!=='function') return 'SKIP: no polling loss or prompt tracker';
     if(NET.same||NET.on) return 'SKIP: this check stages a solo local pad';
     var had=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), oldGet=navigator.getGamepads, savedPad={}, savedInput=JSON.parse(JSON.stringify(INDEV)), k, g=null, list=[], heading=document.querySelector('#pausebox h3'), oldHeading=heading&&heading.textContent;
     var buttons=[], i; for(i=0;i<17;i++) buttons.push({pressed:false,value:0,touched:false});
     var gp={connected:true,id:'Xbox Controller',index:0,mapping:'standard',timestamp:1,buttons:buttons,axes:[0,0,0,0]};
     for(k in PAD){ savedPad[k]=PAD[k]; if(Array.isArray(PAD[k])) savedPad[k]=PAD[k].slice(); }
     if(PAD.held) savedPad.held=Object.assign({},PAD.held);
     function text(){ var e=document.getElementById('pausekeys'); return String(e&&e.textContent||'').toUpperCase(); }
     function poll(){ gp.timestamp++; pollPad(); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       navigator.getGamepads=function(){ return list; };
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       keys={}; mouse.down=false; PAD.prev=[]; PAD.held={}; PAD.on=false;
       INDEV.legacy=false; INDEV.pb=[]; INDEV.pa=[]; indevSet('kb'); padBodyCls();
       poll(); togglePauseBox(true);
       if(text().indexOf('LMB')<0) return 'control: pause did not start with keyboard controls';
       list=[gp]; gp.axes[2]=0.8; poll(); gp.axes[2]=0;
       if(!padOn()||!document.body.classList.contains('padon')||text().indexOf('STICK')<0) return 'control: active pad did not switch the open pause controls';
       list=[]; poll();
       if(!PAD.lost||!pauseOpen||!g.paused) return 'pad loss no longer pauses the local raid';
       if(PAD.on||padOn()||document.body.classList.contains('padon')||text().indexOf('LMB')<0||text().indexOf('STICK')>=0) return 'a lost pad left the open pause controls on pad glyphs';
       if(String(heading.textContent).toLowerCase()!=='pad lost') return 'the loss title was replaced';
       if(mouse.down||PAD.mx||PAD.my||Object.keys(PAD.held||{}).some(function(c){return PAD.held[c]&&keys[c];})) return 'lost pad input is still held';
       poll();
       if(document.body.classList.contains('padon')||text().indexOf('LMB')<0) return 'the next loss poll restored stale pad glyphs';
       list=[gp]; poll();
       if(!PAD.lost||!pauseOpen||String(heading.textContent).toLowerCase()!=='press a') return 'same-slot reconnect did not keep the press a confirmation';
       buttons[0].pressed=true; buttons[0].value=1; poll();
       if(PAD.lost||pauseOpen||g.paused||!PAD.on) return 'same-slot A no longer resumes';
       if(!PAD.prev[0]||!PAD.mSpent||!PAD.mSpent[0]) return 'resume A was not spent';
       return null;
     } finally {
       keys={}; mouse.down=false;
       try{ if(pauseOpen) togglePauseBox(false); if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       if(had) navigator.getGamepads=oldGet; else delete navigator.getGamepads;
       for(k in PAD) if(!Object.prototype.hasOwnProperty.call(savedPad,k)) delete PAD[k];
       for(k in savedPad) PAD[k]=savedPad[k];
       for(k in INDEV) if(!Object.prototype.hasOwnProperty.call(savedInput,k)) delete INDEV[k];
       for(k in savedInput) INDEV[k]=savedInput[k];
       try{ delete PAD._bodyOn; padBodyCls(); if(heading) heading.textContent=oldHeading; }catch(_p){}
       __topClear(); __cleanProfile();
     } }},
  {v:'32.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
