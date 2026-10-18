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

# DEMO HIDES CREDITS XP STASH AND BAG (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function topRightBottom(){
  var el=document.getElementById('topright'); if(!el) return 0;
'@ @'
// v28.xx (cw-hudDemoTR), HIS ANSWER Q55 (2026-10-18): "in the demo hide credits, XP, stash and bag." trDemo is true in the arcade demo (the menu flag or a demo raid).
function trDemo(){ return !!((typeof ARCADE==='object'&&ARCADE&&ARCADE.on)||(typeof G==='object'&&G&&G.arcade)); }
function topRightBottom(){
  var el=document.getElementById('topright'); if(!el) return 0;
  if(!el.innerHTML) return 0;   // v28.xx (cw-hudDemoTR): an empty corner readout takes no room
'@

SubRx @'
  if(s===_trLast) return;
'@ @'
  if(trDemo()) s='demo';   // v28.xx (cw-hudDemoTR), his Q55: nothing in the corner in the demo
  if(s===_trLast) return;
'@

SubRx @'
  el.innerHTML=c+' <small>CREDITS</small> '
'@ @'
  if(s==='demo'){ el.innerHTML=''; return; }
  el.innerHTML=c+' <small>CREDITS</small> '
'@

SubRx @'
var VER='30.50';
'@ @'
var VER='30.51';
'@

$pat = "(?m)^  now:'v30\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.51: The demo no longer shows credits, XP, stash and bag in the top right. Check 30.51 fails on v30.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
