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

# HOLDING E AT THE PEDDLER KEEPS THE STALL OPEN. The open-stall block in raidKey closed the stall on any E, ESC, TAB, I or B
# without a repeat test, so a held E opened the stall (updatePlayer, first frame) and the first key repeat shut it again.
SubRx @'
  // The open stall owns the number row, so buying never also swaps your hotbar
  // slot out from under you.
  if(G&&!G.over&&G.trade){
    if(ev) ev.preventDefault();
    if(code==='Escape'||code==='KeyE'||code==='Tab'||code==='KeyI'||code==='KeyB'){ G.trade=null; G.pedLock=1; return; }
'@ @'
  // The open stall owns the number row, so buying never also swaps your hotbar
  // slot out from under you.
  if(G&&!G.over&&G.trade){
    if(ev) ev.preventDefault();
    // v15.82, trade audit finding: HOLDING E AT THE PEDDLER KEEPS THE STALL OPEN. The game trains him to hold E (every crate
    // search, HOLD E TO EXTRACT), and a held E opens the stall on its first frame in updatePlayer; then the first key repeat
    // the keyboard sends about half a second later (the listener hands raidKey e.repeat) landed here with no repeat test and
    // shut it, and pedLock kept it shut until the key was let go: the panel flashed open and vanished with nothing said. Every
    // other one-press toggle in raidKey ignores repeats (v15.49), and the Digit line right below already did. A repeat of any
    // of these keys now returns with no effect; a fresh E, ESC, TAB, I or B still closes the stall and holds the key. The
    // controller is unchanged: pad X sends fresh presses only. No number, no player text and no seeded draw moved.
    if(code==='Escape'||code==='KeyE'||code==='Tab'||code==='KeyI'||code==='KeyB'){ if(!repeat){ G.trade=null; G.pedLock=1; } return; }
'@
SubRx @'
var VER='15.81';
'@ @'
var VER='15.82';
'@

$pat = "(?m)^  now:'v15\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.82: HOLDING E AT THE PEDDLER KEEPS THE STALL OPEN. Holding E beside the Peddler opened the stall and the first key repeat about half a second later shut it again with nothing said, and it stayed shut until the key was let go. A key repeat of E, ESC, TAB, I or B at the open stall now does nothing, and a fresh press still closes it. Check 15.82 holds E at a Peddler beside him and sends the key repeat, direct and through the page; it fails on v15.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
