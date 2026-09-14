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
  {v:'13.93',what:
'@ @'
  {v:'13.94',what:'a hire who died on your job is not your rival: an identity with two deaths and no kills is not picked as the rival, while an identity with two kills is (contracts, notoriety and waves audit 2026-09-14, finding 5)',
   run:function(){
     if(!window.__P||typeof myRival!=='function'||typeof IDENTITIES==='undefined'||IDENTITIES.length<2) return 'SKIP: no rivals ledger in this build';
     var bad=[], P2=__P(), keep=JSON.stringify(P2.rivals||{});
     var A=IDENTITIES[0].id, B=IDENTITIES[1].id;
     try{
       // CONTROL: two kills make a rival.
       P2.rivals={}; P2.rivals[B]={kills:2,deaths:0,met:2,standing:-3};
       if(myRival()!==B) return 'SKIP: two kills did not make a rival in this build ('+myRival()+'), so nothing here can be measured';
       // THE FINDING: two deaths on your job, no kills.
       P2.rivals={}; P2.rivals[A]={kills:0,deaths:2,met:2,standing:-1};
       if(myRival()===A) bad.push('an identity that only ever died on your job, twice, was picked as your rival');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ P2.rivals=JSON.parse(keep); saveProfile(); }catch(_s){} }
     return bad.length?bad.join('; '):null; }},
  {v:'13.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
