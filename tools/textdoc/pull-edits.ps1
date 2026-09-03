# pull-edits.ps1 : his in-game text edits, out of the run reports and into a map.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\textdoc\pull-edits.ps1
#   then: import-text.ps1 -Map tools\textdoc\edits-pending.json   (add -Apply to write)
#
# Since v10.49 every run report carries a "TEXT EDITS: {json}" line, original
# to new, whenever the profile holds an edit made with the in-game editor
# (the Edit the words switch, v9.75). The local collector drops reports into
# exports/. This reads every report there, newest last so a later edit of the
# same line wins, and writes the merged map beside the text tools. An edit
# whose new text is empty is skipped; the editor never stores those anyway.
param(
  [string]$Exports = 'C:\claudecode\dark raiders\exports',
  [string]$Out = 'C:\claudecode\dark raiders\tools\textdoc\edits-pending.json'
)
$ErrorActionPreference = 'Stop'
$files = Get-ChildItem (Join-Path $Exports '*.txt') | Sort-Object LastWriteTime
$map = @{}
$seen = 0
foreach ($f in $files) {
  foreach ($ln in [IO.File]::ReadAllLines($f.FullName, [Text.Encoding]::UTF8)) {
    if ($ln -notmatch '^TEXT EDITS: (.*)$') { continue }
    $seen++
    try { $obj = $Matches[1] | ConvertFrom-Json } catch { Write-Output ("bad JSON in " + $f.Name); continue }
    foreach ($prop in $obj.PSObject.Properties) {
      if ($prop.Value -is [string] -and $prop.Value -ne '') { $map[$prop.Name] = $prop.Value }
    }
  }
}
$ordered = [ordered]@{}
foreach ($k in ($map.Keys | Sort-Object)) { $ordered[$k] = $map[$k] }
($ordered | ConvertTo-Json -Depth 2) | Out-File -Encoding utf8 $Out
Write-Output ("reports read: " + $files.Count + "   TEXT EDITS lines: " + $seen + "   distinct edits: " + $map.Count)
Write-Output ("map: " + $Out)
foreach ($k in $ordered.Keys) { Write-Output ("  [" + $k + "] -> [" + $ordered[$k] + "]") }
