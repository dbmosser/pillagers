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
  if(G.trade&&!G.over){
    var _pn=((G.trade.stock&&G.trade.stock.length)||0)+1;
'@ @'
  if(G.trade&&!G.over){
    // v14.20, controller audit finding 2: THE PAD LETS GO WHILE THE STALL IS OPEN. This branch returned before the raid
    // branch could release anything, so A held when the stall opened left the fire flag, the aim and any held key on for
    // as long as the stall stayed open: the fire and cook code runs before the stall's own early return in updatePlayer,
    // so an automatic gun kept shooting and reloading through the reserve behind the panel, and a frag cooked off in his
    // hand. padRelease clears only what the pad set, and leaves PAD.prev alone, so the rows below still read presses.
    padRelease();
    var _pn=((G.trade.stock&&G.trade.stock.length)||0)+1;
'@
SubRx @'
var VER='14.19';
'@ @'
var VER='14.20';
'@

$pat = "(?m)^  now:'v14\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.20: THE PAD LETS GO WHILE THE STALL IS OPEN. The stall branch of the pad poll returned before anything was released, so A held when the stall opened kept the fire flag and the aim on behind the panel, and the fire and cook code runs before the stall returns: an automatic gun shot and reloaded through the reserve, and a frag cooked off in his hand. The stall branch now lets go of what the pad holds first. Check 14.20 holds A from the raid into an open stall with a faked pad; it fails on v14.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
