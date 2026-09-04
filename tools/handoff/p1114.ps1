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

# 1. THE DIAL. furnDoor 0 restores the old placement for the A/B.
SubRx @'
bldgRuin:0.09,touchSees:1,winWalk:1};
'@ @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1};
'@

# 2. NEVER IN A DOORWAY.
SubRx @'
      out.push({x:fx4,y:fy4,w:fw2,h:fh2,d:d,ib:bid,furn:ft});
'@ @'
      // v11.14: NEVER IN A DOORWAY. Measured on v11.13 at seed 4242: 11 of 37
      // doorways on COLD STORAGE and 35 of 151 on THE COLD MILE had a piece of
      // furniture leaving under 30 units of clear run for a body that needs 30,
      // so the route went through the door and the body could not follow it.
      // Building 8 on COLD STORAGE: a 36 by 26 piece inside a 64 unit doorway,
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
      out.push({x:fx4,y:fy4,w:fw2,h:fh2,d:d,ib:bid,furn:ft});
'@

# 3. VERSION STAMPS, both of them.
SubRx @'
var VER='11.13';
'@ @'
var VER='11.14';
'@
SubRx @'
var WHATSNEW_VER='11.13';
'@ @'
var WHATSNEW_VER='11.14';
'@
SubRx @'
  'THE GHOST MASK AND THE SPARTAN HELMET ARE YOURS ALONE.
'@ @'
  'NOTHING IS PARKED IN A DOORWAY ANY MORE. About one doorway in four had a piece of furniture inside the gap, leaving too little room for anything to get through, so the machines inside could plan a way out and never walk it. Furniture now keeps clear of every doorway.',
  'THE GHOST MASK AND THE SPARTAN HELMET ARE YOURS ALONE.
'@

# 4. THE WATCHDOG.
SubRx @'
  now:'v11.13: his ruling on the crowd. The ghost mask and the Spartan helmet come off the Undercroft crowd and stay on his rack; everything else the crowd wears is unchanged. Measured before: 182 masks and 172 helmets in 2,000 rolls, so on an eight man floor one of the two was usually in the room. Next: the furniture that plugs doorways and seals machines inside buildings.',
'@ @'
  now:'v11.14: no piece of furniture sits in a doorway. Measured before: 11 of 37 doorways on COLD STORAGE and 35 of 151 on THE COLD MILE held a piece leaving under 30 units for a body that needs 30, so the machines inside could route out and not walk out. A piece landing in a doorway zone slides along the wall until it is clear, with no random number drawn, so the seeded world does not move.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
