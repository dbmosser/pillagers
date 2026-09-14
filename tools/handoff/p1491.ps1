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
  if(typeof next!=='string'||next===''||next===orig){
    delete m[orig];
    delete pm[so.pat];
  } else {
'@ @'
  if(typeof next!=='string'||next===''||next===orig){
    delete m[orig];
    delete pm[so.pat];
    // v14.91, words audit finding 3: CLEARING A BAKED LINE BRINGS THE ORIGINAL BACK. With his profile entry
    // deleted the shipped edit showed again, so clearing a line he had baked changed nothing on screen and the report carried
    // nothing to undo the bake with. For a baked line the original is written as his own entry instead.
    if(TXSHIP&&typeof TXSHIP[orig]==='string') m[orig]=orig;
    if(so.nums.length&&typeof TXPSHIP==='object'&&TXPSHIP&&typeof TXPSHIP[so.pat]==='string') pm[so.pat]=so.pat;
  } else {
'@
SubRx @'
var VER='14.90';
'@ @'
var VER='14.91';
'@

$pat = "(?m)^  now:'v14\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.91: CLEARING A BAKED LINE IN THE WORDS EDITOR BRINGS THE ORIGINAL BACK. An empty edit is how he gets a line back, but for a line baked into the file it only deleted his profile entry, so the baked words stayed on screen and the report carried nothing to undo the bake. The original is now written as his own entry for a baked line. Check 14.91 clears a baked line; it fails on v14.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
