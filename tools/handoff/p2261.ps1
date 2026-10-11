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

# A GIFT TAKEN IS ALWAYS SHOWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=q.length-1;i>=0;i--){ q[i].T-=dt; if(!(q[i].T>0)) q.splice(i,1); }
'@ @'
  // v22.xx (tr4fixb): A ROW SAID WHILE THE STACK IS HIDDEN WAITS TO BE SEEN. The stack is not drawn while the backpack or the map is
  // open, but its rows ran out all the same. A gift is offered only from an open backpack, so the giver's GIVEN TO row was pushed
  // while it was hidden: a teammate who took the item within the 12 s offer left a row that lived 4 s unseen, and with the backpack
  // shut later the item was gone from it with nothing ever said. The rows now keep their time while the stack is hidden and show
  // when it closes. Still at most 4 rows.
  if(G.bagOpen||G.mapOpen) return;
  for(i=q.length-1;i>=0;i--){ q[i].T-=dt; if(!(q[i].T>0)) q.splice(i,1); }
'@

SubRx @'
var VER='22.60';
'@ @'
var VER='22.61';
'@

$pat = "(?m)^  now:'v22\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.61: A pickup row said while the backpack or map is open, such as GIVEN TO a teammate, now waits and shows when it closes. Check 22.61 fails on v22.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
