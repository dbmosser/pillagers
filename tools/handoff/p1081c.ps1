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

# ==== A FLAT CHANCE PER BUILDING GAVE THE SMALL MAP ONE. Measured at four
# ==== rates: COLD STORAGE ruins ONE building at 0.09 and still one at 0.18,
# ==== because twenty buildings is too few for a coin to land twice, while THE
# ==== COLD MILE goes 5 to 11 across the same range. One wrecked building on the
# ==== map a friend plays first is not a feature anybody would notice, and it is
# ==== the v10.80 lesson from two builds ago: a thing meant to be on every map
# ==== has to be GUARANTEED on every map, not left to a roll.
# ==== The rate becomes a proportion of the eligible buildings with a floor of
# ==== two, taken in hash order, which is still fully deterministic and now
# ==== gives COLD STORAGE 2 and the mile 7.
SubRx @'
    for(var _rb=0;_rb<buildings.length;_rb++){
      var _RB=buildings[_rb];
      // Too small to read as anything but a shed with a hole in it.
      if(_RB.w<140||_RB.h<140){ _ruinLog.skipSmall++; continue; }
'@ @'
    // Eligible first, then a count taken off the top in hash order.
    var _elig=[];
    for(var _rb=0;_rb<buildings.length;_rb++){
      var _RB=buildings[_rb];
      // Too small to read as anything but a shed with a hole in it.
      if(_RB.w<140||_RB.h<140){ _ruinLog.skipSmall++; continue; }
'@
SubRx @'
      if(_lk){ _ruinLog.skipLocked++; continue; }
      if(_rh(_RB.x,_RB.y)>=_rrate) continue;
'@ @'
      if(_lk){ _ruinLog.skipLocked++; continue; }
      _elig.push({i:_rb,h:_rh(_RB.x,_RB.y)});
    }
    _elig.sort(function(a,b){ return a.h-b.h; });
    // A FLOOR OF TWO ON EVERY MAP. A flat chance per building gave COLD STORAGE
    // exactly one at every rate from 0.09 to 0.18, because twenty buildings is
    // too few for a coin to land twice.
    var _want=Math.max(2,Math.round(_elig.length*_rrate));
    if(_want>_elig.length) _want=_elig.length;
    _ruinLog.eligible=_elig.length; _ruinLog.want=_want;
    for(var _eq=0;_eq<_want;_eq++){
      _RB=buildings[_elig[_eq].i];
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
