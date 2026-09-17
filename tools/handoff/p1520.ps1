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
        lines.push('<span style="color:var(--ash)">'+mname+' never made the ramp. No cut.</span>');
      } else {
        lines.push('<span style="color:var(--ash)">'+mname+' was left out there.</span>');
'@ @'
        lines.push('<span style="color:var(--ash)">'+mname+' never made the ramp. No cut.</span>');
      } else if(_mrow&&_mrow.out){
        // v15.20, hire audit finding: THE CARD SAYS A HIRE WHO GOT OUT FIRST WAS LEFT OUT THERE. On the LOOT order a hire
        // who runs low flees and extracts on his own: his extraction stamps his roster row out and takes him off the map, so
        // mercEnt is null here. When you extract too, the row pays your cut above; when you died or abandoned instead, neither
        // branch caught him and he fell to the line below, which said he was left out there though he got out before you.
        // No cut is still right (v6.72: the cut needs you both out) and no number moves; only the words were wrong.
        lines.push('<span style="color:var(--ash)">'+mname+' made it out on his own. No cut.</span>');
      } else {
        lines.push('<span style="color:var(--ash)">'+mname+' was left out there.</span>');
'@
SubRx @'
var VER='15.19';
'@ @'
var VER='15.20';
'@

$pat = "(?m)^  now:'v15\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.20: THE CARD SAYS A HIRE WHO GOT OUT FIRST WAS LEFT OUT THERE. If your hire ran low, fled and extracted on his own and you then died or abandoned, the outcome card said he was left out there, though he got out before you. The money was already right, since the cut needs you both out; the card now says he made it out on his own, no cut. Check 15.20 stamps the hire out through his roster row, takes him off the map, dies and reads his line on the card; it fails on v15.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
