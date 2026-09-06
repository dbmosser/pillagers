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

# FIRST TEN MINUTES AUDIT, 2026-09-06: the lift's FREEBIE KIT answer did not
# clear the tactical belt plan, while the identical button on the stash
# screen does. A friend who took the free kit at the lift landed with keys
# bound to items left in the stash and, because an assigned heal key
# replaces the derived Medical cell, two Bandages with no working key.
SubRx @'
  ASKALT=function(){
    P.freeKit=1; P.kitBeforeFree=null; saveProfile();
    try{ renderStage(); }catch(_e){}
    ascendNow();
  };
'@ @'
  ASKALT=function(){
    // v12.13: THE SAME AS THE STASH SCREEN'S FREEBIE BUTTON, which clears the
    // belt plan (a key pointing at something you are not carrying is the v5.72
    // fault). This one did not, so a friend who took the free kit here landed
    // with keys bound to items left in the stash and, because an assigned heal
    // key replaces the derived Medical cell, two Bandages with no key to use.
    P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{})),gun:P._gunSlot||null};   // kept aside for the restore, as the stash button will at v12.16 (nothing reads it before then)
    P.hotAssign={}; P._gunSlot=null;
    P.freeKit=1; P.kitBeforeFree=null; saveProfile();
    try{ renderStage(); }catch(_e){}
    ascendNow();
  };
'@

# STAMPS.
SubRx @'
var VER='12.12';
'@ @'
var VER='12.13';
'@
SubRx @'
var WHATSNEW_VER='12.12';
'@ @'
var WHATSNEW_VER='12.13';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'TAKING THE FREEBIE KIT AT THE LIFT CLEARS YOUR TACTICAL BELT PLAN, the same as the stash screen button, so no key points at something you left behind.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.12:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.12 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.12:[^']*'",{ param($m) "now:'v12.13: from the 2026-09-06 first-ten-minutes audit, the lift FREEBIE KIT answer left the tactical belt plan pointing at items in the stash while the stash screen button cleared it, so a free-kit run landed with dead keys and no Medical cell. The lift answer clears the plan now. Check 12.13 takes the free kit at the lift with a key bound to a stash item and requires the plan empty and a free-kit raid started; fails on v12.12.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
