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

# WALLS, NOT OTHER PIECES. Measured with every neighbour counted: 136 pieces to
# 96 and 440 to 310, three in ten gone, and he asked for MORE furniture. What
# seals a room is a piece bridging to a wall or a partition end; a sliver
# between two pieces is the v10.40 niche, cosmetic. So the gap is asked against
# walls and partitions only.
SubRx @'
          var _ow=out[_wi];
          if(_ow.x+_ow.w<x-1||_ow.x>x+w+1||_ow.y+_ow.h<y-1||_ow.y>y+h+1) continue;
          var _gx=Math.max(0,_ow.x-(fx4+fw2),fx4-(_ow.x+_ow.w));
'@ @'
          var _ow=out[_wi];
          if(_ow.furn) continue;
          if(_ow.x+_ow.w<x-1||_ow.x>x+w+1||_ow.y+_ow.h<y-1||_ow.y>y+h+1) continue;
          var _gx=Math.max(0,_ow.x-(fx4+fw2),fx4-(_ow.x+_ow.w));
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
