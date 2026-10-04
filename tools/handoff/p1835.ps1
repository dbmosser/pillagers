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

# ONE SIEGE SIZE: THE PROMISE MATCHES THE ARRIVALS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function greedOf(){ return clamp(bagValue()/CFG.greedFull,0,1); }
'@ @'
function greedOf(){ return clamp(bagValue()/CFG.greedFull,0,1); }
// v18.35, FOUND BY THE FULL TEST RUN (2026-10-04): ONE SIEGE SIZE. v18.06 cut the siege to 5 + 7 x greed (his son: too many big
// robots) in the spawner only; the call still promised 6 + 8 x greed ("about 10 machines" with 8 coming), the late pull wave
// and a linked window's copy of the siege still counted the old size. Every one of them reads this now.
function siegeBase(GR){ return 5+7*GR; }
'@

SubRx @'
      var _scap=Math.round((6+8*_g)*(CFG.siegeVol===undefined?1:CFG.siegeVol));
'@ @'
      var _scap=Math.round(siegeBase(_g)*(CFG.siegeVol===undefined?1:CFG.siegeVol));   // v18.35: the one siege size
'@

SubRx @'
  var siegeIv=(8-4.6*GR)/_sv85, siegeCap=Math.round((5+7*GR)*_sv85);   // v18.06: his son, fewer at the ring (was 6+8*GR)
'@ @'
  var siegeIv=(8-4.6*GR)/_sv85, siegeCap=Math.round(siegeBase(GR)*_sv85);   // v18.06: his son, fewer at the ring (was 6+8*GR); v18.35: the one siege size
'@

SubRx @'
    var _pullCap=Math.round((6+8*GR)*(CFG.siegePull===undefined?0.5:CFG.siegePull));
'@ @'
    var _pullCap=Math.round(siegeBase(GR)*(CFG.siegePull===undefined?0.5:CFG.siegePull));   // v18.35: the one siege size
'@

SubRx @'
    iv=(8-4.6*GR)/sv; cap=Math.round((6+8*GR)*sv);
'@ @'
    iv=(8-4.6*GR)/sv; cap=Math.round(siegeBase(GR)*sv);   // v18.35: the one siege size, as the host counts it
'@

SubRx @'
      pc=Math.round((6+8*GR)*(CFG.siegePull===undefined?0.5:CFG.siegePull)); z.pullN=z.pullN||0;
'@ @'
      pc=Math.round(siegeBase(GR)*(CFG.siegePull===undefined?0.5:CFG.siegePull)); z.pullN=z.pullN||0;   // v18.35: the one siege size
'@

SubRx @'
var VER='18.34';
'@ @'
var VER='18.35';
'@

$pat = "(?m)^  now:'v18\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.35: The extraction call now promises exactly as many machines as actually come. Check 18.35 fails on v18.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
