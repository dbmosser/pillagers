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
function spendHeld(key,n){
  var free=Math.max(0,heldCount(key)-packedCount(key)), fromPacked=Math.max(0,n-free);
  if(fromPacked>0) unpackSome(key,fromPacked);
  for(var q=0;q<n;q++){ var ix=P.stash.indexOf(key); if(ix>=0) P.stash.splice(ix,1); }
  return fromPacked;
}
'@ @'
// v15.54, rack audit finding: WITH THE FREEBIE KIT TAKEN, BUILD A RACK NAMES THE PACKED PARTS IT USES. TAKE THE FREEBIE KIT
// sets his own packing aside in P.kitSaved and empties P.kit, so packedCount read 0 and every copy in the stash counted as
// loose. With 7 Circuit Boards, 3 of them packed before the freebie kit was taken, a rack spent 6 and said nothing of the
// backpack; the set-aside list still named 3 boards, so the lift question counted 3, and MY LOADOUT (or USE MY OWN GEAR)
// trimmed that list against the stash in freeKitRestore and took up 1. The copies set aside are packed too now: they count as
// packed, capped at what the stash still holds (the same test freeKitRestore makes), loose copies still go first (v13.59),
// and any set-aside copies still needed come off the set-aside list, with a set-aside belt key on that item let go once none
// are left, so the caller names them (v15.18) and the lift counts what goes up. The crafting bench and SLOT A DATA CORE spend
// through here as well. With no freebie kit taken nothing changes. No number, no player text and no seeded draw moved.
function spendHeld(key,n){
  // with the freebie kit taken his own packing is set aside in P.kitSaved and P.kit is empty; those copies are packed too
  var _ks=(P.freeKit&&P.kitSaved&&Array.isArray(P.kitSaved.kit))?P.kitSaved.kit:null, _aside=0, q;
  if(_ks) for(q=0;q<_ks.length;q++) if(_ks[q]===key) _aside++;
  _aside=Math.min(_aside,Math.max(0,heldCount(key)-packedCount(key)));   // only set-aside copies the stash still holds, the test freeKitRestore makes
  var free=Math.max(0,heldCount(key)-packedCount(key)-_aside), fromPacked=Math.max(0,n-free);
  if(fromPacked>0){
    if(_ks){
      for(q=0;q<fromPacked;q++){ var _kx=_ks.lastIndexOf(key); if(_kx>=0) _ks.splice(_kx,1); }
      if(_ks.indexOf(key)<0&&P.kitSaved.hot) for(var _hk in P.kitSaved.hot) if(P.kitSaved.hot[_hk]===key) delete P.kitSaved.hot[_hk];
    }
    else unpackSome(key,fromPacked);
  }
  for(q=0;q<n;q++){ var ix=P.stash.indexOf(key); if(ix>=0) P.stash.splice(ix,1); }
  return fromPacked;
}
'@
SubRx @'
var VER='15.53';
'@ @'
var VER='15.54';
'@

$pat = "(?m)^  now:'v15\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.54: WITH THE FREEBIE KIT TAKEN, BUILD A RACK NAMES THE PACKED PARTS IT USES. With Circuit Boards packed and the freebie kit taken, a rack counted every board as loose, used the packed ones without a word, and the lift question still counted them while MY LOADOUT took up fewer. A rack now treats the packing set aside as packed: loose parts still go first, set-aside parts it uses come off that list and are named in the rack line, and the lift counts what goes up. Check 15.54 builds a rack with packed boards, without and with the freebie kit taken, then asks the lift question; it fails on v15.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
