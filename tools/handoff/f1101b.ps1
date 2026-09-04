$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
SubRx @'
       if(joined.indexOf(MUST[i][0])<0) bad.push('the end of raid buttons have no '+MUST[i][1]);
'@ @'
       if(joined.indexOf(MUST[i][0])<0) bad.push('the end of raid buttons offer no way to say '+MUST[i][1]);
'@
SubRx @'
     var MUST=[['crash','a way to say it crashed'],
               ['looked wrong','a way to say something looked wrong'],
               ['sound','a way to say the sound was off'],
               ['read','a way to say text was hard to read']];
'@ @'
     var MUST=[['crash','it crashed'],
               ['looked wrong','something looked wrong'],
               ['sound','the sound was off'],
               ['read','text was hard to read']];
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
