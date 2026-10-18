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

if ($s.Contains("  {v:'29.30',what:")) { throw "check 29.30 is in the fixture already" }

SubRx @'
  {v:'29.29',what:
'@ @'
  {v:'29.30',what:'the title key line names F1 for the controls list, not H (H heals since keyswap)',
   run:function(){
     var rows=document.querySelectorAll('#title .kbrow'), t='', i;
     for(i=0;i<rows.length;i++) t+=' '+rows[i].textContent;
     if(!t) return 'no title key line found';
     if(/\bH\s+controls/.test(t)) return 'the title still says H controls, but H heals';
     if(!/\bF1\s+controls/.test(t)) return 'the title key line does not say F1 controls';
     return null;
   }},
  {v:'29.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
