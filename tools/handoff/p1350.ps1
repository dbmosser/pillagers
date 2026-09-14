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

# FOUND BY THE 2026-09-14 CRASH SWEEP: every page load requests builds/index.json. The
# build picker fetches the local build archive at boot, and builds/ exists only where he
# serves the repo from his own machine, so on itch every load asked for a file that is
# never there and logged a missing-file error. It asks only on his machine now.
SubRx @'
function initBuildPicker(){
'@ @'
// v13.50: THE BUILD ARCHIVE IS ON HIS MACHINE ONLY. builds/ is served from the repo on
// localhost; the itch copy is one file, so a request for the archive there always failed.
function buildArchiveHost(){
  var h=(location&&location.hostname)||'';
  return h==='localhost'||h==='127.0.0.1';
}
function initBuildPicker(){
'@
SubRx @'
  if(!sel||!go) return;
  fetch('builds/index.json').then(function(r){ return r.json(); }).then(function(list){
'@ @'
  if(!sel||!go) return;
  if(!buildArchiveHost()){ sel.innerHTML='<option>no build archive on this host</option>'; go.disabled=true; return; }   // v13.50
  fetch('builds/index.json').then(function(r){ return r.json(); }).then(function(list){
'@
SubRx @'
var VER='13.49';
'@ @'
var VER='13.50';
'@

$pat = "(?m)^  now:'v13\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.50: THE GAME STOPS ASKING ITCH FOR A FILE THAT IS NEVER THERE. Found by the 2026-09-14 crash sweep: the build picker fetched builds/index.json on every page load, and the build archive exists only where he serves the repo on his own machine, so on itch every load requested a missing file and logged the error. buildArchiveHost now limits the request to localhost, and elsewhere the picker says there is no build archive on this host. Check 13.50 stubs the host test and fetch: off his machine the picker makes no request, on it the request is still made; it fails on v13.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
