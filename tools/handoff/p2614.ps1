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

# THE TEAM LAMP STAYS IN FRONT OF THE GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!_GB) gunHeld(x+leanX,ty,face,fl,st,coat,_BLD,_PC,ads,sprint,rl,muzzle);  } else {
'@ @'
    if(!_GB){
      gunHeld(x+leanX,ty,face,fl,st,coat,_BLD,_PC,ads,sprint,rl,muzzle);
      // v26.14 (nightfix5), found by the overnight regression run of 2026-10-13 (check 24.61, spr22): THE TEAM LAMP STAYS IN FRONT OF THE HELD GUN. Since the big held guns (v25.26) the
      // gun sprite is drawn over the left shoulder strap, so the team lamp hid under the stock facing east, south-east, south and west: half the compass. It is drawn again
      // after the gun, same place and size, so the side a body is on still reads from the strap. Cosmetic only.
      if(_PC&&!(OUTF&&OUTF.norig)&&(st.team==='ally'||st.team==='foe')&&typeof TEAMCOL!=='undefined'){
        wc.fillStyle=INK; wc.fillRect(_lmx-0.5,_lmy-0.5,2.8,2.8);
        wc.fillStyle=TEAMCOL[st.team]; wc.fillRect(_lmx,_lmy,1.8,1.8);
        wc.fillStyle='#ffffff'; wc.fillRect(_lmx+0.2,_lmy+0.2,0.6,0.6);
      }
    }
  } else {
'@

SubRx @'
var VER='26.13';
'@ @'
var VER='26.14';
'@

$pat = "(?m)^  now:'v26\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.14: The team lamp on the shoulder strap now shows in front of the gun at every angle. Check 26.14 fails on v26.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
