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
# v11.46 HARDENED: measured in the ring seat, sight flickers frame to frame for a
# stationary pair (a pylon edge, a jittered grid cell), and re-arming the beat on
# every sightless frame made it re-fire every other frame - a floor by another road.
# The beat now re-arms only after a full second without sight.
SubRx @'
    if(!sees) e.beat=0;   // v11.46: losing sight re-arms the one-time reaction beat below
'@ @'
    // v11.46: losing sight for a full second re-arms the one-time reaction beat
    // below. A one-frame blink (a pylon edge, a jittered grid cell) must not, or
    // the beat re-fires every other frame and is a floor again by another road.
    if(!sees){ e.beatLost=(e.beatLost||0)+dt; if(e.beatLost>1.0) e.beat=0; } else e.beatLost=0;
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
