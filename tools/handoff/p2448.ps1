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

# RUN OVER HOLDS A MOMENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(ARCADE.role!=='host') return false;   // player 2 joins with A on its own pad; its keys go on to player 1 (netKeyFwd)
  var ty=String(e.type||''), cd=String(e.code||''), ky=String(e.key||'');
'@ @'
  if(ARCADE.role!=='host') return false;   // player 2 joins with A on its own pad; its keys go on to player 1 (netKeyFwd)
  var ty=String(e.type||''), cd=String(e.code||''), ky=String(e.key||'');
  if(arcadeOverGuard()&&ty!=='wheel'){ try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_og){} return true; }   // v24.48 (his #39): the RUN OVER card is read, not mashed through
'@

SubRx @'
// A new press on this window pad in the arcade attract.
function arcadePadAtt(anyNew,aNew){
  if(!ARCADE.on) return false;
'@ @'
// v24.48, HIS ORDER 2026-10-12 (his #39, full controller navigation, keyboard and mouse first): THE RUN OVER CARD HOLDS FOR A MOMENT.
// Any key, click or button on the attract drops a new run in, and that includes the presses still coming from the fight that just
// ended: a player mashing fire or roll as he died went straight into a fresh run and never saw RUN OVER or his score. For the first
// 1.5 seconds after a run ends the presses are swallowed (the initials card, when the run made the board, still takes its keys,
// and Ctrl+Shift+F10 still leaves); after that any press drops in as before.
var ARCADE_OVER_GUARD_MS=1500;
function arcadeOverGuard(){ return !!(ARCADE.on&&ARCADE.over&&ARCADE.over.at>0&&Date.now()-ARCADE.over.at<ARCADE_OVER_GUARD_MS&&!(G&&G.arcade&&!G.over)); }
// A new press on this window pad in the arcade attract.
function arcadePadAtt(anyNew,aNew){
  if(!ARCADE.on) return false;
  if(arcadeOverGuard()) return false;   // v24.48 (his #39): the RUN OVER card holds 1.5 s
'@

SubRx @'
var VER='24.47';
'@ @'
var VER='24.48';
'@

$pat = "(?m)^  now:'v24\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.48: The RUN OVER card ignores presses for a moment so mashing does not skip it. Check 24.48 fails on v24.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
