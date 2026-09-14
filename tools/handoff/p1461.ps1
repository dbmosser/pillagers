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
          G.drag={key:_dk,fromHot:_HC2.i};
'@ @'
          G.drag={key:_dk,fromHot:_HC2.i,px:mouse.x,py:mouse.y};   // v14.61: the press point, as the hand gun drag keeps (v11.97)
'@
SubRx @'
    if(!_onBelt&&d&&d.fromHot!==undefined&&G.hotAssign&&G.hotAssign[d.fromHot]!==undefined){
'@ @'
    // v14.61, backpack audit finding 6: A CLICK THAT SLIPS OFF A BELT KEY DOES NOT UNBIND IT. Every press on a belt item starts
    // a drag, and this took any release off the belt as taking the item off its key: a click on key 5 to select the Medkit,
    // with the mouse flicked up to aim before letting go, said "Medkit off slot 5" and saved the plan without it. A drag that
    // has moved less than 24 units from its press point is a click, the same threshold the hand gun drag uses.
    var _dMoved=!(d&&d.px!==undefined&&Math.sqrt((mouse.x-d.px)*(mouse.x-d.px)+(mouse.y-d.py)*(mouse.y-d.py))<=24);
    if(!_onBelt&&_dMoved&&d&&d.fromHot!==undefined&&G.hotAssign&&G.hotAssign[d.fromHot]!==undefined){
'@
SubRx @'
var VER='14.60';
'@ @'
var VER='14.61';
'@

$pat = "(?m)^  now:'v14\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.61: A CLICK THAT SLIPS OFF A BELT KEY DOES NOT UNBIND IT. A press on a belt item starts a drag, and any release off the belt took the item off its key and saved, so clicking a key and flicking the mouse up to aim unbound it. A belt drag now has to move more than 24 units before a release off the belt unbinds, as the hand gun drag already does. Check 14.61 releases a belt drag near and far from its press point; it fails on v14.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
