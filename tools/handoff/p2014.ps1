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

# A CROUCH DOES NOT THROW THE CHEST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
_JG=(_BLD==='curved')?bodyJiggle(st.own,ty-y):JIG0;
'@ @'
_JG=(_BLD==='curved')?bodyJiggle(st.own,ty-y-lift):JIG0;
'@

SubRx @'
  J.t=now; v=(ty-J.py)/dt; a=v-J.pv; J.py=ty; J.pv=v;
'@ @'
  // v20.14, code review (2026-10-08): a crouch dropped the body 5 units in one frame, read as a 300 a second lurch that threw the
  // chest stop to stop. The crouch is no longer fed in (drawOp passes the bob only), and the speed read is capped at 60, well over
  // a sprinting bob (about 23), so one odd frame cannot throw it.
  J.t=now; v=(ty-J.py)/dt; if(v>60) v=60; else if(v<-60) v=-60; a=v-J.pv; J.py=ty; J.pv=v;
'@

SubRx @'
var VER='20.13';
'@ @'
var VER='20.14';
'@

$pat = "(?m)^  now:'v20\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.14: Crouching no longer jolts a Curved body. Check 20.14 fails on v20.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
