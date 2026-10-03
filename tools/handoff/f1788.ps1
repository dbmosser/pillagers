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

if ($s.Contains("  {v:'17.88',what:")) { throw "check 17.88 is in the fixture already" }

SubRx @'
  {v:'17.87',what:
'@ @'
  {v:'17.88',what:'in a same machine pair a window pauses only when the pad it plays is unplugged; the other window pad coming out does nothing to it',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof togglePauseBox!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no raid, pause box or party in this fixture';
     var bad=[], lines=[], oSay=say, st0=state, same0=NET.same, ix0=NET.padIx, ev;
     function drop(ix){ var e=new Event('gamepaddisconnected'); try{ Object.defineProperty(e,'gamepad',{value:{index:ix}}); }catch(_d){} window.dispatchEvent(e); }
     try{
       say=function(t){ lines.push(String(t)); };
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       state='raid'; try{ togglePauseBox(false); }catch(_p0){}
       NET.same='host'; NET.padIx=0;
       drop(1);
       if(pauseOpen) bad.push('the other window pad coming out paused this window');
       if(lines.some(function(t){ return /Controller disconnected/.test(t); })) bad.push('the other window pad coming out said '+JSON.stringify(lines));
       drop(0);
       if(!pauseOpen) bad.push('this window own pad coming out did not pause');
       if(!lines.some(function(t){ return /Controller disconnected/.test(t); })) bad.push('this window own pad coming out said nothing');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say=oSay; state=st0; NET.same=same0; NET.padIx=ix0; try{ togglePauseBox(false); }catch(_p2){} try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
