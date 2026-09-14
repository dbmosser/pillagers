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
  {v:'14.46',what:
'@ @'
  {v:'14.47',what:'a button held while the floor pause box closes does not fire a station: opening and closing the pause box on the floor with the E lock off leaves the lock armed (floor audit finding 3)',
   run:function(){
     if(typeof showScreen!=='function'||typeof togglePauseBox!=='function') return 'SKIP: no floor pause box in this build';
     if(typeof G!=='undefined'&&G) return 'SKIP: a raid is live, so the floor pause box cannot be driven';
     var box=document.getElementById('pausebox');
     if(!box) return 'SKIP: no pause box in this document';
     var bad=[];
     try{
       __topClear(); __cleanProfile();
       showScreen('hub'); __topClear();
       if(typeof HB==='undefined'||!HB) return 'SKIP: no Undercroft floor in this build';
       HB.eLock=false;
       togglePauseBox(true);
       if(!box.classList.contains('on')) return 'SKIP: the pause box did not open on the floor here';
       togglePauseBox(false);
       // CONTROL: the box closed.
       if(box.classList.contains('on')) return 'SKIP: the pause box did not close';
       if(HB.eLock!==true) bad.push('closing the floor pause box left the E lock off, so a key or button held through the close fires the station he stands at');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(box.classList.contains('on')) togglePauseBox(false); }catch(_p){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
