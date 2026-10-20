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

if ($s.Contains("  {v:'32.01',what:")) { throw "check 32.01 is in the fixture already" }

SubRx @'
  {v:'32.00',what:
'@ @'
  {v:'32.01',what:'cw-cx-demoplain: a demo selected on the normal title starts its opening map automatically, demo F2 and F8 require Ctrl, career keeps plain F2 and F8, and the retired party launch functions are absent',
   run:function(){
     if(!DEV_LOCAL) return 'SKIP: local tools are disabled on this origin';
     var bad=[], g=null, skip0=MAPFIRST.skip, sn0=SNIP.dom, te0=CFG.textEdit, go0=JSON.stringify(P.gameOpts||null), tl=document.getElementById('title'), td=tl.style.display, tc=tl.className, oSolo=ARCADE.solo, tag, html, cr;
     function tap(code,ctrl){ var e={code:code,key:code,ctrlKey:!!ctrl,bubbles:true,cancelable:true}; window.dispatchEvent(new KeyboardEvent('keydown',e)); window.dispatchEvent(new KeyboardEvent('keyup',e)); }
     function ctrl(down){ window.dispatchEvent(new KeyboardEvent(down?'keydown':'keyup',{code:'ControlLeft',key:'Control',ctrlKey:down,bubbles:true,cancelable:true})); }
     function labels(chord){ html=keysFixedHtml(); if((html.indexOf('CTRL + F2')>=0)!==chord||(html.indexOf('CTRL + F8')>=0)!==chord) bad.push('key labels do not follow demo '+chord); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(ARCADE.on||NET.on) return 'fixture still has a demo or multiplayer link';
       if(typeof partyHostBoot!=='undefined'||typeof partyP2Boot!=='undefined'||typeof PARTY!=='undefined'||typeof partyOf!=='undefined'||typeof partyReload!=='undefined'||typeof partyNav!=='undefined'||typeof partyClearMarks!=='undefined'||typeof partyHostUp!=='undefined'||typeof partyPlainUrl!=='undefined'||typeof PARTY_EXIT!=='undefined') bad.push('the retired party launch mode still exists');
       if(document.documentElement.classList.contains('party')||document.documentElement.classList.contains('partyhide')) bad.push('a launch mode class still changes the title');
       SNIP.dom=0; if(SNIP.on) snipEnd('esc'); CFG.textEdit=0; P.gameOpts=P.gameOpts||{}; P.gameOpts.textEdit=0; keys={}; mouse.down=false;
       labels(false);
       tap('F8',true); if(SNIP.on) bad.push('career Ctrl+F8 started a snip');
       tap('F8'); if(!SNIP.on) bad.push('career F8 did not snip');
       if(SNIP.on) snipEnd('esc');
       tap('F2'); if(CFG.textEdit!==1) bad.push('career F2 did not edit');
       tap('F2'); if(CFG.textEdit!==0) bad.push('career F2 did not end editing');
       tl.style.display=''; tl.classList.add('on');
       document.getElementById('modearcade1').click();
       if(!ARCADE.on||!ARCADE.solo) return 'the normal title demo row did not enter the demo';
       labels(true);
       tap('F8'); if(SNIP.on) bad.push('plain F8 snips on the demo attract');
       if(SNIP.on) snipEnd('esc');
       tap('F2'); if(CFG.textEdit!==0) bad.push('plain F2 edits on the demo attract');
       if(CFG.textEdit===1) txKeyToggle();
       MAPFIRST.skip=0; if(ATT.on) attStop();
       if(!arcadeDeploy({seed:4242,mapIx:0,cond:'day'})) return 'could not start a demo run';
       g=__state(); if(!g||!g.arcade||!g.mapFirst||!g.paused) return 'the title demo did not begin on its frozen sector map';
       mapFirstStep(MAPFIRST.auto-0.01);
       if(!g.mapFirst) bad.push('demo map closed before the auto delay');
       mapFirstStep(0.02);
       if(g.mapFirst||g.mapOpen||g.paused||g.mapFirstWhy!=='auto') bad.push('plain title demo map did not start automatically at MAPFIRST.auto');
       if(g.mapFirst) mapFirstEnd('test');
       tap('F2'); tap('F8');
       if(CFG.textEdit!==0||SNIP.on||g.paused) bad.push('plain F2 or F8 froze the demo raid');
       if(SNIP.on) snipEnd('esc'); if(CFG.textEdit===1) txKeyToggle();
       cr=g.crouchTog; ctrl(true); tap('F2',true);
       if(CFG.textEdit!==1||!g.paused) bad.push('demo Ctrl+F2 did not edit and pause');
       if(g.crouchTog!==cr) bad.push('demo Ctrl+F2 changed crouch');
       tag=document.getElementById('txtag'); if(!tag||tag.textContent!=='edit words: on (ctrl f2)') bad.push('editor tag has the wrong demo key');
       ctrl(false); ctrl(true); tap('F2',true); ctrl(false);
       if(CFG.textEdit!==0||g.paused) bad.push('second demo Ctrl+F2 did not resume');
       cr=g.crouchTog; ctrl(true); tap('F8',true); ctrl(false);
       if(!SNIP.on||!g.paused) bad.push('demo Ctrl+F8 did not snip and pause');
       if(g.crouchTog!==cr) bad.push('demo Ctrl+F8 changed crouch');
       tap('F8'); if(!SNIP.on) bad.push('plain demo F8 ended a snip');
       if(SNIP.on) snipEnd('esc');
       if(g.paused) bad.push('ending the snip did not resume the demo');
       arcadeOpLeave(); g=null;
       if(ARCADE.on) bad.push('EXIT DEMO left the demo active');
       labels(false);
       tap('F8'); if(!SNIP.on) bad.push('F8 did not return after leaving demo');
       if(SNIP.on) snipEnd('esc');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(SNIP.on) snipEnd('esc'); }catch(_s){}
       try{ CFG.textEdit=0; keys={}; mouse.down=false; if(G) __endRaid('abandon'); }catch(_r){}
       try{ if(ARCADE.on) arcadeLeave(); }catch(_a){}
       MAPFIRST.skip=skip0; SNIP.dom=sn0; ARCADE.solo=oSolo;
       try{ var opts=JSON.parse(go0); if(opts===null) delete P.gameOpts; else P.gameOpts=opts; CFG.textEdit=te0; txTagSync(); keysFixedHtml(); }catch(_c){}
       __topClear(); tl.style.display=td; tl.className=tc;
     } }},
  {v:'32.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
