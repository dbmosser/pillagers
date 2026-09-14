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
  if(AC&&AC.state==='suspended'&&AC.resume){ try{ AC.resume(); }catch(e){} }
'@ @'
  // v14.39, audio audit finding 5: NO RESUME BEFORE THE FIRST CLICK. The music and reverb ticks call this every frame from
  // page load, so before a friend had clicked or pressed anything the browser was asked to resume sixty times a second,
  // refused each time, and logged a warning each time, burying real errors in the console. Resume is asked for once the
  // page has had a user gesture; where the browser cannot say, it is asked as before.
  if(AC&&AC.state==='suspended'&&AC.resume&&(!navigator.userActivation||navigator.userActivation.hasBeenActive)){ try{ AC.resume(); }catch(e){} }
'@
SubRx @'
var VER='14.38';
'@ @'
var VER='14.39';
'@

$pat = "(?m)^  now:'v14\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.39: NO RESUME BEFORE THE FIRST CLICK. The audio was asked to resume every frame from page load, so before any click the browser refused and logged a warning sixty times a second, burying real errors in the console. Resume is now asked for only once the page has had a click or key press. Check 14.39 calls ac() on a suspended fake context with and without a recorded gesture; it fails on v14.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
