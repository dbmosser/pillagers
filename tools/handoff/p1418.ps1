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
    if(from==='weapons'){ say2('That gun is already yours. Drop it on gun 1 or gun 2.'); return; }
'@ @'
    // v14.18, Undercroft audit finding 5: AN ARMOURY GUN DROPPED ON THE STASH GOES INTO THE STASH. The armoury row drags with
    // the label 'rack' (v11.95), and this refusal was written for 'weapons', which nothing sends, so the drop fell through to
    // the kit-only line below and nothing happened, no line and no sound. The belt and the backpack already take a rack gun
    // into the stash as its item form (rackToStash); the stash now does the same, and a gun in his hands says why it stays.
    if(from==='rack'||from==='weapons'){
      var _sg=String(key).slice(4);
      if(P.equipped===_sg||P.equippedSec===_sg){ say2('That one goes up in your hands already.'); try{ sfx('clank'); }catch(e){} return; }
      var _sw=rackToStash(key); if(_sw){ say2(_sw); try{ sfx('clank'); }catch(e){} return; }
      try{ sfx('pick'); }catch(e){}
      say2((ITEMS[key]?ITEMS[key].name:key)+' is in the stash.');
      renderHub(); return;
    }
'@
SubRx @'
var VER='14.17';
'@ @'
var VER='14.18';
'@

$pat = "(?m)^  now:'v14\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.18: AN ARMOURY GUN DROPPED ON THE STASH GOES INTO THE STASH. The armoury row drags with the label rack and the stash grid only refused a label nothing sends, so the drop did nothing at all. A spare gun now leaves the armoury for the stash as its item form, the way the belt and the backpack already take it, and a gun in his hands says it goes up with him. Check 14.18 drops a spare gun and the gun in his hands on the stash grid; it fails on v14.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
