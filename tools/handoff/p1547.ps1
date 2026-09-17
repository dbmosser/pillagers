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

SubRx @'
  var kills=r.kills?(r.kills.sentry+r.kills.crawler+r.kills.raider+(r.kills.snitch||0)+(r.kills.howler||0)+(r.kills.bulwark||0)):0;
'@ @'
  // v15.47, bodies audit finding: EACH RUN IN YOUR STATS COUNTS ITS LISTENER, PILLBOX AND WARDEN KILLS. This line added six
  // kill counts by hand (sentry, crawler, raider, snitch, howler, bulwark) and a run record keeps nine: the death path fills
  // T.kills[e.kind] for whatever kind died by your fire, so warden, listener and choir (the Pillbox) are counted there and were
  // left out here. A run whose only kill was a Listener, a Pillbox or the Warden said 1 kill on its end card and in the Average
  // kills per run card above, and 0k on its own line in the Every run list. v8.42 fixed the same hand list on the end card and
  // this one was missed. Every count the record keeps is added now, the way statSummary adds them for the average, so a run
  // logged before the newer counts existed adds what it has. No number, no player text and no seeded draw moved.
  var kills=0; if(r.kills) for(var _fk in r.kills) kills+=(r.kills[_fk]||0);
'@
SubRx @'
var VER='15.46';
'@ @'
var VER='15.47';
'@

$pat = "(?m)^  now:'v15\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.47: EACH RUN IN YOUR STATS COUNTS ITS LISTENER, PILLBOX AND WARDEN KILLS. The Every run list under Your stats added six of the nine kill counts a run keeps, so a run whose only kill was a Listener, a Pillbox or the Warden said 1 kill on its end card and 0k on its own line. Each line now adds every kill count the run keeps, the same sum the Average kills per run card takes. Check 15.47 destroys a sentry, a Listener, a Warden and a Pillbox in one frame, abandons the raid and reads the new line in the list; it fails on v15.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
