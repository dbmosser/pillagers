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

# DOWNED AND EXTRACTION AUDIT OF 2026-09-14, finding 1: A FOUND COPY OF A GUN YOU ALREADY OWN
# VANISHED WHEN YOU EXTRACTED HOLDING IT. The extraction added each gun in your hands to the
# armoury only when its id was new, and did nothing otherwise. The same gun carried in the
# backpack goes to the stash as a duplicate (bankItem), and a death bills it as lost, but held
# in the hand it was simply dropped. The common case: you carry your armoury carbine, a better
# carbine auto-equips, yours goes into the backpack, and at the extraction the backpack puts
# yours back and the found one disappears. Two identical guns in both hands lost one as well.
# Each hand is now banked on its own, by where its gun came from: a new id to the armoury, and
# a second copy that did not come out of your armoury to the stash. Your own armoury gun is
# still never copied.
SubRx @'
    var kept=carriedGuns(G.player);
    for(i=0;i<kept.length;i++){
      // v6.68, his note: no line about it. The gun is still kept, silently.
      if(P.weapons.indexOf(kept[i].id)<0) P.weapons.push(kept[i].id);
    }
'@ @'
    var kept=carriedGuns(G.player);
    // v13.74, downed and extraction audit: each hand on its own, by where its gun came from. A
    // new id goes to the armoury; a second copy that did not come out of your armoury goes to
    // the stash, as the same gun carried in the backpack does; your own armoury gun is never
    // copied. v6.68, his note: no line about it. The gun is still kept, silently.
    var _kp=G.player, _ks=[[_kp.wep,_kp.wepIssued,_kp.wepFromArmory],[_kp.sec,_kp.secIssued,_kp.secFromArmory]];
    for(i=0;i<_ks.length;i++){
      var _kw=_ks[i][0];
      if(!_kw||_kw.id==='fists'||_ks[i][1]) continue;
      if(P.weapons.indexOf(_kw.id)<0) P.weapons.push(_kw.id);
      else if(!_ks[i][2]&&ITEMS['gun_'+_kw.id]) P.stash.push('gun_'+_kw.id);
    }
'@
SubRx @'
var VER='13.73';
'@ @'
var VER='13.74';
'@

$pat = "(?m)^  now:'v13\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.74: A SECOND COPY OF A GUN YOU OWN IS KEPT WHEN YOU EXTRACT HOLDING IT. Downed and extraction audit of 2026-09-14, finding 1: the extraction added a gun in your hands to the armoury only when its id was new and otherwise dropped it, while the same gun in the backpack went to the stash, so a found carbine that auto-equipped over your own vanished at the extraction. Each hand is banked on its own by where its gun came from: a new id to the armoury, a second copy not from your armoury to the stash, your own armoury gun never copied. Check 13.74 extracts holding a found copy of an owned gun and requires one more in the stash, with the backpack copy and the armoury gun as the two controls; it fails on v13.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
