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

# SETTINGS CHIPS JUMP RIGHT ON A BIG SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var h=document.getElementById(setSecId(n)), bar=host.querySelector('.setjump'), i, d, s0;
'@ @'
  var h=document.getElementById(setSecId(n)), bar=host.querySelector('.setjump'), i, d, s0, zf=(host.offsetHeight>0)?(host.getBoundingClientRect().height/host.offsetHeight):1;
  if(!(zf>0)||!isFinite(zf)) zf=1;   // v27.75 (cloud-menus-settings-jump-zoom), CLOUD HUNT 2026-10-15: the menu zoom, a rectangle pixel per scrollTop pixel
'@

SubRx @'
    s0=host.scrollTop; host.scrollTop=s0+d;
'@ @'
    // v27.75 (cloud-menus-settings-jump-zoom), CLOUD HUNT 2026-10-15: d is in rectangle pixels and scrollTop is not, so at 4K every chip jumped past its section
    // to the end and came back on THE RAID, and at 1440p it fell short. Divided by the menu zoom it lands on the section at any screen size.
    s0=host.scrollTop; host.scrollTop=s0+d/zf;
'@

SubRx @'
var VER='27.74';
'@ @'
var VER='27.75';
'@

$pat = "(?m)^  now:'v27\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.75: The Settings section chips jump to their section on a 1440p or 4K screen too. Check 27.75 fails on v27.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
