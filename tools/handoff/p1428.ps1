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
    if(W.lights!==undefined&&W.lights<1){
      var base=lampBase(day,tdo);
'@ @'
    if(W.lights!==undefined&&W.lights<1){
      // v14.28, progression audit finding 1: UNDER BLACKOUT PROTOCOL THERE ARE NO LAMPS TO KILL. The term places no lamps and
      // forces a lit hour, and lampBase reads that hour's nominal lamp level, so Blackout weather under the term always
      // counted as hard: the run card printed and the run banked the hard weather bonus on top of the term's own pay, for
      // lamps that were never there. By this function's own rule, lamp-killing weather counts only when the lamps were on.
      if(typeof hasTerm==='function'&&hasTerm('blackout')) return 0;
      var base=lampBase(day,tdo);
'@
SubRx @'
var VER='14.27';
'@ @'
var VER='14.28';
'@

$pat = "(?m)^  now:'v14\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.28: UNDER BLACKOUT PROTOCOL, BLACKOUT WEATHER IS NOT HARD WEATHER. The term places no lamps, but the hard weather rule read the nominal lamp level of the hour it forces, so Blackout weather under the term paid the hard weather XP bonus for lamps that were never there. With the term signed, lamp-killing weather no longer counts as hard; weather that cuts sight still does. Check 14.28 reads the rule with and without the term; it fails on v14.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
