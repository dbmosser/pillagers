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

# A CONTROLLER TAKES A TRADE OFFER WITH A WINDOW OPEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padMenu(pressed){
  var md=padOpenModal();
'@ @'
function padMenu(pressed){
  var md=padOpenModal();
  // v18.19, HIS NOTE (2026-10-03, "still not clear how trading works"): Y TAKES A TRADE OFFER WITH A WINDOW OPEN TOO. A panel on
  // screen owns the pad (below), so with the Stash screen or the shop open, which is where a player is when an offer arrives in
  // the Undercroft, the Y that takes an offer on the floor never ran. Read here first, on its own edge (padMenu never taps Y),
  // so a controller player can accept wherever he is. Nothing else about the panel's pad changes.
  var _yNow=!!pressed(3);
  if(md&&_yNow&&!PAD.yMenuWas&&typeof netHubGiftKey==='function'&&typeof NET==='object'&&NET&&NET.hg&&NET.hg.in&&!NET.hg.in.yes){ try{ netHubGiftKey(); }catch(_yg){} }
  PAD.yMenuWas=_yNow;
'@

SubRx @'
var VER='18.18';
'@ @'
var VER='18.19';
'@

$pat = "(?m)^  now:'v18\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.19: A controller player can take a trade offer with the stash or a shop open, not only on the floor. Check 18.19 fails on v18.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
