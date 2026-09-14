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
      if(_ce&&_ce.msg===msg&&_ce.kind===kind&&(now-_ce.t)<CRASH_SAME_MS){ hit=_ce; break; }
'@ @'
      // v14.49, report audit finding 1: A REPEAT IS THE SAME CRASH EVEN WHEN A NUMBER IN IT CHANGES. Chrome names the key it
      // failed to read, so a grid read out of range reads '37', then '38', as things move: never an exact match, a new entry
      // every frame, a profile save every frame, and every earlier crash pushed out within twelve frames. Digits are ignored
      // when matching; the first message is kept as it was.
      if(_ce&&_ce.kind===kind&&(now-_ce.t)<CRASH_SAME_MS&&String(_ce.msg).replace(/\d+/g,'#')===msg.replace(/\d+/g,'#')){ hit=_ce; break; }
'@
SubRx @'
    if(!hit||!(noteCrash.savedAt>0)||(now-noteCrash.savedAt)>=CRASH_SAME_MS){ noteCrash.savedAt=now; try{ saveProfile(); }catch(_sp){} }
'@ @'
    // v14.49: and a new entry saves at most once a second, so a burst of different errors cannot save every frame either.
    if(!(noteCrash.savedAt>0)||(now-noteCrash.savedAt)>=(hit?CRASH_SAME_MS:1000)){ noteCrash.savedAt=now; try{ saveProfile(); }catch(_sp){} }
'@
SubRx @'
var VER='14.48';
'@ @'
var VER='14.49';
'@

$pat = "(?m)^  now:'v14\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.49: A CRASH REPEATING EVERY FRAME IS ONE ENTRY, NOT TWELVE. An error whose message carries a changing number, such as the key a failed read names, never matched the entry before it, so every frame added a crash, saved the whole profile and pushed the real first crash out of the list. Repeats now match with the numbers ignored, and a new entry saves at most once a second. Check 14.49 reports ten frames of one error with a changing key and one different error; it fails on v14.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
