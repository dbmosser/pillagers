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
      if(it.use==='heal'||it.use==='throw'||it.use==='armor'||it.use==='stim'){
        var _lab=document.createElement('span');
'@ @'
      // v14.76, stash and trader audit finding 4: EVERY ITEM ON EVERY KEY, AS THE RIGHT-CLICK MENU HAS OFFERED SINCE v8.18. This
      // hover row kept the old rule, keys 3 to 9 and only for what heals, throws, plates or stims, so hovering a gun or a part
      // offered no key while right-click and the number keys put it on any key. planPut is the rule for all three.
      {
        var _lab=document.createElement('span');
'@
SubRx @'
        for(var _sq=2;_sq<HOTBAR_N;_sq++){
'@ @'
        for(var _sq=0;_sq<HOTBAR_N;_sq++){
'@
SubRx @'
var VER='14.75';
'@ @'
var VER='14.76';
'@

$pat = "(?m)^  now:'v14\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.76: THE STASH HOVER ROW OFFERS EVERY KEY FOR EVERY ITEM. The put on key buttons under a hovered stash item offered keys 3 to 9, and nothing at all for a gun or a part, while right-click and the number keys put any item on any key. The row now offers keys 1 to 9 for every item. Check 14.76 hovers a Bandage and a gun; it fails on v14.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
