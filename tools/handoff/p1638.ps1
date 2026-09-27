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

# YOU ARE HOSTING (his note: the host screen clearly says you are hosting, do not quit).

SubRx @'
function netUpShown(g){ return !!g&&g.n>0&&g.age<NET_HUB_STALE&&g.seat!==NET.seat&&netSeatName(g.seat)!==null&&!!NET.upSeed&&g.sd===(NET.upSeed>>>0); }
'@ @'
function netUpShown(g){ return !!g&&g.n>0&&g.age<NET_HUB_STALE&&g.seat!==NET.seat&&netSeatName(g.seat)!==null&&!!NET.upSeed&&g.sd===(NET.upSeed>>>0); }
// v16.38, HIS NOTE: the host screen should clearly say You are hosting, do not quit. Is this window hosting a raid its party is in?
// Then the pause box says so, and closing the window asks first (the browser's own leave page question).
function netHostHolds(){
  return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&netInCount()>0&&NET.upSeed&&typeof G!=='undefined'&&G&&!G.sim&&(!G.over||G===NET.specG));
}
window.addEventListener('beforeunload',function(e){ if(netHostHolds()){ e.preventDefault(); e.returnValue=''; return ''; } });
'@

SubRx @'
  <div id="pausebleed" style="display:none;font-size:13.5px;color:var(--rust);margin-top:8px;text-align:center;max-width:620px;line-height:1.7">YOU ARE DOWNED.  You can extract while downed</div>
'@ @'
  <div id="pausebleed" style="display:none;font-size:13.5px;color:var(--rust);margin-top:8px;text-align:center;max-width:620px;line-height:1.7">YOU ARE DOWNED.  You can extract while downed</div>
  <div id="pausehost" style="display:none;font-size:13.5px;color:var(--amber);margin-top:8px;text-align:center;max-width:620px;line-height:1.7">YOU ARE HOSTING. Closing this window or ending the party ends the raid for your whole party.</div>
'@

SubRx @'
    if(_bl) _bl.style.display=(_inRaid&&_downNow)?'':'none';
'@ @'
    if(_bl) _bl.style.display=(_inRaid&&_downNow)?'':'none';
    var _hw=document.getElementById('pausehost'); if(_hw) _hw.style.display=netHostHolds()?'':'none';   // v16.38: the host is told what quitting costs the party
'@

SubRx @'
var VER='16.37';
'@ @'
var VER='16.38';
'@

$pat = "(?m)^  now:'v16\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.38: YOU ARE HOSTING. His note: the host screen should clearly say you are hosting, do not quit. With a party up top on the host raid, the host pause box now reads YOU ARE HOSTING. Closing this window or ending the party ends the raid for your whole party, and closing the host window asks first. Abandoning still makes the host spectate (his ruling of 2026-09-26). Check 16.38 fails on v16.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
