$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== v10.23 KEPT ITS OWN LIST OF THE STATION NAMES, and the rename turned it
# ==== into a SKIP, which is not a PASS: the one check that guards station names
# ==== running into each other stopped running on the build that moved them. It
# ==== asks the game for its own stations now, so the next rename cannot silence
# ==== it, and it names the two it needs by ID rather than by wording.
SubRx @'
     var names=['DISCOUNT FASHION DEPOT','DEV CHEAT BOX','THE STASH','SHOP, CRAFT, AND HIRE','THE LAST POUR','THE MAINFRAME','WIRT THE GAMBLER','SETTINGS','DEV BOX'];
     var got={};
     for(var i=0;i<tr.length;i++){ var d=tr[i]; if(names.indexOf(String(d.t))>=0) got[d.t]={x:d.x-d.w/2,y:d.y-d.px,w:d.w,h:d.px*1.15}; }
     if(!got['DISCOUNT FASHION DEPOT']) return 'SKIP: the Depot is not on the floor';
     if(!got['DEV CHEAT BOX']) return 'SKIP: the cheat box is not on this floor (it shows on localhost only)';
'@ @'
     // v10.93: ASK THE GAME. This list used to be typed out here, and the build
     // that renamed one station turned this check into a SKIP, which is not a
     // pass: the only guard against two names running into each other stopped
     // running on the build most likely to make them.
     var _HBn=__hub(), names=[], _lbl={};
     for(var _s=0;_s<_HBn.stations.length;_s++){ names.push(String(_HBn.stations[_s].label)); _lbl[_HBn.stations[_s].id]=String(_HBn.stations[_s].label); }
     var got={};
     for(var i=0;i<tr.length;i++){ var d=tr[i]; if(names.indexOf(String(d.t))>=0) got[d.t]={x:d.x-d.w/2,y:d.y-d.px,w:d.w,h:d.px*1.15}; }
     if(names.length<4) return 'SKIP: the Undercroft has almost no stations on it';
     if(!_lbl['mirror']||!got[_lbl['mirror']]) return 'SKIP: the racks station is not on the floor';
     if(!_lbl['cheat']||!got[_lbl['cheat']]) return 'SKIP: the cheat box is not on this floor (it shows on localhost only)';
'@
SubRx @'
     // THE FINDING. On v10.22 the Depot's name ran into the cheat box's.
'@ @'
     // THE FINDING. On v10.22 the racks station name ran into the cheat box's.
'@
SubRx @'
     // CONTROL: the Depot still opens from where it stands.
'@ @'
     // CONTROL: the racks station still opens from where it stands.
'@
SubRx @'
     if(!rr||rr.err||!(md&&md.classList.contains('on'))) bad.push('control: the Depot did not open');
'@ @'
     if(!rr||rr.err||!(md&&md.classList.contains('on'))) bad.push('control: the racks station did not open');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
