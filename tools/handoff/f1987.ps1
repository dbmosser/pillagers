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

if ($s.Contains("  {v:'19.87',what:")) { throw "check 19.87 is in the fixture already" }

SubRx @'
  {v:'19.86',what:
'@ @'
  {v:'19.87',what:'an open pause box follows the pad: plugging a controller in while the box is open turns its key line into the pad buttons, and pulling it out turns it back',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof pollPad!=='function'||typeof togglePauseBox!=='function') return 'SKIP: no pad poll or pause box here';
     var bad=[], g, el=document.getElementById('pausekeys'), had=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), og=navigator.getGamepads, on0=PAD.on, pad, t1, t2;
     if(!el) return 'SKIP: no pause key line';
     pad={id:'Xbox Wireless Controller (STANDARD GAMEPAD)',index:0,connected:true,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:Array.apply(null,Array(17)).map(function(){ return {pressed:false,touched:false,value:0}; })};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       navigator.getGamepads=function(){ return [null,null,null,null]; }; pollPad(); PAD.on=false; try{ padBodyCls(); }catch(_b){}
       togglePauseBox(true);
       if(String(el.textContent).indexOf('LMB')<0) return 'SKIP: the box did not open on the keyboard line';
       navigator.getGamepads=function(){ pad.timestamp++; return [pad,null,null,null]; }; pollPad();
       t1=String(el.textContent);
       if(t1.indexOf('LMB')>=0||t1.indexOf('STICK')<0) bad.push('a pad plugged in with the box open left the keyboard line up');
       navigator.getGamepads=function(){ return [null,null,null,null]; }; pollPad();
       t2=String(el.textContent);
       if(t2.indexOf('LMB')<0) bad.push('a pad pulled out with the box open left the pad line up');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(had) navigator.getGamepads=og; else delete navigator.getGamepads; try{ pollPad(); }catch(_p){} PAD.on=on0; try{ padBodyCls(); }catch(_b2){} try{ if(pauseOpen) togglePauseBox(false); }catch(_t){} try{ keysLegendApply(); }catch(_k){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
