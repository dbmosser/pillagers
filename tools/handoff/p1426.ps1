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
  if(pbx&&pbx.classList.contains('on')) return pbx;
  var hb=document.getElementById('hub');
'@ @'
  if(pbx&&pbx.classList.contains('on')) return pbx;
  // v14.26, controller audit finding 7: THE TITLE SCREEN IS A PANEL TOO. It is a .screen, the floor is frozen under it and
  // the floor's pad taps return there, so with only a pad nothing on the title could be pressed, ENTER THE UNDERCROFT included.
  var ttl=document.getElementById('title');
  if(ttl&&ttl.classList.contains('on')) return ttl;
  var hb=document.getElementById('hub');
'@
SubRx @'
  if(!list.length) return true;
  // The remembered control may have been re-rendered out from under us.
'@ @'
  if(!list.length) return true;
  // v14.26: the title opens on ENTER THE UNDERCROFT, not on GO FULLSCREEN above it.
  if(md.id==='title'&&(!PAD.focus||!md.contains(PAD.focus))){ var _tsb=document.getElementById('titlestart'); if(_tsb&&list.indexOf(_tsb)>=0) padSetFocus(_tsb); }
  // The remembered control may have been re-rendered out from under us.
'@
SubRx @'
  if(md.id==='pausebox'){
'@ @'
  // v14.26: B on the title does nothing. The search for a way out below finds no button there and would strip the title's
  // .on without running what ENTER THE UNDERCROFT runs, leaving a blank screen.
  if(md.id==='title') tap(1);
  if(md.id==='pausebox'){
'@
SubRx @'
var VER='14.25';
'@ @'
var VER='14.26';
'@

$pat = "(?m)^  now:'v14\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.26: THE TITLE SCREEN WORKS ON A PAD. The title is a .screen and the floor is frozen under it, so with only a pad nothing on it could be pressed, ENTER THE UNDERCROFT included, and B would have stripped it to a blank screen. The pad now drives the title like a panel, starting on ENTER THE UNDERCROFT, and B does nothing there. Check 14.26 shows the title with a faked pad, then checks the focus and presses B; it fails on v14.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
