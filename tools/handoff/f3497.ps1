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

if ($s.Contains("  {v:'34.97',what:")) { throw "check 34.97 is in the fixture already" }

SubRx @'
  {v:'34.96',what:
'@ @'
  {v:'34.97',what:'cw-exportguard: the flight recorder export does not throw on a run record with no outcome (it prints a question mark), so the play data export and the demo run report still go out',
   run:function(){
     if(typeof buildExport!=='function') return 'SKIP: no buildExport';
     var keep=P.log, t, bad=[];
     try{
       __runPrep(); __topClear(); __cleanProfile();
       P.log=[{n:1,ver:'1.00',mapName:'zqx'},{n:2,outcome:'extract',haul:10}];
       try{ t=buildExport(); }catch(e){ return 'the export threw on a record with no outcome: '+(e&&e.message||e); }
       if(typeof t!=='string'||t.indexOf('#1 v1.00 ?')<0) bad.push('the record with no outcome is not printed with a question mark');
       if(t.indexOf('#2 v?')<0||t.indexOf('EXTRACT')<0) bad.push('a normal record is missing from the export');
       return bad.length?bad.join('; '):null;
     } finally { P.log=keep; try{ __topClear(); }catch(_c){} } }},
  {v:'34.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
