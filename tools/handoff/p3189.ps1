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

# X RELOADS IN A FIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||G.nearForge||(G.nearSeal&&!G.nearSeal.done)||(G.nearStray&&G.nearStray.found&&!G.nearStray.hostile)||_xm)?'KeyE':'KeyR';
'@ @'
PAD.xMode=padXMode(_xm); /* v28.xx (cw-cx-xfight): his 3.10 b: reload wins during a fight. */
'@

SubRx @'
function pollPad(){
'@ @'
// v28.xx (cw-cx-xfight): his 3.10 b: X stays reload/search; decide once on the press, with revives first.
function padXMode(mateDown){
  var p=G&&G.player;
  if(!G||!p) return 'KeyR';
  if(p.downed||mateDown||G.nearDown) return 'KeyE';
  if(inCombatNow()&&!p.hand&&p.wep&&p.ammo<p.wep.mag&&(rlHave(p)||p.reloading>0)) return 'KeyR';
  return (G.nearContainer||G.nearPad||G.nearDoor||G.nearPed||G.nearForge||(G.nearSeal&&!G.nearSeal.done)||(G.nearStray&&G.nearStray.found&&!G.nearStray.hostile))?'KeyE':'KeyR';
}
function pollPad(){
'@

SubRx @'
var VER='31.88';
'@ @'
var VER='31.89';
'@

$pat = "(?m)^  now:'v31\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.89: A fresh X press reloads in combat when rounds can be loaded. Revives still work. Check 31.89 fails on v31.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
