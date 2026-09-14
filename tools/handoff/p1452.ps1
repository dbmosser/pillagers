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
    if(P.autoDownload||!droppedThisSession||P.runs-savedAtRun>=2){
'@ @'
    // v14.52, report audit finding 3: A REPORT CORRECTED AFTER COPY REPORT IS SAVED AGAIN. Copy report saves the file and marks
    // this run saved; a tag or note chosen after it sends the report out again, and this line then saw zero runs since the
    // save, under the two it waits for, and marked it not saved: the banner read RUN REPORT NOT SAVED with 0 raids waiting,
    // and the file on disk was built before the note existed. The same run saved once already is saved again with the note.
    if(P.autoDownload||!droppedThisSession||P.runs-savedAtRun>=2||P.runs===savedAtRun){
'@
SubRx @'
var VER='14.51';
'@ @'
var VER='14.52';
'@

$pat = "(?m)^  now:'v14\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.52: A REPORT CORRECTED AFTER COPY REPORT IS SAVED AGAIN. A tag or note chosen after Copy report sent the report out again, and with no drop address the save rule saw zero raids since the last save and marked it not saved: a false RUN REPORT NOT SAVED banner, and the saved file missing the note. A run that was already saved is now saved again with the correction. Check 14.52 runs the save with the run just saved and with two runs waiting; it fails on v14.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
