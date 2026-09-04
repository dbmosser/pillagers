$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v10.46: FOG, NOT CLEAR. Its three floors, red, pale and ink, were calibrated
# on what seed 4242 rolled when the check was written, which was noon in fog.
# Pinning noon under a clear sky kept the numeral and lost the side panels: ink
# read minus 3 against a floor of 2, because fog is what puts the trim under the
# darkness line. The light a colour check names has to be the light its floors
# were read under.
SubRx @'
     // v11.14: noon, clear, by name. This read 20 pale pixels at noon in fog
     // and 2 at 6pm under a clear sky, both on the same jersey, when the
     // furniture fix let one more lamp fit and the sky rolled after the lamps.
     if(typeof TODS!=='undefined'&&typeof WEATHER!=='undefined'){
       for(var _ti2=0;_ti2<TODS.length;_ti2++) if(TODS[_ti2].id==='noon') g.tod=TODS[_ti2];
       for(var _wi2=0;_wi2<WEATHER.length;_wi2++) if(WEATHER[_wi2].id==='clear') g.wx=WEATHER[_wi2];
     }
'@ @'
     // v11.14: noon in fog, by name, which is the light the three floors below
     // were read under. This read 20 pale pixels at noon in fog and 2 at 6pm
     // under a clear sky, both on the same jersey, when the furniture fix let
     // one more lamp fit and the sky rolled after the lamps. Noon under a CLEAR
     // sky kept the numeral and lost the side panels, ink minus 3 against 2.
     if(typeof TODS!=='undefined'&&typeof WEATHER!=='undefined'){
       for(var _ti2=0;_ti2<TODS.length;_ti2++) if(TODS[_ti2].id==='noon') g.tod=TODS[_ti2];
       for(var _wi2=0;_wi2<WEATHER.length;_wi2++) if(WEATHER[_wi2].id==='fog') g.wx=WEATHER[_wi2];
     }
'@

# v8.88: THE ROOM IS THE VIEWPORT, NOT THE CANVAS. applyMenuZoom fits the title
# column to window.innerHeight, and in this pane innerHeight stays at 1080 when
# the canvas is asked for 1440, so a title column tall enough to be clamped at
# 1080 can never show the 1440p rise. It passed before only while the fixture
# profile held one save and the column was short. Measured: four saves, column
# 1078 tall, zoom asked 1.733 and fitted to 1.4513. The pane, by name.
SubRx @'
     var _hp=__forceSize(2560,1440).H;
     if(_hp<1400){ P.menuZoom=keepZ; __forceSize(keepW||1920,keepH||1080); applyMenuZoom();
       return 'SKIP: the pane cannot reach 1440p, it gave '+_hp+' tall, so the monitor rule cannot be measured here'; }
'@ @'
     __forceSize(2560,1440);
     var _vh=window.innerHeight||0;
     if(_vh<1400){ P.menuZoom=keepZ; __forceSize(keepW||1920,keepH||1080); applyMenuZoom();
       return 'SKIP: the pane cannot reach 1440p, its viewport stays '+_vh+' tall and the title is fitted to the viewport, so the monitor rule cannot be measured here'; }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
