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

# THE SLIDE SEALED ROOMS. Measured by the corpus on the first cut: buildings 26
# and 51 on THE COLD MILE held floor nothing could reach, because a piece slid
# along its wall lands wherever the zone ends, and the interior partitions have
# doorways of their own that BDOORS has never heard of. A piece that is not
# placed cannot seal anything. So: a piece landing in a doorway zone is dropped.
SubRx @'
      // 10.5 units one side of it and 17.5 the other, and the crawler inside
      // never reached a player standing outside. The zone is the doorway grown
      // 40 units through the wall both ways and 12 along it. A piece landing in
      // it SLIDES along the door axis until it is clear, and is dropped if that
      // takes it out of the room. No random number is drawn either way, so every
      // roll after this lands where it did before and the seeded world does not
      // move. furnDoor 0 restores the old placement for the A/B.
      if((CFG.furnDoor===undefined?1:CFG.furnDoor)){
        var _fdrop=false;
        for(var _di=0;_di<BDOORS.length;_di++){
          var _dd=BDOORS[_di],_dh=_dd.w>=_dd.h;
          var _zx=_dh?_dd.x-12:_dd.x-40,_zy=_dh?_dd.y-40:_dd.y-12;
          var _zw=_dh?_dd.w+24:_dd.w+80,_zh=_dh?_dd.h+80:_dd.h+24;
          if(!(fx4<_zx+_zw&&fx4+fw2>_zx&&fy4<_zy+_zh&&fy4+fh2>_zy)) continue;
          if(_dh){ fx4=((fx4+fw2/2)<(_dd.x+_dd.w/2))?(_zx-fw2):(_zx+_zw); }
          else { fy4=((fy4+fh2/2)<(_dd.y+_dd.h/2))?(_zy-fh2):(_zy+_zh); }
          if(fx4<ix+1||fx4+fw2>ix+iw-1||fy4<iy+1||fy4+fh2>iy+ih-1){ _fdrop=true; break; }
        }
        if(_fdrop) continue;
      }
'@ @'
      // 10.5 units one side of it and 17.5 the other, and the crawler inside
      // never reached a player standing outside. The zone is the doorway grown
      // 40 units through the wall both ways and 12 along it. A piece landing in
      // it is NOT PLACED. The first cut slid the piece along its wall instead,
      // and the corpus caught it sealing two rooms on THE COLD MILE: the
      // interior partitions have doorways of their own that BDOORS has never
      // heard of, and a slid piece lands wherever the zone ends. A piece that is
      // not placed cannot seal anything. No random number is drawn, so every
      // roll after this lands where it did before and the seeded world does not
      // move. furnDoor 0 restores the old placement for the A/B.
      if((CFG.furnDoor===undefined?1:CFG.furnDoor)){
        var _fdrop=false;
        for(var _di=0;_di<BDOORS.length;_di++){
          var _dd=BDOORS[_di],_dh=_dd.w>=_dd.h;
          var _zx=_dh?_dd.x-12:_dd.x-40,_zy=_dh?_dd.y-40:_dd.y-12;
          var _zw=_dh?_dd.w+24:_dd.w+80,_zh=_dh?_dd.h+80:_dd.h+24;
          if(fx4<_zx+_zw&&fx4+fw2>_zx&&fy4<_zy+_zh&&fy4+fh2>_zy){ _fdrop=true; break; }
        }
        if(_fdrop) continue;
      }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
