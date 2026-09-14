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
window.addEventListener('error',function(ev){
  var er=ev&&ev.error;
  if(!(ev&&ev.message)&&!er) return;
  var st=(er&&er.stack)?String(er.stack).split('\n').slice(0,2).join(' '):((ev&&ev.filename)?(ev.filename+':'+ev.lineno):'');
'@ @'
// v14.51, report audit finding 2: WHERE A CRASH HAPPENED SURVIVES A LONG MESSAGE. Chrome's stack starts with the message itself,
// so the first two lines were the message and the top frame, cut at 200 characters: a canvas error is about 120 characters
// before the frame, and the cut took the line and column, the only part that says where. The lines that carry a location
// are kept; a stack with none keeps its first two lines as before.
function crashWhere(stack){
  var L=String(stack||'').split('\n'), loc=L.filter(function(x){ return /:\d+:\d+/.test(x); });
  return (loc.length?loc:L).slice(0,2).join(' ');
}
window.addEventListener('error',function(ev){
  var er=ev&&ev.error;
  if(!(ev&&ev.message)&&!er) return;
  var st=(er&&er.stack)?crashWhere(er.stack):((ev&&ev.filename)?(ev.filename+':'+ev.lineno):'');
'@
SubRx @'
  var st=(r&&r.stack)?String(r.stack).split('\n').slice(0,2).join(' '):'';
'@ @'
  var st=(r&&r.stack)?crashWhere(r.stack):'';   // v14.51: the location lines, not the message
'@
SubRx @'
var VER='14.50';
'@ @'
var VER='14.51';
'@

$pat = "(?m)^  now:'v14\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.51: A CRASH NOTE KEEPS WHERE IT HAPPENED. The crash location was the first two stack lines cut at 200 characters, and in Chrome the first line is the message, so a long message cut off the line and column. The location lines are now kept instead. Check 14.51 raises an error with a long message through the real error listener; it fails on v14.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
