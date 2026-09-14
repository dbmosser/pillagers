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

# THE KEY PROMPT AUDIT OF 2026-09-14, findings 2 to 7: on a controller six pieces of text
# named a keyboard key or a button that does not do what it says. One build, one theme:
# what a controller player reads matches the button that does it.
SubRx @'
  var gc=gunCell();
  return 'Press '+keyLabel('Digit'+(gc+1),String(gc+1))+' for your gun.';
'@ @'
  var gc=gunCell();
  if(padOn()) return 'LB or RB to your gun.';   // v13.52: no pad button reaches a digit; the bumpers walk the belt
  return 'Press '+keyLabel('Digit'+(gc+1),String(gc+1))+' for your gun.';
'@
SubRx @'
              Space:'B',Tab:'BACK',KeyP:'START',KeyZ:'D-LEFT',
'@ @'
              Space:'B',Tab:'BACK',KeyP:'MENU',KeyZ:'D-LEFT',
'@
SubRx @'
              ShiftLeft:'LS',ControlLeft:'RS',KeyM:'D-UP',KeyI:'BACK'};
'@ @'
              ShiftLeft:'LS',ControlLeft:'RS',KeyM:'D-UP',KeyI:'VIEW'};   // v13.52: the full pad list and the backpack say VIEW and MENU
'@
SubRx @'
  ['BACK','backpack'],['D-DOWN','medical'],
'@ @'
  ['VIEW','backpack'],['D-DOWN','revive'],
'@
SubRx @'
  ['D-UP','map'],['START','pause']
'@ @'
  ['D-UP','map'],['MENU','pause']
'@
SubRx @'
['D-DOWN','use medical']
'@ @'
['D-DOWN','revive when down']
'@
SubRx @'
    ctx.fillText('B / I  BACKPACK',W-16,by-LH(70));
'@ @'
    ctx.fillText(padOn()?'VIEW  BACKPACK':'B / I  BACKPACK',W-16,by-LH(70));   // v13.52: pad B is the dodge roll
'@
SubRx @'
'THE PEDDLER  [E] DEAL'
'@ @'
'THE PEDDLER  ['+keyLabel('KeyE','E')+'] DEAL'
'@
SubRx @'
ctx.fillText('HOLD E TO CALL FOR EXTRACTION',W/2,_exRow);
'@ @'
ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CALL FOR EXTRACTION',W/2,_exRow);
'@
SubRx @'
ctx.fillText('HOLD E TO CALL FOR EXTRACTION',W/2,_rowY);
'@ @'
ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CALL FOR EXTRACTION',W/2,_rowY);
'@
SubRx @'
      ctx.fillText(sl[sel].name+'   [FIRE] use    [V] signal',W/2,hy-LH(6));
'@ @'
      ctx.fillText(sl[sel].name+'   [FIRE] use'+(padOn()?'':'    [V] signal'),W/2,hy-LH(6));   // v13.52: no pad button reaches V
'@
SubRx @'
var VER='13.51';
'@ @'
var VER='13.52';
'@

$pat = "(?m)^  now:'v13\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.52: WHAT A CONTROLLER PLAYER READS MATCHES THE BUTTON. The key prompt audit of 2026-09-14, findings 2 to 7: the empty cell line said Press 1 for your gun, which no pad button reaches, and now says LB or RB; the short pad key list said BACK and START while the full list and the backpack say VIEW and MENU, and PADLABEL now agrees; D-DOWN was labelled medical, which it has not done since v11.27, and now reads revive; the HUD backpack cue named B, the dodge roll, and reads VIEW on a pad; the Peddler DEAL prompt and both HOLD TO CALL lines printed E and now name the pad button; and the belt caption hides V signal on a pad. Keyboard text is unchanged. Check 13.52 stubs padOn and requires the new wording, and that the keyboard wording still stands; it fails on v13.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
