$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ESC FROM THE PLAYER 2 WINDOW PAUSES PLAYER 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    try{ window.dispatchEvent(new KeyboardEvent((m.ty==='keyup')?'keyup':'keydown',{code:String(m.code||''),key:String(m.key||''),repeat:!!m.rep,shiftKey:!!m.sh,ctrlKey:!!m.ct,bubbles:true,cancelable:true})); }catch(_ke){}
'@ @'
    // v18.02, HIS REPORT (2026-10-03): PLAYER 1 COULD NOT PAUSE WITH ESC WHILE THE PLAYER 2 WINDOW WAS SELECTED. The handed key
    // was dispatched AT this window, so the two window listeners ran in the order they were registered: the main handler first,
    // which opened the pause box, then the Escape closer (a capture listener registered later), which found the box open and
    // shut it again in the same press. A real key starts at the page body, where capture listeners run first. The handed key
    // starts there too now, so it walks exactly the path a key pressed in this window walks.
    try{ (document.body||window).dispatchEvent(new KeyboardEvent((m.ty==='keyup')?'keyup':'keydown',{code:String(m.code||''),key:String(m.key||''),repeat:!!m.rep,shiftKey:!!m.sh,ctrlKey:!!m.ct,bubbles:true,cancelable:true})); }catch(_ke){}
'@

SubRx @'
var VER='18.01';
'@ @'
var VER='18.02';
'@

$pat = "(?m)^  now:'v18\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.02: ESC pauses player 1 even while the player 2 window is the one selected. Check 18.02 fails on v18.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
