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

# v10.46: PIN THE LIGHT IT MEASURES UNDER. It reads the pale numeral on the
# jersey at the drop point at seed 4242 and had been reading it at noon in fog
# by luck of the roll. v11.14 let one more lamp fit on COLD STORAGE, the lamps
# draw from the seeded stream and the sky is rolled after them, so the same seed
# became six in the evening under a clear sky and the golden light pulled the
# white numeral under the brightness line: 20 pale pixels became 2. Not the
# jersey. A colour measurement names its light.
SubRx @'
     var g=__state(); if(!g) return 'SKIP: no raid';
     var p=g.player; g.ents.length=0; p.hp=100000; p.maxhp=100000; p.armor=0; p.plate=0;
'@ @'
     var g=__state(); if(!g) return 'SKIP: no raid';
     // v11.14: noon, clear, by name. This read 20 pale pixels at noon in fog
     // and 2 at 6pm under a clear sky, both on the same jersey, when the
     // furniture fix let one more lamp fit and the sky rolled after the lamps.
     if(typeof TODS!=='undefined'&&typeof WEATHER!=='undefined'){
       for(var _ti2=0;_ti2<TODS.length;_ti2++) if(TODS[_ti2].id==='noon') g.tod=TODS[_ti2];
       for(var _wi2=0;_wi2<WEATHER.length;_wi2++) if(WEATHER[_wi2].id==='clear') g.wx=WEATHER[_wi2];
     }
     var p=g.player; g.ents.length=0; p.hp=100000; p.maxhp=100000; p.armor=0; p.plate=0;
'@

# v8.88: NAME THE SIZE WHEN THE PANE CANNOT REACH IT. The monitor rule needs a
# 1440 pixel tall window; a pane that hands back less cannot measure it, and
# saying so by size is the rule from the v9.9x notes, not a pass.
SubRx @'
     var c=z(2560,1440,1.3);
'@ @'
     var _hp=__forceSize(2560,1440).H;
     if(_hp<1400){ P.menuZoom=keepZ; __forceSize(keepW||1920,keepH||1080); applyMenuZoom();
       return 'SKIP: the pane cannot reach 1440p, it gave '+_hp+' tall, so the monitor rule cannot be measured here'; }
     var c=z(2560,1440,1.3);
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
