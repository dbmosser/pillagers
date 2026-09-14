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
    if(P.weapons.indexOf(T.v)<0){
      P.weapons.push(T.v);
      msg=WEAPONS[T.v].name+' in the armoury';
'@ @'
    if(P.weapons.indexOf(T.v)<0){
      P.weapons.push(T.v);
      // v14.29, progression audit finding 2: A REWARD GUN IS THE GUN IN HAND WHEN THERE IS NONE. With every armoury gun lost,
      // gun 1 is fists; the reward went into the armoury and gun 1 stayed on fists, so the next raid issued a loaner and the
      // rewarded gun stayed home. bankItem and the shop repair exactly this state, and the reward now does too.
      if(!P.equipped||P.equipped==='fists'||P.weapons.indexOf(P.equipped)<0) P.equipped=T.v;
      msg=WEAPONS[T.v].name+' in the armoury';
'@
SubRx @'
var VER='14.28';
'@ @'
var VER='14.29';
'@

$pat = "(?m)^  now:'v14\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.29: A REWARD GUN CLAIMED WITH NOTHING IN HAND BECOMES GUN 1. With every armoury gun lost gun 1 is fists, and a claimed gun reward went into the armoury while gun 1 stayed on fists, so the next raid issued a loaner and the reward stayed home. A claimed gun now takes gun 1 when gun 1 is fists or a gun he no longer owns, the same repair the shop and the recovered-gun path make. Check 14.29 claims two gun rewards from fists; it fails on v14.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
