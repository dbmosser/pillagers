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

# ROOM ON THE GUN KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    for(var gi=0;gi<GUNKEYS&&gi<slots.length;gi++){
      var gs=slots[gi];
      if(G.hotAssign[gi]===undefined&&gs&&gs.kind==='gun'&&!gs.assigned&&(gs.vacant||(gs.icon==='fists'&&!gs.inHand))){
'@ @'
    // v22.57, from the review of the four-gun belt (build 5): A GUN KEY THAT ONLY REPEATS A GUN HE PUT ON A LATER KEY IS FREE. A gun
    // in his hands always shows on a gun key too (v15.25, his note), so after he dragged the rifle from key 1 to key 6 to make room,
    // key 1 still showed the rifle and the next gun he picked up found no free gun key (GUN SLOTS FULL). A truly free gun key still
    // comes first; then a gun key whose gun one of his keys also shows takes it, and that gun stays on his key.
    var _abDup=function(ix,c){
      if(!(c&&(c.k==='gunA'||c.k==='gunB')&&!c.vacant&&c.icon&&c.icon!=='fists')) return false;
      for(var _aj=0;_aj<slots.length;_aj++) if(_aj!==ix&&slots[_aj]&&slots[_aj].assigned&&slots[_aj].equipped&&slots[_aj].icon===c.icon&&!!slots[_aj].inHand===!!c.inHand) return true;
      return false;
    };
    for(var _abP=0;_abP<2;_abP++)
    for(var gi=0;gi<GUNKEYS&&gi<slots.length;gi++){
      var gs=slots[gi];
      if(G.hotAssign[gi]===undefined&&gs&&gs.kind==='gun'&&!gs.assigned&&(_abP?_abDup(gi,gs):(gs.vacant||(gs.icon==='fists'&&!gs.inHand)))){
'@

SubRx @'
        G.hotAssign[gi]=key; G.hotAuto=G.hotAuto||{}; G.hotAuto[gi]=1;
'@ @'
        G.hotAssign[gi]=key; G.hotAuto=G.hotAuto||{}; G.hotAuto[gi]=1;
        if(_abP&&G.hot===gi) G.hot=gunCell();   // v22.57: the highlight never stays on a key that now shows a backpack gun
'@

SubRx @'
var VER='22.56';
'@ @'
var VER='22.57';
'@

$pat = "(?m)^  now:'v22\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.57: A gun key that only repeats a gun on a later key takes the next gun picked up. Check 22.57 fails on v22.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
