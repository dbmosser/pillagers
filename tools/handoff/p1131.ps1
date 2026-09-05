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

# THE STASH SAID "NOTHING IN THE STASH" UNDER A GUN. The ALL tab draws the
# owned guns as cells (the tab count says ALL 1 on a fresh profile) and the
# empty-grid guard exempted only the GUNS tab, so under ALL the message was
# appended straight after the Scav Pistol cell.
SubRx @'
  if(!shown.length&&sl&&!(P.stashTab==='gun'&&(P.weapons||[]).length)){
'@ @'
  // v11.31: ALL draws the owned guns too, so it is exempt on the same terms
  // as GUNS; a fresh profile read "ALL 1", one pistol cell, and "Nothing in
  // the stash" under it.
  if(!shown.length&&sl&&!((P.stashTab==='gun'||P.stashTab==='all')&&(P.weapons||[]).length)){
'@

# STAMPS.
SubRx @'
var VER='11.30';
'@ @'
var VER='11.31';
'@
SubRx @'
var WHATSNEW_VER='11.30';
'@ @'
var WHATSNEW_VER='11.31';
'@
SubRx @'
  'A BELT KEY TELLS YOU THE RIGHT KEY. Pressing a tactical belt key for a gun still in your backpack used to say "TAB to equip it"; TAB only opens the backpack. It now says TAB, then ENTER, which is what equips it.',
'@ @'
  'THE STASH NO LONGER SAYS IT IS EMPTY UNDER YOUR GUN. On a fresh save the ALL tab showed your Scav Pistol and, under it, "Nothing in the stash". The message only appears when there really is nothing to show.',
  'A BELT KEY TELLS YOU THE RIGHT KEY. Pressing a tactical belt key for a gun still in your backpack used to say "TAB to equip it"; TAB only opens the backpack. It now says TAB, then ENTER, which is what equips it.',
'@
SubRx @'
  now:'v11.30: a belt key for a gun still in the backpack said "TAB to equip it"; TAB opens the backpack and ENTER equips (v2.94, LEGEND). Reproduced by pressing the key: the message named the key that does nothing. It says TAB, then ENTER now. From the same read-only agent as v11.26 to v11.28; one finding a build, each pressed in the page first.',
'@ @'
  now:'v11.31: the stash on a fresh save said "Nothing in the stash. Ascend, pillage, extract." directly under the one Scav Pistol cell it had just drawn, because the ALL tab draws the owned guns like GUNS does but the empty-grid guard exempted GUNS alone. Reproduced on a fresh profile in memory: ALL 1, one cell, the message. The guard exempts ALL on the same terms. From the second bounded agent (Undercroft and stash), reproduced in the page first.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
