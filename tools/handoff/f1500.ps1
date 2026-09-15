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
  {v:'14.99',what:
'@ @'
  {v:'15.00',what:'a restore code carries his standing with the named pillagers: a code made with a grudge against one pillager, restored over a character with a grudge against another, leaves the first grudge and not the second (save audit finding 1)',
   run:function(){
     if(typeof restoreMake!=='function'||typeof restoreApply!=='function'||!window.__applyLoaded) return 'SKIP: no restore codes in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __P().rivals={zqxA:{kills:3,deaths:0,met:3,standing:-4}};
       var o=JSON.parse(JSON.stringify(restoreMake()));
       __P().rivals={zqxB:{kills:1,deaths:0,met:1,standing:-2}};
       var ok=restoreApply(o);
       // CONTROL: the code applied.
       if(ok===false) return 'SKIP: restoreApply refused a code made a moment ago';
       var rv=__P().rivals||{};
       if(!rv.zqxA||rv.zqxA.kills!==3) bad.push('the grudge carried by the code is gone after the restore ('+JSON.stringify(rv).slice(0,80)+')');
       if(rv.zqxB) bad.push('the replaced character\'s grudge is still there after the restore');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
