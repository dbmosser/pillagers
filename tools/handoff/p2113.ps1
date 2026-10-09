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

# RANDOM FROM STASH GIVES TWO GUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(own.length){ if(rand) g=own[Math.floor(Math.random()*own.length)]; else { own.sort(function(a,b){ return (WTIER[b]||0)-(WTIER[a]||0); }); g=own[0]; } }
'@ @'
  if(own.length){
    if(rand){
      // v21.13, HIS ORDER (2026-10-08): "'random from stash' loadout should never start player with a scav pistol if i have guns
      // in the stash. give me 2 random stash guns always". It picked one gun at random from everything he owns, the Scav Pistol
      // included, and left the second slot as it was, so he could go up holding a Scav Pistol or carrying one on his back. Now
      // both slots are filled at random from his guns, two different kinds, and the Scav Pistol is never picked while he owns
      // any other gun; with only one other gun, it goes in his hands and the back slot stays empty.
      var _rp=own.filter(function(k){ return k!=='pistol'; }), _rs;
      if(!_rp.length) _rp=own.slice();
      g=_rp[Math.floor(Math.random()*_rp.length)];
      _rs=_rp.filter(function(k){ return k!==g; });
      P.equippedSec=_rs.length?_rs[Math.floor(Math.random()*_rs.length)]:'none';
    } else { own.sort(function(a,b){ return (WTIER[b]||0)-(WTIER[a]||0); }); g=own[0]; }
  }
'@

SubRx @'
var VER='21.12';
'@ @'
var VER='21.13';
'@

$pat = "(?m)^  now:'v21\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.13: RANDOM FROM STASH gives you two random guns from your stash, never the Scav Pistol while you own others. Check 21.13 fails on v21.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
