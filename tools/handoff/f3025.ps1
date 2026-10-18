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

if ($s.Contains("  {v:'30.25',what:")) { throw "check 30.25 is in the fixture already" }

SubRx @'
  {v:'30.24',what:
'@ @'
  {v:'30.25',what:'the title does not show the PvP rows, and the arrows skip them (his Q72: hide PvP)',
   run:function(){
     var a=document.getElementById('modepvp'), b=document.getElementById('modepvpsrv'), w, rows, i;
     if(!a||!b) return 'SKIP: no PvP rows in the page';
     w=b.parentNode;
     if(getComputedStyle(a).display!=='none') return 'the same machine PvP row is still shown';
     if(getComputedStyle(w).display!=='none') return 'the PvP server row is still shown';
     if(typeof netTitleRows==='function'){ rows=netTitleRows(); for(i=0;i<rows.length;i++){ if(rows[i]===a||rows[i]===b) return 'the arrows can still land on a PvP row'; } }
     return null; }},
  {v:'30.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
