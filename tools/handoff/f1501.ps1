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
  {v:'15.00',what:
'@ @'
  {v:'15.01',what:'a restore code carries the contracts completed count: a code made at seven contracts, restored over a character at ninety nine, leaves seven (save audit finding 2)',
   run:function(){
     if(typeof restoreMake!=='function'||typeof restoreApply!=='function'||!window.__applyLoaded) return 'SKIP: no restore codes in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __P().cdone=7;
       var o=JSON.parse(JSON.stringify(restoreMake()));
       __P().cdone=99;
       var ok=restoreApply(o);
       // CONTROL: the code applied.
       if(ok===false) return 'SKIP: restoreApply refused a code made a moment ago';
       if(__P().cdone!==7) bad.push('after restoring a code made at 7 contracts the board counts '+__P().cdone);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'15.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
