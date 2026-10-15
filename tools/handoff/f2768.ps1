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

if ($s.Contains("  {v:'27.68',what:")) { throw "check 27.68 is in the fixture already" }

SubRx @'
  {v:'27.67',what:
'@ @'
  {v:'27.68',what:'cloud-menus-pad-b-closes-settings: controller B in Settings shuts the window and leaves MINIMAP ZOOM alone while that row reads CLOSE',
   run:function(){
     if(typeof pollPad!=='function'||typeof PAD==='undefined'||typeof openSettings!=='function'||!window.__opts) return 'SKIP: this fixture cannot drive Settings with a pad';
     var bad=[], Pf=__P(), go0=JSON.stringify(Pf.gameOpts||{}), on0=PAD.on, had=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), og=navigator.getGamepads, md=document.getElementById('settingsmodal'), zb, span0, pad0={}, pk, ru0=(typeof RUMBLE!=='undefined'&&RUMBLE)?RUMBLE.usedAt:undefined;
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) pad0[pk]=PAD[pk];
     if(!md) return 'SKIP: no Settings window';
     function mk(down){ var bt=[], q, d; for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bt.push({pressed:d,touched:d,value:d?1:0}); } return {connected:true,id:'Xbox Wireless Controller (STANDARD GAMEPAD)',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bt}; }
     function poll(down){ var gp=mk(down); navigator.getGamepads=function(){ return [gp,null,null,null]; }; pollPad(); }
     try{
       __topClear(); __runPrep(); __resetCfg();
       Pf.gameOpts={mmZoom:0}; __opts.apply();
       openSettings();
       if(!md.classList.contains('on')) return 'SKIP: Settings did not open';
       zb=document.getElementById('go_mmZoom');
       if(!zb||String(zb.textContent).trim()!=='CLOSE') return 'SKIP: the MINIMAP ZOOM row does not read CLOSE here';
       span0=CFG.mmSpan;
       poll([]); poll([]); poll([1]); poll([]);
       if(md.classList.contains('on')) bad.push('B on the controller left Settings open');
       if(Pf.gameOpts.mmZoom!==0) bad.push('B on the controller changed MINIMAP ZOOM to option '+Pf.gameOpts.mmZoom);
       if(CFG.mmSpan!==span0) bad.push('B on the controller changed the minimap span from '+span0+' to '+CFG.mmSpan);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ navigator.getGamepads=function(){ return [null,null,null,null]; }; pollPad(); }catch(_p0){}
       if(had) navigator.getGamepads=og; else { try{ delete navigator.getGamepads; }catch(_d){} }
       for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(pad0,pk)) delete PAD[pk];
       for(pk in pad0) PAD[pk]=pad0[pk];
       if(typeof RUMBLE!=='undefined'&&RUMBLE) RUMBLE.usedAt=ru0;
       PAD.on=on0; try{ padBodyCls(); }catch(_b){} try{ padSetFocus(null); }catch(_f){} PAD.focus=null;
       try{ md.classList.remove('on'); }catch(_m){}
       Pf.gameOpts=JSON.parse(go0); try{ __resetCfg(); __opts.apply(); }catch(_o){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
