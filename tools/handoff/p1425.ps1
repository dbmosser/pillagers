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
          G.hotAssign=G.hotAssign||{};
          if(d.fromHot!==undefined&&d.fromHot!==_H.i) delete G.hotAssign[d.fromHot];
          G.hotAssign[_H.i]=d.key;
'@ @'
          G.hotAssign=G.hotAssign||{};
          // v14.25, Undercroft audit finding 4: ONE ITEM, ONE KEY, IN THE UNDERCROFT BACKPACK TOO. This drop only let go of the
          // key the item was dragged from. It never took the same item off its other keys, so dragging one Medkit to key 4
          // and another to key 5 put Medkit on both; and dragging key 3 onto a filled key 4 deleted what key 4 held instead of
          // swapping it back onto key 3. The raid drop has done both since v8.04, and this is the same rule.
          var _hPrev=G.hotAssign[_H.i];
          if(d.fromHot!==_H.i){
            for(var _hk in G.hotAssign) if(G.hotAssign[_hk]===d.key) delete G.hotAssign[_hk];
            if(d.fromHot!==undefined) delete G.hotAssign[d.fromHot];
            if(d.fromHot!==undefined&&_hPrev&&_hPrev!==d.key) G.hotAssign[d.fromHot]=_hPrev;
          }
          G.hotAssign[_H.i]=d.key;
'@
SubRx @'
var VER='14.24';
'@ @'
var VER='14.25';
'@

$pat = "(?m)^  now:'v14\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.25: ONE ITEM, ONE KEY, IN THE UNDERCROFT BACKPACK TOO. A drag onto the tactical belt from the Undercroft backpack let go only of the key it came from, so the same Medkit could sit on two keys, and a key dragged onto a filled key deleted what that key held. It now follows the raid rule: the item leaves its other keys, and a displaced item swaps back onto the key the drag came from. Check 14.25 releases a drag over two staged belt cells through the real mouseup; it fails on v14.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
