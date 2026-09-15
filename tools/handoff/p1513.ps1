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
function restoreMake(){
'@ @'
// v15.13, corpus on v15.11 (check 11.03): A RESTORE CODE STAYS SHORT ENOUGH TO PASTE. v15.00 put every named pillager's record in
// the code, and a record is written, all zeros, for each named pillager a raid ever names, so a long save carried seventy blank
// records and a code over 6,000 characters, past what a person pastes into a chat window. Only a record that holds something
// travels; a missing record is created, all zeros, the moment the game reads it.
function rivalsForCode(){
  var out={}, rv=P.rivals||{};
  for(var id in rv){
    var r=rv[id]||{};
    if((r.kills|0)||(r.deaths|0)||(r.met|0)||(r.standing|0)) out[id]={kills:r.kills|0,deaths:r.deaths|0,met:r.met|0,standing:r.standing|0};
  }
  return out;
}
function restoreMake(){
'@
SubRx @'
         rv:P.rivals||{},
'@ @'
         rv:rivalsForCode(),   // v15.13: only the records that hold something
'@
SubRx @'
var VER='15.12';
'@ @'
var VER='15.13';
'@

$pat = "(?m)^  now:'v15\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.13: A RESTORE CODE STAYS SHORT ENOUGH TO PASTE. Since v15.00 the code carried every named pillager record, and a blank record exists for each one a raid ever names, so a long save made a code over 6,000 characters and check 11.03 went red. Only records that hold something travel now; a missing record is created blank when read. Check 15.13 makes a code over seventy blank records and one real one; it fails on v15.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
