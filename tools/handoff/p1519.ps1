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
          if(e.mgoal&&(e.mgoal.opened||dist(e,e.mgoal)>280)){ e.mgoal=null; e.mlootT=0; }
          if(!e.mgoal){
'@ @'
          // v15.19, hire audit finding: YOUR HIRE TAKES THE CRATE YOU ARE SEARCHING. Under FOLLOW, the default order, he took
          // any unopened crate within 160 of him and 420 of you: he walked over, and after two seconds marked it opened and
          // copied everything still inside into his own pack. Staged pulls take the worst first, so a crate you were holding
          // X on gave him its best items, your search bar vanished with no word, and his pack cannot be searched (v6.72).
          // Only your search adds to the prog of a crate, so progress on a crate means it is yours, and SPEC 7.4 keeps that
          // progress waiting for you. He now lets go of a crate the moment you start on it.
          if(e.mgoal&&(e.mgoal.opened||(e.mgoal.prog||0)>0||dist(e,e.mgoal)>280)){ e.mgoal=null; e.mlootT=0; }
          if(!e.mgoal){
'@
SubRx @'
              var _CT=G.containers[_mc];
              if(_CT.opened||_CT.locked||_CT.mine) continue;
'@ @'
              var _CT=G.containers[_mc];
              // v15.19, hire audit finding: AND HE DOES NOT PICK A CRATE YOU STARTED. A crate you searched part way and walked
              // away from keeps its progress for you (SPEC 7.4), and this pick took it the same way as one under your hands.
              if(_CT.opened||_CT.locked||_CT.mine||(_CT.prog||0)>0) continue;
'@
SubRx @'
var VER='15.18';
'@ @'
var VER='15.19';
'@

$pat = "(?m)^  now:'v15\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.19: YOUR HIRE TAKES THE CRATE YOU ARE SEARCHING. Under FOLLOW, the default order, your hire took any unopened crate near him, so while you held X on one he marked it opened after two seconds and kept everything still inside, the best items your search had not reached yet, and your search bar vanished. He now leaves any crate with search progress on it, the one you are searching and one you started and walked away from. Check 15.19 stands him beside a part searched crate, before and after he picked it, and beside an untouched crate he still loots; it fails on v15.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
