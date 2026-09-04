$SP = 'C:\claudecode\dark raiders\tools\handoff'
Get-ChildItem (Join-Path $SP 'f10*.ps1') | ForEach-Object {
  $t = [IO.File]::ReadAllText($_.FullName)
  $u = $t.Replace('return />\?</.test(', 'return (/>\?</).test(')
  if ($u -ne $t) { [IO.File]::WriteAllText($_.FullName, $u, (New-Object Text.UTF8Encoding $false)); Write-Output ("fixed " + $_.Name) }
}
