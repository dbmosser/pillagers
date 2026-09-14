$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
      L.push('  after run #'+fn.run+' '+when+': '+fn.txt);
'@ @'
      // v14.53, report audit finding 4: A NOTE WITH A LINE BREAK STAYS ON ITS OWN LABELLED LINE. The note boxes are text areas,
      // so Enter put a break in the note and its second line printed at column 0 with no label, reading as a line of the
      // report itself. Breaks print as a slash; the note text itself is kept as typed.
      L.push('  after run #'+fn.run+' '+when+': '+String(fn.txt).replace(/\s*\n\s*/g,' / '));
'@
SubRx @'
    if(r.note) L.push('   note: '+r.note);
    (r.inRunNotes||[]).forEach(function(n){ L.push('   in-run note @'+n.t+'s: '+n.txt); });
'@ @'
    if(r.note) L.push('   note: '+String(r.note).replace(/\s*\n\s*/g,' / '));   // v14.53: one labelled line
    (r.inRunNotes||[]).forEach(function(n){ L.push('   in-run note @'+n.t+'s: '+String(n.txt).replace(/\s*\n\s*/g,' / ')); });
'@
SubRx @'
var VER='14.52';
'@ @'
var VER='14.53';
'@

$pat = "(?m)^  now:'v14\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.53: A NOTE WITH A LINE BREAK STAYS ONE LINE IN THE REPORT. Notes are typed in text areas, so Enter put a break in them, and the second line of a note printed at the left margin with no label, reading as part of the report itself. Breaks in floor, run and in-run notes now print as a slash on the note own line. Check 14.53 builds a report with a floor note typed over two lines; it fails on v14.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
