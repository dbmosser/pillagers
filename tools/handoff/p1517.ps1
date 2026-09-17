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
      _rc.loot=_rt.loot; _rc.opened=false; _rc.openedAt=null;
      _rc.prog=0; _rc.pulled=0; _rc.best=_rt.best;
'@ @'
      _rc.loot=_rt.loot; _rc.opened=false; _rc.openedAt=null;
      _rc.prog=0; _rc.pulled=0; _rc.best=_rt.best;
      // v15.17, mainframe audit finding 2: A RESTOCKED CRATE OR LOCKER DROPS OFF THE DATA CORE KEY MARKS. A burned core lists
      // every container holding a locked room key once, at the ascent, and the sector map draws KEY on each one still shut.
      // The locked room guarantee can put that key in a crate or locker, and this restock rebuilds it in place from LOOT.crate
      // or LOOT.locker, which hold no key, and shuts it again. Nothing took it off the list, so the KEY mark came back on a
      // crate with no key in it and sent him across the map for nothing, even when he had left the key inside, because the
      // restock throws that loot away. It leaves the list now; G.intelKeys is unset on a raid with no core burned.
      if(G.intelKeys){ var _ikr=G.intelKeys.indexOf(_rc); if(_ikr>=0) G.intelKeys.splice(_ikr,1); }
'@
SubRx @'
var VER='15.16';
'@ @'
var VER='15.17';
'@

$pat = "(?m)^  now:'v15\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.17: A RESTOCKED CRATE OR LOCKER DROPS OFF THE DATA CORE KEY MARKS. A burned Data Core marks KEY on the sector map over every container holding a locked room key, and a crate or locker that was opened and later restocked came back marked KEY with no key inside, sending you across the map for nothing. A restock now takes that container off the key marks, and a container still holding its key keeps its mark. Check 15.17 burns a core at seed 4242, stages a key in a crate, a locker and a third container, restocks the opened crate and locker on one frame and draws the sector map; it fails on v15.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
