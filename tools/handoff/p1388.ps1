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

# SEARCHING AND LOOT AUDIT OF 2026-09-14, finding 3: REVIVING THE SAME PILLAGER AGAIN PAID A SECOND
# COPY OF THE GUN IN HIS HANDS. A revive pays the gun in his bag, or failing that the best thing
# he carries, or failing that a copy of the gun in his hands, which he keeps holding. The first
# revive marks him paidRevive so his body does not pay that gun again (v9.10), but nothing on the
# revive itself read the mark: shoot him down again, pick him up again, and his hands paid
# another copy. Reviving is free, so it was an endless supply of his gun. The hands pay once.
SubRx @'
        else if(downRdr.wep&&downRdr.wep.id&&ITEMS['gun_'+downRdr.wep.id]) _rpk='gun_'+downRdr.wep.id;
'@ @'
        // v13.88, loot audit: once. He keeps holding it, so a second revive paid another copy.
        else if(!downRdr.paidRevive&&downRdr.wep&&downRdr.wep.id&&ITEMS['gun_'+downRdr.wep.id]) _rpk='gun_'+downRdr.wep.id;
'@
SubRx @'
var VER='13.87';
'@ @'
var VER='13.88';
'@

$pat = "(?m)^  now:'v13\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.88: A REVIVED PILLAGER PAYS HIS GUN ONCE. Searching and loot audit of 2026-09-14, finding 3: a revive with nothing in his bag pays a copy of the gun in his hands, which he keeps holding, and the paidRevive mark that stops his body paying it again was never read on the revive itself, so downing and reviving the same man again paid another copy every time. The hands now pay only when he has not paid a revive. Check 13.88 revives an empty-handed pillager holding an SMG twice and requires one SMG in the backpack, with the first revive paying it as the control; it fails on v13.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
