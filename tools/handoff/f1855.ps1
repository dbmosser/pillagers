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

if ($s.Contains("  {v:'18.55',what:")) { throw "check 18.55 is in the fixture already" }

SubRx @'
  {v:'18.54',what:
'@ @'
  {v:'18.55',what:'the player 2 save stays shut while its window is open: with no party mode in this window, a fresh mark from the player 2 window blocks that save, and an old or missing mark does not',
   run:function(){
     if(typeof slotBlocked!=='function'||typeof p2PtrKey!=='function') return 'SKIP: no player 2 saves here';
     if(typeof NETP2!=='undefined'&&NETP2) return 'SKIP: this is a player 2 window';
     var bad=[], kP=p2PtrKey(), kL='salvagerun:p2live', oP=null, oL=null, oSame=NET.same;
     try{ oP=localStorage.getItem(kP); oL=localStorage.getItem(kL); }catch(_o){}
     try{
       NET.same=null;
       localStorage.setItem(kP,'7');
       localStorage.removeItem(kL);
       if(slotBlocked('7')) bad.push('control: a save was shut with no player 2 window');
       if(typeof p2LiveBeat==='function') p2LiveBeat(); else localStorage.setItem(kL,String(Date.now()));
       if(!slotBlocked('7')) bad.push('the save the player 2 window has open could be loaded or erased after a reload');
       if(slotBlocked('6')) bad.push('another save was shut too');
       localStorage.setItem(kL,String(Date.now()-200000));
       if(slotBlocked('7')) bad.push('an old mark (a closed window) still shut the save');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ NET.same=oSame; try{ if(oP===null) localStorage.removeItem(kP); else localStorage.setItem(kP,oP); if(oL===null) localStorage.removeItem(kL); else localStorage.setItem(kL,oL); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
