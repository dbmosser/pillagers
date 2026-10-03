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

if ($s.Contains("  {v:'18.02',what:")) { throw "check 18.02 is in the fixture already" }

SubRx @'
  {v:'18.01',what:
'@ @'
  {v:'18.02',what:'an ESC handed over from the player 2 window pauses player 1: with a raid up and the pause box down, the handed key leaves the box up, and a second handed ESC closes it again, the way a key pressed in this window does',
   run:function(){
     if(typeof netSameOnMsg!=='function'||typeof togglePauseBox!=='function') return 'SKIP: no pair channel in this fixture';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], same0=NET.same, pair0=NET.pair, box=document.getElementById('pausebox'), r;
     if(!box) return 'SKIP: no pause box';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       keys={}; NET.same='host'; NET.pair='zqxesc';
       if(box.classList.contains('on')) togglePauseBox(false);
       r=netSameOnMsg({t:'key',pair:'zqxesc',ty:'keydown',code:'Escape',key:'Escape',rep:false,sh:false,ct:false});
       netSameOnMsg({t:'key',pair:'zqxesc',ty:'keyup',code:'Escape',key:'Escape',rep:false,sh:false,ct:false});
       if(r!=='key') bad.push('the handed key was answered '+r);
       if(!box.classList.contains('on')) bad.push('a handed ESC left player 1 unpaused');
       netSameOnMsg({t:'key',pair:'zqxesc',ty:'keydown',code:'Escape',key:'Escape',rep:false,sh:false,ct:false});
       netSameOnMsg({t:'key',pair:'zqxesc',ty:'keyup',code:'Escape',key:'Escape',rep:false,sh:false,ct:false});
       if(box.classList.contains('on')) bad.push('a second handed ESC did not close the pause box');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       NET.same=same0; NET.pair=pair0; keys={};
       try{ if(box.classList.contains('on')) togglePauseBox(false); }catch(_pb){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'18.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
