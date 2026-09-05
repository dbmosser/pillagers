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

# THE DIAL. furnGap 0 restores the old placement for the A/B.
SubRx @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15,doorClear:1,furnIDoor:1};
'@ @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15,doorClear:1,furnIDoor:1,furnGap:1};
'@

# A PIECE KEEPS A BODY'S WIDTH FROM EVERYTHING IT DOES NOT TOUCH. Building 74
# on THE COLD MILE, measured: a free standing piece at 7594,4903 landed between
# the ends of two alcove partitions, 8 units below one and 14 beside the other,
# and split the building in two for anything wider than 8. The repair pass
# never saw it because it floods a grid with no body in it. A piece flush
# against a wall is fine, gap nought; a piece overlapping one is as before; a
# piece that leaves a gap under 30 to any wall or piece in its building is not
# placed. No random number is drawn.
SubRx @'
        if(_fdrop2) continue;
      }
      out.push({x:fx4,y:fy4,w:fw2,h:fh2,d:d,ib:bid,furn:ft});
'@ @'
        if(_fdrop2) continue;
      }
      // v11.17: AND A BODY'S WIDTH FROM EVERYTHING IT DOES NOT TOUCH. Building
      // 74 on THE COLD MILE: a free standing piece landed between the ends of
      // two alcove partitions, 8 units below one and 14 beside the other, and
      // split the building in two for anything wider than 8; the repair pass
      // floods a grid with no body in it and never saw it. Flush is fine,
      // overlapping is as before, a gap under 30 to any wall or piece of this
      // building is not placed. No random number is drawn. furnGap 0 restores.
      if((CFG.furnGap===undefined?1:CFG.furnGap)){
        var _fg=false;
        for(var _wi=0;_wi<out.length;_wi++){
          var _ow=out[_wi];
          if(_ow.x+_ow.w<x-1||_ow.x>x+w+1||_ow.y+_ow.h<y-1||_ow.y>y+h+1) continue;
          var _gx=Math.max(0,_ow.x-(fx4+fw2),fx4-(_ow.x+_ow.w));
          var _gy=Math.max(0,_ow.y-(fy4+fh2),fy4-(_ow.y+_ow.h));
          var _gap=(_gx>0&&_gy>0)?Math.sqrt(_gx*_gx+_gy*_gy):Math.max(_gx,_gy);
          if(_gap>0.5&&_gap<30){ _fg=true; break; }
        }
        if(_fg) continue;
      }
      out.push({x:fx4,y:fy4,w:fw2,h:fh2,d:d,ib:bid,furn:ft});
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
