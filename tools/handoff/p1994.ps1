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

# THE PAUSE BOX FRAME IS WIDE ENOUGH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .pausebox::before{ inset:50% auto auto 50%; width:780px; height:min(var(--pbh,400px),calc(100% - 28px));
'@ @'
  .pausebox::before{ inset:50% auto auto 50%; width:min(var(--pbw,780px),calc(100% - 28px)); height:min(var(--pbh,400px),calc(100% - 28px));
'@

SubRx @'
  var b=document.getElementById('pausebox'), i, c, t=1e9, bo=-1e9;
'@ @'
  var b=document.getElementById('pausebox'), i, c, t=1e9, bo=-1e9, wd=0;
'@

SubRx @'
  for(i=0;i<b.children.length;i++){ c=b.children[i]; if(c.offsetHeight>0){ t=Math.min(t,c.offsetTop); bo=Math.max(bo,c.offsetTop+c.offsetHeight); } }
'@ @'
  for(i=0;i<b.children.length;i++){ c=b.children[i]; if(c.offsetHeight>0){ t=Math.min(t,c.offsetTop); bo=Math.max(bo,c.offsetTop+c.offsetHeight); wd=Math.max(wd,c.offsetWidth); } }
'@

SubRx @'
  b.style.setProperty('--pbh',Math.max(400,Math.ceil(bo-t)+64)+'px');
'@ @'
  b.style.setProperty('--pbh',Math.max(400,Math.ceil(bo-t)+64)+'px');
  b.style.setProperty('--pbw',Math.max(780,Math.ceil(wd)+96)+'px');   // v19.94, seen on the 4K floor pause screenshot (2026-10-08): the floor's three buttons all but touched the frame sides
'@

SubRx @'
var VER='19.93';
'@ @'
var VER='19.94';
'@

$pat = "(?m)^  now:'v19\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.94: The pause box frame leaves room around its buttons in the Undercroft. Check 19.94 fails on v19.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
