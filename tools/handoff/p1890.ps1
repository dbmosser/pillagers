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

# PICKING UP KEY 8 NO LONGER SWAPS HIS GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _bagGun=!!(_hs2&&_hs2.kind==='gun'&&_hs2.itemKey&&!_hs2.equipped);
'@ @'
// v18.90, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". The v17.18 rule, a press only picks the key up, now covers a key holding a gun that is already in his hands too: pressing key 8 to drag it swapped that gun up on the press, before he had dropped anything. The swap waits for the release and happens only when the release is a click.
        var _bagGun=!!(_hs2&&_hs2.kind==='gun'&&_hs2.itemKey);
'@

SubRx @'
if(_cg&&_cg.kind==='gun'&&_cg.itemKey===d.key&&!_cg.equipped) setHot(HC.i);
'@ @'
if(_cg&&_cg.kind==='gun'&&_cg.itemKey===d.key) setHot(HC.i);   // v18.90, his report (2026-10-07): a key on a gun in his hands too, since the press no longer brings it up
'@

SubRx @'
if(_cg2&&_cg2.kind==='gun'&&_cg2.itemKey===d.key&&!_cg2.equipped) setHot(d.fromHot);
'@ @'
if(_cg2&&_cg2.kind==='gun'&&_cg2.itemKey===d.key) setHot(d.fromHot);   // v18.90, his report (2026-10-07): a key on a gun in his hands too, since the press no longer brings it up
'@

SubRx @'
var VER='18.89';
'@ @'
var VER='18.90';
'@

$pat = "(?m)^  now:'v18\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.90: Pressing a belt key to drag it no longer swaps the gun in your hands. Check 18.90 fails on v18.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
