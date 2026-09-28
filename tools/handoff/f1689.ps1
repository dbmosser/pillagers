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

if ($s.Contains("  {v:'16.89',what:")) { throw "check 16.89 is in the fixture already" }

SubRx @'
  {v:'16.88',what:
'@ @'
  {v:'16.89',what:'in a same machine pair the keyboard always drives player 1: the player 2 window hands a key to the pair channel and does not act on it, and the player 1 window plays a handed key as its own; outside a pair nothing is handed',
   run:function(){
     if(typeof netSameOnMsg!=='function'||typeof netSamePost!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no same machine pair';
     var keep={same:NET.same,pair:NET.pair}, oPost=netSamePost, sent=[], bad=[], k0=keys, K=window.KeyboardEvent;
     function press(code,ty){ window.dispatchEvent(new K(ty||'keydown',{code:code,key:code.replace(/^Key/,'').toLowerCase(),bubbles:true,cancelable:true})); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSamePost=function(m){ sent.push(m); return true; };
       NET.same='p2'; NET.pair='zqxkeys'; keys={};
       press('KeyW'); press('KeyW','keyup'); press('KeyW');
       if(!sent.some(function(m){ return m&&m.t==='key'&&m.code==='KeyW'&&m.ty==='keydown'&&m.pair==='zqxkeys'; })) bad.push('the player 2 window did not hand a key to player 1 ('+JSON.stringify(sent)+')');
       if(keys['KeyW']) bad.push('the player 2 window acted on a key meant for player 1');
       press('KeyW','keyup');
       NET.same='host'; keys={};
       var r=netSameOnMsg({t:'key',pair:'zqxkeys',ty:'keydown',code:'KeyW',key:'w'});
       if(r!=='key'||!keys['KeyW']) bad.push('the player 1 window did not play a handed key as its own ('+r+')');
       netSameOnMsg({t:'key',pair:'zqxkeys',ty:'keyup',code:'KeyW',key:'w'});
       if(keys['KeyW']) bad.push('the player 1 window did not let go of a handed key');
       NET.same=''; sent.length=0; keys={};
       press('KeyD'); press('KeyD','keyup');
       if(sent.length) bad.push('outside a pair a key was handed on');
     } finally {
       netSamePost=oPost; NET.same=keep.same; NET.pair=keep.pair; keys=k0||{};
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
