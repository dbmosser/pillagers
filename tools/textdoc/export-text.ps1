# export-text.ps1 : every piece of text a player can read, as a Word document.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\textdoc\export-text.ps1
#
# Reads dark_raiders.html, pulls the text out of the markup (what is between the
# tags) and out of the script (string literals that read as words, and the words
# inside HTML that the script writes), gives each distinct line an ID (the first
# eight hex of its SHA1), writes a manifest (JSON) beside the document, and
# builds the .docx by hand: a docx is a zip of three XML parts and needs no Word.
#
# He edits the TEXT column only, keeps the ID column, and returns the file;
# import-text.ps1 puts the edits back by exact replacement of the original.
param(
  [string]$Src = 'C:\claudecode\dark raiders\dark_raiders.html',
  [string]$OutDir = 'C:\claudecode\dark raiders\tools\textdoc'
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$s = [IO.File]::ReadAllText($Src)
$ver = ([regex]::Match($s, "var VER='([0-9.]+)'")).Groups[1].Value
$scriptAt = $s.IndexOf('<script>')
$markup = $s.Substring(0, $scriptAt)
$script = $s.Substring($scriptAt)

# line starts, for line numbers
$lineStarts = New-Object System.Collections.Generic.List[int]
$lineStarts.Add(0)
for ($i = 0; $i -lt $s.Length; $i++) { if ($s[$i] -eq "`n") { $lineStarts.Add($i + 1) } }
function LineOf([int]$pos) {
  $lo = 0; $hi = $lineStarts.Count - 1
  while ($lo -lt $hi) { $mid = [int](($lo + $hi + 1) / 2); if ($lineStarts[$mid] -le $pos) { $lo = $mid } else { $hi = $mid - 1 } }
  return $lo + 1
}

$sha = [System.Security.Cryptography.SHA1]::Create()
function IdOf([string]$t) {
  $b = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($t))
  return (($b[0..3] | ForEach-Object { $_.ToString('x2') }) -join '')
}
function Wordy([string]$t, [int]$minWords) {
  # words of letters with a space between them, and nothing that reads as code or style
  if ($t.Length -lt 2) { return $false }
  $words = ([regex]::Matches($t, '[A-Za-z]{2,}')).Count
  if ($words -lt $minWords) { return $false }
  if ($minWords -ge 2 -and $t -notmatch '\s') { return $false }
  if ($t -match 'sans-serif|monospace|px "' ) { return $false }
  if ($t -eq 'use strict') { return $false }
  if ($t -match '^[\w\-]+$' -and $t -match '_') { return $false }
  if ($t -match '^[\s\w\-]+:\s*[^;]*;?\s*$' -and $t -notmatch '\s[a-z]+\s') { return $false }   # css declaration
  if ($t -match '^(bold |italic |\d+ )*\d+(\.\d+)?px') { return $false }                         # font spec
  if ($t -match '=>|function\s*\(|\)\s*\{|\}\s*\)|;\s*$' -and $t -notmatch '[.!?]\s*$') { return $false }
  if ($t -match '^[#.][\w\-]+(\s*[,>][\s#.\w\-]+)*$') { return $false }                          # selector
  if ($t -match '^https?://') { return $false }
  if ($t -match '^[\w\-]+=[\w\-]+(&[\w\-]+=[\w\-]+)*$') { return $false }
  return $true
}

$entries = New-Object System.Collections.ArrayList
$seen = @{}
function Add([string]$text, [string]$raw, [int]$pos, [string]$kind, [string]$quote) {
  $t = $text.Trim()
  $min = if ($kind -eq 'markup' -or $kind -eq 'markup-attr' -or $kind -eq 'name') { 1 } else { 2 }
  if (-not (Wordy $t $min)) { return }
  if ($seen.ContainsKey($t)) { return }
  $seen[$t] = 1
  [void]$entries.Add([pscustomobject]@{ id = (IdOf $t); line = (LineOf $pos); kind = $kind; quote = $quote; raw = $raw; text = $t })
}

# 1. markup: text between tags, styles removed
$mk = [regex]::Replace($markup, '(?s)<style.*?</style>', { param($m) ' ' * $m.Length })
foreach ($m in [regex]::Matches($mk, '>([^<>]+)<')) {
  $t = $m.Groups[1].Value
  if ($t -match '[A-Za-z]') { Add $t $t ($m.Groups[1].Index) 'markup' '' }
}
foreach ($m in [regex]::Matches($mk, '(?:title|placeholder|alt)="([^"]+)"')) {
  Add $m.Groups[1].Value $m.Groups[1].Value ($m.Groups[1].Index) 'markup-attr' ''
}

# 2. script: string literals, with whole-line comments blanked first so a quote
#    in a comment cannot pair with a quote in code
$lines = $script -split "`n"
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '^\s*//') { $lines[$i] = ' ' * $lines[$i].Length }
}
$sc = $lines -join "`n"
$lit = [regex]"'((?:[^'\\\r\n]|\\.)*)'|""((?:[^""\\\r\n]|\\.)*)"""
foreach ($m in $lit.Matches($sc)) {
  $body = if ($m.Groups[1].Success) { $m.Groups[1].Value } else { $m.Groups[2].Value }
  $quote = if ($m.Groups[1].Success) { "'" } else { '"' }
  if ($body.Length -lt 4) { continue }
  $pos = $scriptAt + $m.Index
  $shown = $body -replace "\\'", "'" -replace '\\"', '"' -replace '\\n', ' '
  if ($shown -match '<[a-zA-Z/][^<>]*>') {
    # html written by the script: the words between its tags, each its own line
    foreach ($f in [regex]::Matches($shown, '>([^<>]+)<')) {
      $frag = $f.Groups[1].Value
      if ($frag -match '[A-Za-z]') { Add $frag $frag.Trim() $pos 'html-in-js' $quote }
    }
    if ($shown -match '^([^<>]+)<') { $lead = $Matches[1]; if ($lead -match '[A-Za-z]') { Add $lead $lead.Trim() $pos 'html-in-js' $quote } }
    if ($shown -match '>([^<>]+)$') { $tail = $Matches[1]; if ($tail -match '[A-Za-z]') { Add $tail $tail.Trim() $pos 'html-in-js' $quote } }
  } else {
    if ($shown -match '\+\s*$|^\s*\+') { continue }
    Add $shown $body $pos 'js' $quote
  }
}

# 3. names: item, weapon, rack, option and station names are single words more
#    often than not, so they get in on their field name rather than their length
foreach ($m in [regex]::Matches($sc, "\b(?:name|n|label|title)\s*:\s*'((?:[^'\\\r\n]|\\.)+)'")) {
  $body = $m.Groups[1].Value
  if ($body -match '[A-Za-z]{2,}' -and $body -notmatch '<') {
    $shown = $body -replace "\\'", "'"
    Add $shown $body ($scriptAt + $m.Groups[1].Index) 'name' "'"
  }
}

$sorted = $entries | Sort-Object line
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$manifest = Join-Path $OutDir ("manifest-v" + $ver + ".json")
($sorted | ConvertTo-Json -Depth 3 -Compress) | Out-File -Encoding utf8 $manifest

# 3. the document
function X([string]$t) { return [System.Security.SecurityElement]::Escape($t) }
$sb = New-Object System.Text.StringBuilder
[void]$sb.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
[void]$sb.Append('<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>')
function Para([string]$t, [bool]$bold) {
  $rpr = if ($bold) { '<w:rPr><w:b/></w:rPr>' } else { '' }
  return '<w:p><w:r>' + $rpr + '<w:t xml:space="preserve">' + (X $t) + '</w:t></w:r></w:p>'
}
[void]$sb.Append((Para ("PILLAGERS v" + $ver + ": every piece of text in the game") $true))
[void]$sb.Append((Para ("Exported " + (Get-Date).ToString('yyyy-MM-dd HH:mm') + ". " + $sorted.Count + " distinct lines, in the order they sit in the file, which is roughly by screen.") $false))
[void]$sb.Append((Para "How to use it: change anything in the TEXT column. Leave the ID column alone; it is how each line finds its way back. Do not add or delete rows. Send the file back and the edits go into the game by exact replacement, so a line that appears in several places changes in all of them." $false))
[void]$sb.Append((Para "WHERE says the line number in the game file and what kind of text it is: markup is the page itself, js is a message or a label the code writes, html-in-js is a label inside a panel the code builds. Lines that read like code or style crept past the filter here and there; leave those alone." $false))
[void]$sb.Append((Para "Apostrophes and quotes are fine. Please keep to plain characters where you can; a curly quote or a dash is turned into its plain cousin on the way back in." $false))
[void]$sb.Append('<w:tbl><w:tblPr><w:tblW w:w="0" w:type="auto"/><w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="999999"/><w:left w:val="single" w:sz="4" w:space="0" w:color="999999"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="999999"/><w:right w:val="single" w:sz="4" w:space="0" w:color="999999"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="999999"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="999999"/></w:tblBorders></w:tblPr>')
[void]$sb.Append('<w:tblGrid><w:gridCol w:w="1300"/><w:gridCol w:w="1500"/><w:gridCol w:w="6500"/></w:tblGrid>')
function Cell([string]$t, [int]$w, [bool]$bold) {
  $rpr = if ($bold) { '<w:rPr><w:b/></w:rPr>' } else { '' }
  return '<w:tc><w:tcPr><w:tcW w:w="' + $w + '" w:type="dxa"/></w:tcPr><w:p><w:r>' + $rpr + '<w:t xml:space="preserve">' + (X $t) + '</w:t></w:r></w:p></w:tc>'
}
[void]$sb.Append('<w:tr>' + (Cell 'ID' 1300 $true) + (Cell 'WHERE' 1500 $true) + (Cell 'TEXT' 6500 $true) + '</w:tr>')
foreach ($e in $sorted) {
  [void]$sb.Append('<w:tr>' + (Cell $e.id 1300 $false) + (Cell ($e.line.ToString() + ' ' + $e.kind) 1500 $false) + (Cell $e.text 6500 $false) + '</w:tr>')
}
[void]$sb.Append('</w:tbl><w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1000" w:right="900" w:bottom="1000" w:left="900" w:header="500" w:footer="500" w:gutter="0"/></w:sectPr></w:body></w:document>')
$docXml = $sb.ToString()

$types = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>'
$rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>'

$docx = Join-Path $OutDir ("PILLAGERS-text-v" + $ver + ".docx")
if (Test-Path $docx) { Remove-Item $docx -Force }
$zip = [System.IO.Compression.ZipFile]::Open($docx, [System.IO.Compression.ZipArchiveMode]::Create)
function Put([System.IO.Compression.ZipArchive]$z, [string]$name, [string]$content) {
  $entry = $z.CreateEntry($name)
  $st = $entry.Open()
  $bytes = (New-Object Text.UTF8Encoding $false).GetBytes($content)
  $st.Write($bytes, 0, $bytes.Length)
  $st.Close()
}
Put $zip '[Content_Types].xml' $types
Put $zip '_rels/.rels' $rels
Put $zip 'word/document.xml' $docXml
$zip.Dispose()

Write-Output ("lines: " + $sorted.Count)
Write-Output ("markup " + (@($sorted | Where-Object { $_.kind -eq 'markup' })).Count + ", markup-attr " + (@($sorted | Where-Object { $_.kind -eq 'markup-attr' })).Count + ", js " + (@($sorted | Where-Object { $_.kind -eq 'js' })).Count + ", html-in-js " + (@($sorted | Where-Object { $_.kind -eq 'html-in-js' })).Count)
Write-Output ("manifest: " + $manifest)
Write-Output ("docx: " + $docx)
