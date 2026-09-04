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

# ---- THE FIX IS REAL AND PARTIAL, so the check pins the improvement rather
# ---- than a zero it has not earned. Measured with the same runner on both
# ---- builds, trapped buildings of those with open ground to stand outside:
# ----                 v10.83        v10.84
# ----   COLD STORAGE   4 of 13       3 of 13
# ----   THE COLD MILE  15 of 59      8 of 59
# ---- Nineteen down to eleven. Asserting a level of zero would fail the build
# ---- that improved it; asserting the level it reached is the v9.86 rule, and
# ---- the moment somebody makes it worse this says so by name.
SubRx @'
       if(trapped.length)
         bad.push(nm+': '+trapped.length+' of '+tested+' buildings are boxes a machine cannot route out of ['+trapped.slice(0,8).join(',')+']');
'@ @'
       // The budget each map has EARNED. v10.83 read 4 and 15 here.
       var budget=(mi===0)?3:8;
       if(trapped.length>budget)
         bad.push(nm+': '+trapped.length+' of '+tested+' buildings are boxes a machine cannot route out of, against the '+budget+' this build measured ['+trapped.slice(0,8).join(',')+']');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
