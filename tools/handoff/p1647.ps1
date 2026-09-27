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

# A CONTROLLER PLACES A MAP MARKER (the gap left at v16.46).

SubRx @'
    mouse.x=psx+rx*_rr2*pz; mouse.y=psy+ry*_rr2*pz; mouse.init=true;
  }
'@ @'
    mouse.x=psx+rx*_rr2*pz; mouse.y=psy+ry*_rr2*pz; mouse.init=true;
  }
  // v16.47: A CONTROLLER PLACES A MAP MARKER. With the map open, the right stick moves a cursor across the map (from where you
  // stand, the whole map in about two seconds) and a tap of D-UP places your marker there. The cursor takes over only once the
  // stick moves, so a mouse on the same window keeps the map.
  if(G&&!G.over&&G.mapOpen&&G.player&&(rx||ry||G.mapCur)){
    var _mnow=netPadNow(), _mdt=Math.min(0.05,Math.max(0,_mnow-(PAD.mcT||_mnow))); PAD.mcT=_mnow;
    if(!G.mapCur) G.mapCur={x:G.player.x,y:G.player.y};
    G.mapCur.x=clamp(G.mapCur.x+rx*WORLD_W*0.5*_mdt,0,WORLD_W); G.mapCur.y=clamp(G.mapCur.y+ry*WORLD_W*0.5*_mdt,0,WORLD_H);
    var _MPc=mapProj(); mouse.x=_MPc.ox+G.mapCur.x*_MPc.sc; mouse.y=_MPc.oy+G.mapCur.y*_MPc.sc; mouse.init=true;
  } else if(G&&!G.mapOpen){ G.mapCur=null; PAD.mcT=0; }
'@

SubRx @'
      if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;
'@ @'
      if(G.mapOpen&&G.mapCur) netWpFromMap(); else if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;   // v16.47: with the map cursor moved, a tap places the marker
'@

SubRx @'
  blip('pick'); say('Marker placed. Your party can see it.');
'@ @'
  blip('pick'); say((typeof NET==='object'&&NET&&NET.on)?'Marker placed. Your party can see it.':'Waypoint marked');
'@

SubRx @'
var VER='16.46';
'@ @'
var VER='16.47';
'@

$pat = "(?m)^  now:'v16\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.47: A CONTROLLER PLACES A MAP MARKER. The gap left at v16.46: a controller could not place a map marker. With the map open the right stick now moves a cursor across the map and a tap of D-UP places the marker there, shared with the party as a mouse click is; a hold still shuts the map. A mouse on the same window keeps the map until the stick moves. Check 16.47 fails on v16.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
