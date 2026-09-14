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
        try{ localStorage.removeItem(slotKey(armed)); }catch(e){}
        armed=null; renderSlots();
'@ @'
        try{ localStorage.removeItem(slotKey(armed)); }catch(e){}
        // v14.41, title and saves audit finding 1: ERASE TAKES THE SAVE'S UNDO COPY WITH IT. Each save keeps its own restore
        // backup beside it (v14.06), and erasing removed only the profile, so a new character later made in that save showed
        // UNDO, and UNDO wrote the erased character back over the new one. The backup is erased too.
        try{ localStorage.removeItem(slotKey(armed)+':prerestore'); }catch(e){}
        armed=null; renderSlots();
'@
SubRx @'
var VER='14.40';
'@ @'
var VER='14.41';
'@

$pat = "(?m)^  now:'v14\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.41: ERASING A SAVE ERASES ITS UNDO COPY. Each save keeps a restore backup beside it, and ERASE removed only the profile, so a new character made in that save later showed UNDO and UNDO brought the erased character back over it. ERASE now removes the backup too. Check 14.41 erases a save that has a backup through the title screen buttons; it fails on v14.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
