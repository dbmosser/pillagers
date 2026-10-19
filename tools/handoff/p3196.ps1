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

# WHAT IS NEW CARD: NOTE LINES SAY MORE THAN THE HEADLINE, X ABOVE THE TITLE RULE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(t.length<=60) return t;
  return t.slice(0,i+1);

'@ @'
  if(t.length<=60) return t;
  // v28.xx (cw-endrow2): the headline alone read "polish pass 31." with nothing after it, so the first clause of what follows comes too (cut at a comma or "and", never mid word).
  var rest=t.slice(i+2), c=rest.search(/,| and /);
  if(c<0||c>44) c=Math.min(rest.length,44), rest=rest.slice(0,c).replace(/\s+\S*$/,'');
  else rest=rest.slice(0,c);
  return t.slice(0,i+1)+(rest?' '+rest:'');
'@

SubRx @'
var _wxs=LH(40), _wxx=wnX+wnW-LH(14)-_wxs, _wxy=wnY+LH(14);
'@ @'
var _wxs=LH(32), _wxx=wnX+wnW-LH(14)-_wxs, _wxy=wnY+LH(10);   // v28.xx (cw-endrow2): the X (32 to 42 down) ends above the title rule (44 down); it ran across the rule at 40
'@

SubRx @'
var VER='31.95';
'@ @'
var VER='31.96';
'@

$pat = "(?m)^  now:'v31\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.96: Each note line keeps its first clause after the headline. The X is smaller and sits above the title rule. Check 31.96 fails on v31.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
