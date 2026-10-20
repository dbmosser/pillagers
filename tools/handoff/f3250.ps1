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

if ($s.Contains("  {v:'32.50',what:")) { throw "check 32.50 is in the fixture already" }

SubRx @'
  {v:'32.49',what:
'@ @'
  {v:'32.50',what:'corner readout shows $ money, not the word credits',
   run:function(){
     var bad=[];
     try{
       var el=document.getElementById('topright'); if(!el) return 'SKIP: no corner readout';
       var c0=P.credits; P.credits=4321; _trLast=null;
       try{ syncTopRight(); }catch(_s){}
       var t=(el.textContent||'');
       if(!t) return 'SKIP: corner empty (demo)';
       if(/credits/i.test(t)) bad.push('still says credits: '+t);
       if(t.indexOf('$4,321')!==0) bad.push('no $4,321 first: '+t);
       if(!el.querySelector('.trgap')||el.querySelector('.trgap').getBoundingClientRect().width<20) bad.push('no 24px gap');
       P.credits=c0; _trLast=null; try{ syncTopRight(); }catch(_s2){}
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
