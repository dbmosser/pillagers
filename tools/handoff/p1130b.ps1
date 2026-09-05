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

# THE HINT WAS SAID AND THEN OVERWRITTEN IN THE SAME CALL. setHot says the
# backpack sentence, then unconditionally says the slot label ("Scav Pistol
# (field)  x1"), and the message line shows the last say. So no player ever
# read the sentence, wrong key or right key. The label now yields to the hint
# when there is one.
SubRx @'
  else if(s2.kind==='gun'&&!_inHands&&s2.itemKey)
    say(s2.name+' is in your backpack. TAB, then ENTER to equip it.');
  if(s2.kind==='throw'){
    var tk2=s2.k.split(':')[1],ix=THROWKEYS.indexOf(tk2);
    if(ix>=0) G.tsel=ix;
  }
  say(s2.name+(s2.count!==null&&s2.count!==undefined?'  x'+s2.count:''));
  blip('pick');
'@ @'
  else if(s2.kind==='gun'&&!_inHands&&s2.itemKey){
    // v11.30: this sentence was overwritten by the slot label two lines down
    // in the same call, so nobody ever read it; the label yields to it now.
    say(s2.name+' is in your backpack. TAB, then ENTER to equip it.');
    _hinted=true;
  }
  if(s2.kind==='throw'){
    var tk2=s2.k.split(':')[1],ix=THROWKEYS.indexOf(tk2);
    if(ix>=0) G.tsel=ix;
  }
  if(!_hinted) say(s2.name+(s2.count!==null&&s2.count!==undefined?'  x'+s2.count:''));
  blip('pick');
'@
SubRx @'
  var _inHands=(s2.k==='gunA'||s2.k==='gunB'||s2.equipped);
  // v8.67: not into an empty gun slot. The cell is always drawn now, so picking
'@ @'
  var _inHands=(s2.k==='gunA'||s2.k==='gunB'||s2.equipped), _hinted=false;
  // v8.67: not into an empty gun slot. The cell is always drawn now, so picking
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
