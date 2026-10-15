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

# A MENU PRESS NEVER ACTS IN THE RAID AFTER CHANGE PAD BUTTONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!gp){ if(PAD.on) padRelease(); PAD.on=false; PAD.prev=[]; PAD.xWas=false; PAD.xDownAt=null; PAD.xSearched=false; PAD.mx=0; PAD.my=0; padBodyCls(); return; }   // v8.39; v17.00, co-op hunt 2026-09-28: a pad gap forgets the X press too, but not xAfterTrade, which still spends an X held from the stall
'@ @'
  // v27.69 (cloud-menus-pad-menu-press-spent), CLOUD HUNT 2026-10-15: a pad gap forgets the buttons a menu spent and the raid button numbering too
  if(!gp){ if(PAD.on) padRelease(); PAD.on=false; PAD.prev=[]; PAD.mSpent=null; PAD.prevMap=null; PAD.xWas=false; PAD.xDownAt=null; PAD.xSearched=false; PAD.mx=0; PAD.my=0; padBodyCls(); return; }   // v8.39; v17.00, co-op hunt 2026-09-28: a pad gap forgets the X press too, but not xAfterTrade, which still spends an X held from the stall
'@

SubRx @'
  var ax=gp.axes||[],bt=gp.buttons||[];
'@ @'
  var ax=gp.axes||[],bt=gp.buttons||[];
  // v27.69 (cloud-menus-pad-menu-press-spent), CLOUD HUNT 2026-10-15: PAD.prev is read by the physical button everywhere but the raid, which reads it by action while CHANGE PAD BUTTONS has buttons moved.
  // The raid hands it back in physical numbers here, so a menu never takes a button held from the raid as a new press (B bound to pause
  // opened the box and the next poll shut it again), and a button a menu spent stays spent only while it is held (0.35, past the resting travel of a worn trigger).
  if(PAD.prevMap){ var _pp=PAD.prev.slice(), _pm=PAD.prevMap; for(var _pi=0;_pi<_pm.length;_pi++) _pp[_pm[_pi]]=!!(PAD.prev[_pi]||(PAD.mSpent&&PAD.mSpent[_pm[_pi]])); PAD.prev=_pp; PAD.prevMap=null; }
  if(PAD.mSpent) for(var _mk=0;_mk<PAD.mSpent.length;_mk++) if(PAD.mSpent[_mk]&&!(bt[_mk]&&(bt[_mk].pressed||bt[_mk].value>0.35))) PAD.mSpent[_mk]=0;
'@

SubRx @'
  if(padMenu(pressed)){ padRelease(); return; }
'@ @'
  // v27.69 (cloud-menus-pad-menu-press-spent), CLOUD HUNT 2026-10-15: THE PRESS THAT SHUTS A MENU IS SPENT IN THE RAID WHATEVER CHANGE PAD BUTTONS PUT ON IT. padMenu stamps PAD.prev by the
  // physical button, the raid reads the logical one, so with fire moved onto A the A on RESUME RUN or ASCEND fired a real shot, B rolled and
  // MENU crouched. Every button held while a menu owns the pad is noted here; the raid ignores it until it is let go.
  if(padMenu(pressed)){ PAD.mSpent=[]; for(var _ms=0;_ms<bt.length;_ms++) if(pressed(_ms)) PAD.mSpent[_ms]=1; padRelease(); return; }
'@

SubRx @'
  bt=padLogical(bt);   // v26.xx (padbind): from here the raid reads the buttons as CHANGE PAD BUTTONS has them (action n is on the button it is bound to); the menus, the title and the Undercroft above read the pad as it is
'@ @'
  var _rawBt=bt; bt=padLogical(bt);   // v26.xx (padbind): from here the raid reads the buttons as CHANGE PAD BUTTONS has them (action n is on the button it is bound to); the menus, the title and the Undercroft above read the pad as it is
  // v27.69 (cloud-menus-pad-menu-press-spent), CLOUD HUNT 2026-10-15: with buttons moved (bt is then a new array) PAD.prev is read by action from here (handed back at the top of the next poll), and a moved
  // action whose button is still held from a menu reads as up until it is let go. The standard layout is untouched.
  if(bt!==_rawBt){ var _mm=padMapArr(), _pl=PAD.prev.slice(); for(var _mi=0;_mi<16;_mi++){ _pl[_mi]=!!PAD.prev[_mm[_mi]]; if(PAD.mSpent&&_mm[_mi]!==_mi&&PAD.mSpent[_mm[_mi]]&&_mi<bt.length) bt[_mi]={pressed:false,value:0}; } PAD.prev=_pl; PAD.prevMap=_mm; }
'@

SubRx @'
var VER='27.68';
'@ @'
var VER='27.69';
'@

$pat = "(?m)^  now:'v27\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.69: With your own controller buttons, the press that closes the pause box or ascends no longer fires, rolls or crouches in the raid. Check 27.69 fails on v27.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
