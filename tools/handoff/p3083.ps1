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

# SCORE LABEL CLEAR OF THE TOP EDGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var fb=FSz(TYPE.title,z), fs=FSz(TYPE.micro,z), mh=/([\d.]+)px/.exec(fb), h=mh?+mh[1]:20, w, gx, yL=y, _bot;
'@ @'
  var fb=FSz(TYPE.title,z), fs=FSz(TYPE.micro,z), mh=/([\d.]+)px/.exec(fb), h=mh?+mh[1]:20, w, gx, yL=y+Math.round(10*z), _bot;   // v28.xx (cw-scoretop): the whole block rides 10 pixels lower (the label) and 14 (the number) so the SCORE label is not clipped at the top edge (the critic, 10-19)
'@

SubRx @'
  y=y+Math.round(4*z); _bot=Math.round(y+h*0.22);
'@ @'
  y=y+Math.round(14*z); _bot=Math.round(y+h*0.22);
'@

SubRx @'
  ctx.font=fs; ctx.fillStyle='#ffc04a'; hudText(solo?'SCORE':'TEAM SCORE',cx,Math.round(yL-h*0.80));   // v23.54 (arcade30): SCORE in the 1 player arcade
'@ @'
  ctx.font=fs; ctx.fillStyle=UIC.tx_2; hudText(solo?'SCORE':'TEAM SCORE',cx,Math.round(yL-h*0.80));   // v23.54 (arcade30): SCORE in the 1 player arcade; v28.xx (cw-scoretop): the label is quiet grey (amber is for a warning), the number is the hero
'@

SubRx @'
var VER='30.82';
'@ @'
var VER='30.83';
'@

$pat = "(?m)^  now:'v30\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.83: The score label at the top centre is no longer cut off by the top edge. Check 30.83 fails on v30.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
