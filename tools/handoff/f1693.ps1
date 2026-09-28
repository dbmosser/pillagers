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

if ($s.Contains("  {v:'16.93',what:")) { throw "check 16.93 is in the fixture already" }

SubRx @'
  {v:'16.92',what:
'@ @'
  {v:'16.93',what:'with the pause box open in the player 2 window, ESC or TAB shuts that box and is spent there: it is not handed to the player 1 window, where it paused player 1 or shut his map',
   run:function(){
     if(typeof netKeyFwd!=='function'||typeof togglePauseBox!=='function'||typeof netSamePost!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no same machine pair';
     var pb=document.getElementById('pausebox');
     if(!pb) return 'SKIP: this build has no pause box';
     var keep={same:NET.same,pair:NET.pair}, oPost=netSamePost, sent=[], bad=[], k0=keys, md0=mouse.down, K=window.KeyboardEvent, codes=['Escape','Tab'], i, c;
     function press(code,ty){ document.body.dispatchEvent(new K(ty||'keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function handed(code){ return sent.filter(function(m){ return m&&m.t==='key'&&m.ty==='keydown'&&m.code===code; }).length; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSamePost=function(m){ sent.push(m); return true; };
       NET.same='p2'; NET.pair='zqxesc'; keys={};
       for(i=0;i<codes.length;i++){
         c=codes[i]; sent.length=0;
         togglePauseBox(true);
         if(!pb.classList.contains('on')) return 'SKIP: staging: the pause box did not open in the player 2 window';
         press(c); press(c,'keyup');
         if(pb.classList.contains('on')) bad.push('control: '+c+' did not shut the pause box in the player 2 window');
         if(handed(c)) bad.push(c+' that shut the pause box in the player 2 window was also handed to player 1, where it pauses him or shuts his map');
       }
       sent.length=0; press('KeyW'); press('KeyW','keyup');
       if(!handed('KeyW')) bad.push('control: with the box shut the player 2 window no longer hands keys to player 1');
     } finally {
       netSamePost=oPost; NET.same=keep.same; NET.pair=keep.pair; keys=k0||{};
       try{ togglePauseBox(false); }catch(e){}
       mouse.down=md0;
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
