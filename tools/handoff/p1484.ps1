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
      if(ai2.use==='heal'&&dsl.k==='heal') dupe=true;
'@ @'
      // v14.84, belt audit finding 1: A HEAL ON A KEY BLANKS MEDICAL ONLY WHEN EVERY HEAL CARRIED IS ON A KEY. Medical is the one
      // cell that uses the heals he did not bind, so a Medkit on key 8 blanked it and the Bandages in the backpack could not be
      // used for the rest of the raid once the Medkit was spent.
      if(ai2.use==='heal'&&dsl.k==='heal'){ if(!unkeyedHeals()) dupe=true; }
'@
SubRx @'
function countHeals(){
'@ @'
function unkeyedHeals(){
  // v14.84: the heals in the backpack whose item is on no belt key.
  var n=0, keyed={};
  for(var s in (G.hotAssign||{})) keyed[G.hotAssign[s]]=1;
  for(var i=0;i<G.bag.length;i++){ var it=ITEMS[G.bag[i]]; if(it&&it.use==='heal'&&!keyed[G.bag[i]]) n++; }
  return n;
}
function countHeals(){
'@
SubRx @'
var VER='14.83';
'@ @'
var VER='14.84';
'@

$pat = "(?m)^  now:'v14\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.84: A HEAL ON A BELT KEY NO LONGER TAKES MEDICAL AWAY FROM THE OTHER HEALS. Any heal bound to a key blanked the Medical cell, the only cell that uses the heals he did not bind, so with a Medkit on key 8 the Bandages in the backpack could not be used once the Medkit was spent. Medical is now blanked only when every heal carried is on a key. Check 14.84 binds a Medkit with a Bandage carried; it fails on v14.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
