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

# THE MAP WEATHER LINE CLEARS THE CREDITS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillText((isDay()?tod().name:'night')+'  '+G.wx.name+
    (G.wxNext?('  \u2192 '+G.wxNext.name+'  '+Math.round(G.wxT*100)+'%'):''),
    ox+WORLD_W*sc,oy-10);
'@ @'
  // v19.32, seen on the 4K map screenshot (2026-10-08): this line ends at the map's right edge, which on a big screen is under the credits
  // and XP readout in the top right corner (8am Clear ran into 900 CREDITS). When that readout covers the line, it ends just left of it.
  var _wxR=ox+WORLD_W*sc;
  try{
    var _trE=document.getElementById('topright'), _trR=_trE?_trE.getBoundingClientRect():null, _cvR=ctx.canvas.getBoundingClientRect(), _wm=ctx.getTransform(), _wk=(_cvR.width>0)?ctx.canvas.width/_cvR.width:1;
    if(_trR&&_trR.width>0&&_wm.a){
      var _wfp=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11;
      var _trL=((_trR.left-_cvR.left)*_wk-_wm.e)/_wm.a, _trB=((_trR.bottom-_cvR.top)*_wk-_wm.f)/(_wm.d||1);
      if(_trB>oy-10-_wfp&&_trL<_wxR+2) _wxR=Math.min(_wxR,_trL-14);
    }
  }catch(_wx){}
  ctx.fillText((isDay()?tod().name:'night')+'  '+G.wx.name+
    (G.wxNext?('  \u2192 '+G.wxNext.name+'  '+Math.round(G.wxT*100)+'%'):''),
    _wxR,oy-10);
'@

SubRx @'
var VER='19.31';
'@ @'
var VER='19.32';
'@

$pat = "(?m)^  now:'v19\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.32: The time and weather on the sector map no longer run into the credits. Check 19.32 fails on v19.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
