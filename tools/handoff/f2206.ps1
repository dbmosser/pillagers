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

if ($s.Contains("  {v:'22.06',what:")) { throw "check 22.06 is in the fixture already" }

SubRx @'
  {v:'22.05',what:
'@ @'
  {v:'22.06',what:'F11 in the player 2 window runs that window fullscreen toggle and is never handed to player 1; other keys still go to player 1',
   run:function(){
     if(typeof netKeyFwd!=='function'||typeof netSamePost!=='function'||typeof fsToggle!=='function'||typeof netKeyHeld==='undefined'||typeof NET!=='object'||!NET) return 'SKIP: no player 2 window here';
     var NK={}, k, bad=[], oPost=netSamePost, oFs=fsToggle, posts=[], fs=0, kh0=netKeyHeld, k0=keys;
     function key(ty,code){ window.dispatchEvent(new KeyboardEvent(ty,{code:code,key:code,bubbles:true,cancelable:true})); }
     function sent(code){ return posts.filter(function(m){ return m&&m.t==='key'&&m.code===code; }).length; }
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear();
       keys={}; netKeyHeld={};
       netSamePost=function(m){ posts.push(JSON.parse(JSON.stringify(m))); return true; };
       fsToggle=function(){ fs++; return true; };
       NET.same='p2'; NET.pair='zqk17pair';
       // CONTROL: a plain key pressed in the player 2 window is handed to player 1, down and up
       key('keydown','KeyJ'); key('keyup','KeyJ');
       if(sent('KeyJ')!==2) return 'SKIP: staging: the player 2 window did not hand a key to player 1 ('+sent('KeyJ')+' words)';
       if(fs) return 'SKIP: staging: a plain key ran the fullscreen toggle';
       key('keydown','F11'); key('keyup','F11');
       if(sent('F11')) bad.push('F11 in the player 2 window was handed to player 1 ('+sent('F11')+' words), which takes his window out of fullscreen');
       if(fs!==1) bad.push('F11 in the player 2 window ran its own fullscreen toggle '+fs+' times, not once');
       if(netKeyHeld.F11) bad.push('the player 2 window still counts F11 as a key held for player 1');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSamePost=oPost; fsToggle=oFs; netKeyHeld=kh0; keys=k0||{};
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
