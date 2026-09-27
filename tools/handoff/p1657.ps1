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

# A PAUSED PARTY IS PAUSED WHILE THE HOST SPECTATES (stability pass before his co-op session, 2026-09-27).

SubRx @'
  G=S; NET.specTick=true;
'@ @'
  // v16.57, stability (co-op review): his rule of v16.27 is that the game pauses whenever every player is paused. While the
  // host spectated, this ran the kept raid whatever the party did, so a teammate who paused saw his own screen stop while the
  // pillagers on the host went on shooting him and the clock ran down. With every teammate up top paused the world stands still;
  // the words still go out.
  var wdt=dt, _pzAll=true;
  for(i=0;i<NET.up.length;i++) if(netUpShown(NET.up[i])&&!NET.up[i].pz) _pzAll=false;
  if(_pzAll) wdt=0;
  G=S; NET.specTick=true;
'@

SubRx @'
    G.t+=dt; if(raidClockOn()) G.timeLeft=Math.max(0,G.timeLeft-dt);
    refreshVseg(); updateEnts(dt); updateBullets(dt); updateThrowables(dt);
'@ @'
    G.t+=wdt; if(raidClockOn()) G.timeLeft=Math.max(0,G.timeLeft-wdt);
    refreshVseg(); updateEnts(wdt); updateBullets(wdt); updateThrowables(wdt);
'@

SubRx @'
    netSrchTick(dt);
'@ @'
    netSrchTick(wdt);
'@

SubRx @'
var VER='16.56';
'@ @'
var VER='16.57';
'@

$pat = "(?m)^  now:'v16\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.57: A PAUSED PARTY IS PAUSED WHILE THE HOST SPECTATES. Stability pass before a co-op session. His rule is that the game pauses whenever every player is paused. While the host watched after leaving the raid, the raid kept running for the party whatever they did, so a teammate who paused saw his screen stop while the pillagers went on shooting him and the clock ran down. Now with every teammate paused the raid stands still. Check 16.57 fails on v16.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
