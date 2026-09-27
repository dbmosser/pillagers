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

# A SPECTATING HOST BACK IN THE UNDERCROFT NEVER LETS THE RAID GO (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
  if(!S||NET.role!=='host'){ NET.specG=null; return 0; }
'@ @'
  if(!S||NET.role!=='host'){ NET.specG=null; return 0; }
  // v16.70, stability (co-op review): a teammate whose words stop goes stale after NET_HUB_STALE and the kept raid is let go.
  // But his words aged only in netUpTick, which runs only while this window has a raid in hand, so once the host was back in
  // the Undercroft (G null) nothing aged them: a teammate word left set after his run ended (a last position word on the fast,
  // unordered channel can land after his out word and file him again) or from a window that stopped drawing stayed fresh for
  // good, the raid was never let go and every later ascent was refused. When netUpTick is not running this frame they age here,
  // by the same step; on the run card netUpTick still ages them, once.
  if(!(state==='raid'&&keep&&!keep.sim)&&isFinite(dt)&&dt>0) for(i=0;i<NET.up.length;i++) if(NET.up[i]) NET.up[i].age+=dt;
'@

SubRx @'
var VER='16.69';
'@ @'
var VER='16.70';
'@

$pat = "(?m)^  now:'v16\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.70: A HOST BACK IN THE UNDERCROFT LETS THE RAID GO WHEN HIS TEAMMATE STOPS SENDING. Stability pass before a co-op session. The host keeps the raid running for his party until nobody is up top, judged by how long ago each teammate last sent word, but that clock only ran while the host had a raid of his own in hand. Back in the Undercroft it stopped, so a teammate word left over after his run ended kept the raid alive for good and every later ascent was refused. The clock now runs there too. Check 16.70 fails on v16.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
