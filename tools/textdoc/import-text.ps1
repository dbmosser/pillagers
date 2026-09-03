# import-text.ps1 : put his edited Word document back into the game.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\textdoc\import-text.ps1 -Doc "C:\...\PILLAGERS-text-v10.39.docx"
#   add -Apply to write; without it the script only reports what it would change.
#
# Reads the table out of the .docx (word/document.xml), matches each row's ID to
# the manifest written by export-text.ps1, and for every row whose TEXT differs
# replaces the ORIGINAL text in the game file with the new one, everywhere it
# appears. Curly quotes and dashes are turned into their plain cousins; a
# character outside ASCII inside a script string becomes a \u escape so the
# file stays clean. Apostrophes and quotes are escaped to match the literal
# they sit in. Nothing is written unless -Apply is given.
param(
  [Parameter(Mandatory=$true)][string]$Doc,
  [string]$Manifest = '',
  [string]$Game = 'C:\claudecode\dark raiders\dark_raiders.html',
  [switch]$Apply
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

if ($Manifest -eq '') {
  $dir = Split-Path $Doc
  $cand = Get-ChildItem (Join-Path $dir 'manifest-v*.json') | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $cand) { throw 'no manifest beside the document; pass -Manifest' }
  $Manifest = $cand.FullName
}
$man = Get-Content $Manifest -Raw | ConvertFrom-Json
$byId = @{}
foreach ($e in $man) { $byId[$e.id] = $e }

# 1. the rows out of the document
$zip = [System.IO.Compression.ZipFile]::OpenRead($Doc)
$entry = $zip.GetEntry('word/document.xml')
$sr = New-Object IO.StreamReader($entry.Open(), [Text.Encoding]::UTF8)
$xml = $sr.ReadToEnd(); $sr.Close(); $zip.Dispose()
$rows = @()
foreach ($tr in [regex]::Matches($xml, '(?s)<w:tr[ >].*?</w:tr>')) {
  $cells = @()
  foreach ($tc in [regex]::Matches($tr.Value, '(?s)<w:tc[ >].*?</w:tc>')) {
    $txt = ''
    foreach ($t in [regex]::Matches($tc.Value, '(?s)<w:t(?: [^>]*)?>(.*?)</w:t>')) { $txt += $t.Groups[1].Value }
    $txt = [System.Net.WebUtility]::HtmlDecode($txt)
    $cells += ,$txt
  }
  if ($cells.Count -ge 3) { $rows += ,@($cells[0].Trim(), $cells[1].Trim(), $cells[2]) }
}
$rows = $rows | Where-Object { $_[0] -match '^[0-9a-f]{8}$' }
Write-Output ("rows in the document: " + $rows.Count + "   lines in the manifest: " + $man.Count)

function Plain([string]$t) {
  $t = $t -replace "[\u2018\u2019\u201A]", "'" -replace "[\u201C\u201D\u201E]", '"' -replace "[\u2013\u2014]", "-" -replace "\u2026", "..." -replace "\u00A0", " "
  return $t
}
function ToLiteral([string]$t, [string]$quote) {
  # what goes inside the quotes of a script literal
  $t = $t -replace '\\', '\\\\'
  if ($quote -eq "'") { $t = $t -replace "'", "\'" } elseif ($quote -eq '"') { $t = $t -replace '"', '\"' }
  $sb = New-Object Text.StringBuilder
  foreach ($ch in $t.ToCharArray()) {
    if ([int]$ch -gt 126) { [void]$sb.Append('\u' + ([int]$ch).ToString('x4')) } else { [void]$sb.Append($ch) }
  }
  return $sb.ToString()
}

$s = [IO.File]::ReadAllText($Game)
$changed = 0; $missing = 0; $unknown = 0; $log = @()
foreach ($r in $rows) {
  $id = $r[0]; $new = Plain ($r[2].Trim())
  if (-not $byId.ContainsKey($id)) { $unknown++; continue }
  $e = $byId[$id]
  if ($new -eq $e.text) { continue }
  if ($new -eq '') { $log += ("SKIP empty replacement for " + $id + " (" + $e.text + ")"); continue }
  if ($e.kind -eq 'markup' -or $e.kind -eq 'markup-attr') {
    $old = $e.raw; $rep = [System.Security.SecurityElement]::Escape($new) -replace '&apos;', "'"
  } else {
    $old = $e.raw; $rep = ToLiteral $new $e.quote
  }
  $count = ([regex]::Matches($s, [regex]::Escape($old))).Count
  if ($count -eq 0) { $missing++; $log += ("MISSING in the game now: " + $id + " (" + $e.text + ")"); continue }
  $s = $s.Replace($old, $rep)
  $changed++
  $log += ("CHANGED x" + $count + " line " + $e.line + ": [" + $e.text + "] -> [" + $new + "]")
}
$log | ForEach-Object { Write-Output $_ }
Write-Output ("changed " + $changed + ", missing " + $missing + ", unknown ids " + $unknown)
if ($Apply -and $changed -gt 0) {
  [IO.File]::WriteAllText($Game, $s, (New-Object Text.UTF8Encoding $false))
  Write-Output ("written: " + $Game + "   (now rebuild the fixture, parse check, corpus, bump VER, commit)")
} elseif (-not $Apply) {
  Write-Output "dry run only; add -Apply to write"
}
