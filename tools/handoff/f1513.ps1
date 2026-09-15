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
  {v:'15.12',what:
'@ @'
  {v:'15.13',what:'a restore code stays short enough to paste: over seventy blank named pillager records and one real one, the code carries only the real record, stays under 4,000 characters, and a restore still gives that record back (corpus on v15.11, check 11.03)',
   run:function(){
     if(typeof restoreMake!=='function'||typeof restoreCode!=='function'||typeof restoreApply!=='function'||!window.__applyLoaded) return 'SKIP: no restore codes in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var rv={};
       for(var i=0;i<72;i++) rv['zqxblank'+i]={kills:0,deaths:0,met:0,standing:0};
       rv.zqxreal={kills:2,deaths:0,met:2,standing:-5};
       __P().rivals=rv;
       var o=JSON.parse(JSON.stringify(restoreMake()));
       // CONTROL: the code carries a rivals record at all.
       if(!o.rv||typeof o.rv!=='object') return 'SKIP: this build carries no named pillager records in the code';
       var n=Object.keys(o.rv).length;
       if(n!==1) bad.push('the code carries '+n+' named pillager records where only one holds anything');
       var len=(restoreCode()||'').length;
       if(len>4000) bad.push('the code is '+len+' characters over 72 blank records');
       __P().rivals={};
       if(restoreApply(o)===false) return 'SKIP: restoreApply refused a code made a moment ago';
       var back=(__P().rivals||{}).zqxreal;
       if(!back||back.kills!==2||back.standing!==-5) bad.push('after the restore the real record came back as '+JSON.stringify(back));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'15.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
