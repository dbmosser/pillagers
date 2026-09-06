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

# FROM THE 2026-09-06 MENU AUDIT (P1): TAKE THE FREEBIE KIT emptied the
# packed backpack and the whole belt plan with no confirmation and no undo,
# and a new player is likely to press it after packing. His own note behind
# the emptying stands (anything already picked goes BACK to the stash, and a
# key pointing at something you are not carrying is the v5.72 fault), so the
# selection is not kept live; it is kept ASIDE, and USE MY OWN GEAR puts it
# back, minus anything no longer in the stash.
SubRx @'
    if(P.freeKit){ P.freeKit=0; saveProfile(); renderStage(); return; }
    // HIS NOTE: anything already picked goes BACK. P.kit is a selection out of the
    // stash rather than a move, so emptying it returns those items by itself; the
    // hotbar plan is cleared for the same reason, since a key pointing at something
    // you are not carrying is the exact fault v5.72 fixed.
    P.kit=[]; P.hotAssign={}; P._gunSlot=null;
'@ @'
    if(P.freeKit){
      P.freeKit=0;
      // v11.93, from the 2026-09-06 menu audit: what he had packed before he
      // took the free kit comes back, minus anything no longer in the stash.
      var _ks=P.kitSaved; P.kitSaved=null;
      if(_ks){
        var _pool=(P.stash||[]).slice(), _kit=[];
        for(var _ki=0;_ki<(_ks.kit||[]).length;_ki++){ var _kx=_pool.indexOf(_ks.kit[_ki]); if(_kx>=0){ _pool.splice(_kx,1); _kit.push(_ks.kit[_ki]); } }
        P.kit=_kit; P.hotAssign=_ks.hot||{}; P._gunSlot=_ks.gun||null;
      }
      saveProfile(); try{ renderHub(); }catch(_fh0){} renderStage(); return;
    }
    // HIS NOTE: anything already picked goes BACK. P.kit is a selection out of the
    // stash rather than a move, so emptying it returns those items by itself; the
    // hotbar plan is cleared for the same reason, since a key pointing at something
    // you are not carrying is the exact fault v5.72 fixed.
    // v11.93: kept aside first, so switching back to his own gear is not a wipe.
    P.kitSaved={kit:(P.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P.hotAssign||{})),gun:P._gunSlot||null};
    P.kit=[]; P.hotAssign={}; P._gunSlot=null;
'@
SubRx @'
    '<span>'+(on?'Taking the freebie kit. '+escHtml(freeKitText()):
'@ @'
    '<span>'+(on?'Taking the freebie kit. '+escHtml(freeKitText())+' Your own packing is kept for when you switch back.':
'@

# STAMPS.
SubRx @'
var VER='11.92';
'@ @'
var VER='11.93';
'@
SubRx @'
var WHATSNEW_VER='11.92';
'@ @'
var WHATSNEW_VER='11.93';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'TAKING THE FREEBIE KIT NO LONGER THROWS AWAY WHAT YOU PACKED. Switch back to your own gear and it is all still there.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.92:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.92 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.92:[^']*'",{ param($m) "now:'v11.93: from the 2026-09-06 menu audit, TAKE THE FREEBIE KIT wiped the packed backpack and the whole belt plan with no undo. The selection is kept aside on the profile (kitSaved) when the kit is taken and put back by USE MY OWN GEAR, minus anything no longer in the stash. Check 11.93 packs two items and a key, presses the real button twice, and requires the packing and the key back, then sells one item between presses and requires only the other back; fails on v11.92.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
