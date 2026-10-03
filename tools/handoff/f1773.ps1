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

if ($s.Contains("  {v:'17.73',what:")) { throw "check 17.73 is in the fixture already" }

SubRx @'
  {v:'17.72',what:
'@ @'
  {v:'17.73',what:'a controller unplugged in a raid opens the pause box and says so; on the Undercroft floor it does not pause',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof togglePauseBox!=='function') return 'SKIP: no raid or pause box in this fixture';
     var bad=[], lines=[], oSay=say, st0=state, ev;
     try{
       say=function(t){ lines.push(String(t)); };
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       state='raid'; try{ togglePauseBox(false); }catch(_p0){}
       ev=new Event('gamepaddisconnected'); window.dispatchEvent(ev);
       if(!pauseOpen) bad.push('a controller unplugged in a raid did not pause');
       if(!lines.some(function(t){ return /Controller disconnected/.test(t); })) bad.push('nothing said the controller was unplugged ('+JSON.stringify(lines)+')');
       try{ togglePauseBox(false); }catch(_p1){}
       __endRaid('abandon'); __topClear(); state='hub'; lines.length=0;
       window.dispatchEvent(new Event('gamepaddisconnected'));
       if(pauseOpen) bad.push('a controller unplugged on the floor paused');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; state=st0;
       try{ togglePauseBox(false); }catch(_p2){}
       try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
