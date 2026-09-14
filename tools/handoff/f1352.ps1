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
  {v:'13.51',what:
'@ @'
  {v:'13.52',what:'with a controller connected the text names the button that does it: the empty cell line names LB or RB, the pad key lists say VIEW and MENU, D-DOWN reads revive and not medical, and the keyboard wording is unchanged (key prompt audit 2026-09-14)',
   run:function(){
     if(typeof padOn!=='function'||typeof gunKeyLine!=='function'||typeof LEGEND_MINI_PAD==='undefined'||typeof LEGEND_PAD==='undefined'||typeof PADLABEL==='undefined') return 'SKIP: this build has no pad text to read';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], keepOn=padOn;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       // CONTROL FIRST: the keyboard wording stands.
       padOn=function(){ return false; };
       if(String(gunKeyLine()).indexOf('Press ')!==0) bad.push('control: on the keyboard the empty cell line no longer says Press (it says '+gunKeyLine()+')');
       padOn=function(){ return true; };
       var gl=String(gunKeyLine());
       if(gl.indexOf('LB')<0||gl.indexOf('Press ')>=0) bad.push('on a controller the empty cell line says '+gl+', naming a number key no pad button reaches');
       if(PADLABEL.KeyI!=='VIEW') bad.push('on a controller the backpack label is '+PADLABEL.KeyI+', while the button is View');
       if(PADLABEL.KeyP!=='MENU') bad.push('on a controller the pause label is '+PADLABEL.KeyP+', while the button is Menu');
       var mini=JSON.stringify(LEGEND_MINI_PAD), full=JSON.stringify(LEGEND_PAD);
       if(mini.indexOf('"BACK"')>=0||mini.indexOf('"START"')>=0) bad.push('the short pad key list still names BACK or START while the full list names VIEW and MENU');
       if(mini.indexOf('medical')>=0||full.indexOf('use medical')>=0) bad.push('a pad key list still says D-DOWN uses medical, which it has not done since v11.27');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ padOn=keepOn; }catch(_o){}
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
