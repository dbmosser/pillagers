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
    var gone=carriedGuns(G.player);
    // v10.72: and they go in the count and in the money. Both branches below
'@ @'
    var gone=carriedGuns(G.player), _gp0=G.player;
    // v14.80, gun audit finding 1: TWO OF THE SAME GUN ARE TWO GUNS LOST. carriedGuns keeps one of a same-model pair, the hand,
    // and only a gun that came out of the armoury comes off the list below, so a field copy in hand beside his own armoury copy
    // in gun 2 left the armoury copy on the list after the death. Which hand was up decided whether he kept a gun he died with.
    if(gone.length===1&&gone[0]===_gp0.wep&&_gp0.sec&&_gp0.sec.id===_gp0.wep.id&&!_gp0.secIssued) gone.push(_gp0.sec);
    // v10.72: and they go in the count and in the money. Both branches below
'@
SubRx @'
var VER='14.79';
'@ @'
var VER='14.80';
'@

$pat = "(?m)^  now:'v14\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.80: TWO OF THE SAME GUN ARE TWO GUNS LOST. With a field copy of a gun in hand and his own armoury copy in gun 2, a death kept the armoury copy, because only one of a same-model pair was counted and it was the one in hand. Both are now lost. Check 14.80 arms that pair and dies; it fails on v14.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
