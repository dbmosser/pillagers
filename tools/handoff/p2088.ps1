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

# THE FLOOR HEADING STAYS OUT OF THE WINDOWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawHubHUD(ox,oy){
'@ @'
// v20.88, from the whole-game bug hunt of 2026-10-08 (V-A1): IS A WINDOW OPEN OVER THE FLOOR. Any window that is on counts, except
// the tuning and sim consoles, which openModal lets sit over whatever they tune.
function hubWinOn(){
  var m=document.querySelectorAll('.modal.on'), i;
  for(i=0;i<m.length;i++) if(m[i].id!=='tunemodal'&&m[i].id!=='simmodal') return true;
  return false;
}
function drawHubHUD(ox,oy){
'@

SubRx @'
  ctx.fillText('THE UNDERCROFT',16,28);
'@ @'
  // v20.88, from the whole-game bug hunt of 2026-10-08 (V-A1): THE FLOOR HEADING STAYS OUT OF A STATION WINDOW. A window is a
  // slightly see-through sheet with its frame 14 pixels in from the screen edge, and the floor kept painting this heading in the
  // corner behind it, so on the 4K screenshots the top half of THE UNDERCROFT showed above the frame line of the shop, Fashion and
  // the other windows, cut in half by it. It is not painted while a window is open and is back the frame it closes. The money
  // line under it sits behind the frame and is left as it was.
  if(!hubWinOn()) ctx.fillText('THE UNDERCROFT',16,28);
'@

SubRx @'
var VER='20.87';
'@ @'
var VER='20.88';
'@

$pat = "(?m)^  now:'v20\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.88: The Undercroft heading no longer pokes out above the top of the shop, Fashion and the other windows. Check 20.88 fails on v20.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
