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
    if(_rt){ G.tel.notes.push({t:Math.round(elapsed()),txt:_rt}); _rn.value=''; }
'@ @'
    // v14.54, report audit finding 5: A NOTE IS AT MOST 400 CHARACTERS, as floor notes already were. Right after Copy report
    // the clipboard holds the whole report, and a paste into a note stored all of it inside the run and repeated it in every
    // later report, growing each time until saves hit the storage limit.
    if(_rt){ G.tel.notes.push({t:Math.round(elapsed()),txt:_rt.slice(0,400)}); _rn.value=''; }
'@
SubRx @'
      _ln=_ln?_ln.value.trim():'';
'@ @'
      _ln=_ln?_ln.value.trim().slice(0,400):'';   // v14.54: the same 400 character cap
'@
SubRx @'
  pendingRun.note=_ocn?_ocn.value.trim():'';
'@ @'
  pendingRun.note=_ocn?_ocn.value.trim().slice(0,400):'';   // v14.54: the same 400 character cap
'@
SubRx @'
var VER='14.53';
'@ @'
var VER='14.54';
'@

$pat = "(?m)^  now:'v14\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.54: A NOTE IS AT MOST 400 CHARACTERS. The outcome card note and in-raid notes had no limit, so pasting the report Copy report had just put on the clipboard stored the whole report inside the run and repeated it in every later report, growing toward the storage limit. Both are now cut at 400, as floor notes already were. Check 14.54 banks a long pause box note in a raid and corrects a run with a long outcome note; it fails on v14.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
