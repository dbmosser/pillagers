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

if ($s.Contains("  {v:'34.45',what:")) { throw "check 34.45 is in the fixture already" }

SubRx @'
  {v:'34.44',what:
'@ @'
  {v:'34.45',what:'the initials card draws the active letter in the lime accent and the heading in tx-2, not amber and teal (critic 53 54 55)',
   run:function(){
     if(typeof arcadeIniDraw!=='function') return 'SKIP: no initials draw';
     var s=String(arcadeIniDraw);
     if(s.indexOf('#ffc04a')>=0) return 'the active initial is still amber';
     if(s.indexOf('#7fe3d4')>=0) return 'the initials heading is still teal';
     if(s.indexOf('span.cur{color:var(--acc)')<0) return 'the active initial is not the accent';
     return null; }},
  {v:'34.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
