# mkdoc.ps1 : a plain text file with light markers into a .docx, no Word needed.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\textdoc\mkdoc.ps1 -In notes.txt -Out notes.docx
#
# Markers, one per line:  "# Title"  "## Heading"  "### Small heading"
#   "1. step" (numbered, kept as written)   "- bullet"   blank line ends a paragraph
#   anything else is a paragraph line; consecutive lines join with a space.
param([Parameter(Mandatory=$true)][string]$In, [Parameter(Mandatory=$true)][string]$Out, [string]$Title = '')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
function X([string]$t) { return [System.Security.SecurityElement]::Escape($t) }
function Run([string]$t, [string]$rpr) { return '<w:r>' + $rpr + '<w:t xml:space="preserve">' + (X $t) + '</w:t></w:r>' }
function Para([string]$t, [string]$ppr, [string]$rpr) { return '<w:p>' + $ppr + (Run $t $rpr) + '</w:p>' }
$sb = New-Object System.Text.StringBuilder
[void]$sb.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>')
$buf = @()
function Flush() {
  if ($script:buf.Count -gt 0) {
    [void]$script:sb.Append((Para ($script:buf -join ' ') '<w:pPr><w:spacing w:after="160"/></w:pPr>' '<w:rPr><w:sz w:val="22"/></w:rPr>'))
    $script:buf = @()
  }
}
foreach ($raw in [IO.File]::ReadAllLines($In, [Text.Encoding]::UTF8)) {
  $ln = $raw.TrimEnd()
  if ($ln -eq '') { Flush; continue }
  if ($ln -match '^# (.*)$') { Flush; [void]$sb.Append((Para $Matches[1] '<w:pPr><w:spacing w:before="200" w:after="200"/></w:pPr>' '<w:rPr><w:b/><w:sz w:val="40"/></w:rPr>')); continue }
  if ($ln -match '^## (.*)$') { Flush; [void]$sb.Append((Para $Matches[1] '<w:pPr><w:spacing w:before="280" w:after="120"/></w:pPr>' '<w:rPr><w:b/><w:sz w:val="30"/></w:rPr>')); continue }
  if ($ln -match '^### (.*)$') { Flush; [void]$sb.Append((Para $Matches[1] '<w:pPr><w:spacing w:before="200" w:after="80"/></w:pPr>' '<w:rPr><w:b/><w:sz w:val="24"/></w:rPr>')); continue }
  if ($ln -match '^(\d+)\. (.*)$') { Flush; [void]$sb.Append((Para ($Matches[1] + '.  ' + $Matches[2]) '<w:pPr><w:ind w:left="560" w:hanging="400"/><w:spacing w:after="120"/></w:pPr>' '<w:rPr><w:sz w:val="22"/></w:rPr>')); continue }
  if ($ln -match '^- (.*)$') { Flush; [void]$sb.Append((Para ('*  ' + $Matches[1]) '<w:pPr><w:ind w:left="560" w:hanging="300"/><w:spacing w:after="100"/></w:pPr>' '<w:rPr><w:sz w:val="22"/></w:rPr>')); continue }
  $buf += $ln
}
Flush
[void]$sb.Append('<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1200" w:right="1100" w:bottom="1200" w:left="1100" w:header="500" w:footer="500" w:gutter="0"/></w:sectPr></w:body></w:document>')
$types = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>'
$rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>'
if (Test-Path $Out) { Remove-Item $Out -Force }
$zip = [System.IO.Compression.ZipFile]::Open($Out, [System.IO.Compression.ZipArchiveMode]::Create)
function Put([System.IO.Compression.ZipArchive]$z, [string]$name, [string]$content) {
  $entry = $z.CreateEntry($name); $st = $entry.Open()
  $bytes = (New-Object Text.UTF8Encoding $false).GetBytes($content); $st.Write($bytes, 0, $bytes.Length); $st.Close()
}
Put $zip '[Content_Types].xml' $types
Put $zip '_rels/.rels' $rels
Put $zip 'word/document.xml' $sb.ToString()
$zip.Dispose()
Write-Output ("docx: " + $Out)
