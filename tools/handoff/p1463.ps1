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
function bagStacks(){
'@ @'
// v14.63, backpack audit finding 5: A BELT KEY FOR THE GUN IN HIS HANDS DOES NOT HIDE A BACKPACK COPY. Every belt assignment
// claimed one backpack copy of its item, but a key naming a gun he is holding shows that gun in hand, not a copy from the
// backpack. With the SMG on key 5 and an SMG in hand, a second SMG looted into the backpack was claimed by that key: in
// neither the grid nor the belt, so it could not be dropped, equipped, given or sold. Such a key claims nothing.
function beltClaimsBag(k){
  if(!k) return false;
  if(k.indexOf('gun_')===0&&typeof G!=='undefined'&&G&&G.player){
    var _gk=k.slice(4), _pp=G.player;
    if((_pp.wep&&_pp.wep.id===_gk)||(_pp.sec&&_pp.sec.id===_gk)) return false;
  }
  return true;
}
function bagStacks(){
'@
SubRx @'
    if(_hk) _hbClaim[_hk]=(_hbClaim[_hk]||0)+1;
'@ @'
    if(_hk&&beltClaimsBag(_hk)) _hbClaim[_hk]=(_hbClaim[_hk]||0)+1;   // v14.63: not the gun in hand
'@
SubRx @'
  if(G&&G.hotAssign) for(var a in G.hotAssign){ var hk=G.hotAssign[a]; if(hk) cl[hk]=(cl[hk]||0)+1; }
'@ @'
  if(G&&G.hotAssign) for(var a in G.hotAssign){ var hk=G.hotAssign[a]; if(hk&&beltClaimsBag(hk)) cl[hk]=(cl[hk]||0)+1; }   // v14.63
'@
SubRx @'
  if(G.hotAssign) for(var _ck in G.hotAssign){ var _cv=G.hotAssign[_ck]; if(_cv) _clm[_cv]=(_clm[_cv]||0)+1; }
'@ @'
  if(G.hotAssign) for(var _ck in G.hotAssign){ var _cv=G.hotAssign[_ck]; if(_cv&&beltClaimsBag(_cv)) _clm[_cv]=(_clm[_cv]||0)+1; }   // v14.63
'@
SubRx @'
var VER='14.62';
'@ @'
var VER='14.63';
'@

$pat = "(?m)^  now:'v14\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.63: A SECOND COPY OF THE GUN IN HIS HANDS SHOWS IN THE BACKPACK. A belt key naming the gun he holds shows that gun in hand, but it still claimed a backpack copy of it, so a second one looted into the backpack was in neither the grid nor the belt and could not be dropped, equipped, given or sold. A belt key for a gun in hand now claims no backpack copy, in the backpack, its header and the stall. Check 14.63 carries a second copy of the gun in hand with a key bound to it; it fails on v14.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
