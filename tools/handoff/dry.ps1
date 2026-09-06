$ErrorActionPreference = 'Continue'
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$dry = Join-Path $SP 'dry'
Copy-Item 'C:\claudecode\dark raiders\dark_raiders.html' (Join-Path $dry 'game.html') -Force
Copy-Item 'C:\claudecode\dark raiders\tools\mkfixture.ps1' (Join-Path $dry 'mk.ps1') -Force
$gamePath = Join-Path $dry 'game.html'
$mkPath = Join-Path $dry 'mk.ps1'
$first = [int]$args[0]; $last = [int]$args[1]
for ($n = $first; $n -le $last; $n++) {
  foreach ($k in @('p','f')) {
    $f = Join-Path $SP ("$k$n.ps1")
    if (-not (Test-Path $f)) { Write-Output "$k$n : MISSING"; continue }
    $src = [IO.File]::ReadAllText($f)
    if ($k -eq 'p') { $src = $src.Replace("`$p = 'C:\claudecode\dark raiders\dark_raiders.html'", "`$p = '$gamePath'") }
    else { $src = $src.Replace("`$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'", "`$p = '$mkPath'") }
    if ($src.IndexOf($dry) -lt 0) { Write-Output "$k$n : path substitution failed"; exit 1 }
    $run = Join-Path $dry 'run.ps1'
    [IO.File]::WriteAllText($run, $src, (New-Object Text.UTF8Encoding $false))
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $run 2>&1 | Select-Object -Last 1
    Write-Output "$k$n : $out"
  }
}
$g = [IO.File]::ReadAllText($gamePath)
$m = [regex]::Match($g, "var VER='([0-9.]+)'")
Write-Output ("dry game at v" + $m.Groups[1].Value)
