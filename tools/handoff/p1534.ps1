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
    var _shipDown=(G.beaconT<=0&&G.shipHold!==null&&G.shipHold!==undefined);
    var _inRing=dist(p,G.active)<G.active.r;
'@ @'
    // v15.34, extraction audit finding: STANDING IN ANY LANDED EXTRACTION POINT SHOWS THE EXTRACT PROMPT. Both tests here read
    // the pointer and its mirrors, and the pointer is the point called last: with one point landed and a later call still
    // inbound at another, standing in the landed one does not move it back (v12.57), so the centre verb measured the inbound
    // point, found nothing landed there and drew nothing, while a hold of E in the landed point still took him out there. Both
    // now read the point he stands in, standingRing, the scan the pull, the surrender guard and the downed screen already use
    // (v12.94). It falls back to the pointer when he is in no point, so a single call reads exactly as before.
    var _sr=standingRing(), _shipDown=ringLanded(_sr);
    var _inRing=!!_sr&&dist(p,_sr)<_sr.r;
'@
SubRx @'
var VER='15.33';
'@ @'
var VER='15.34';
'@

$pat = "(?m)^  now:'v15\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.34: STANDING IN ANY LANDED EXTRACTION POINT SHOWS THE EXTRACT PROMPT. With one point landed and a later call still inbound at another, standing in the landed point drew no prompt to hold E, because the prompt followed the point called last, yet holding E there still extracted him. The prompt now reads the point he stands in, as the downed screen already does, and a single call reads as before. Check 15.34 stands him in a landed point while another is inbound; it fails on v15.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
