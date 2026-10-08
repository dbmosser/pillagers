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

# THE FASHION PIECE PREVIEWS SHOW THE PIECE EVEN WITH AN OUTFIT ON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  keepW=wc; keepV=P[ck]; keepOwned=cosOwned;
  try{
    wc=x2;
    b=cosPreviewBox(cv2,x2);
'@ @'
  keepW=wc; keepV=P[ck]; keepOwned=cosOwned;
  // v19.09, from the review (2026-10-07): an outfit overrules hat, beard, hairstyle, face, tattoo and clothing when drawn, so while
  // one was worn every tile on those six racks showed the same outfit picture. The previews are painted on the operator's own
  // clothes (outfit off for the one paint), where those pieces really show; the worn outfit is put back after.
  var keepO=P[COSKEY.outfit];
  try{
    wc=x2;
    P[COSKEY.outfit]='outnone';
    b=cosPreviewBox(cv2,x2);
'@

SubRx @'
  finally{ wc=keepW; cosOwned=keepOwned; if(keepV===undefined) delete P[ck]; else P[ck]=keepV; }
'@ @'
  finally{ wc=keepW; cosOwned=keepOwned; if(keepV===undefined) delete P[ck]; else P[ck]=keepV; if(keepO===undefined) delete P[COSKEY.outfit]; else P[COSKEY.outfit]=keepO; }
'@

SubRx @'
var VER='19.08';
'@ @'
var VER='19.09';
'@

$pat = "(?m)^  now:'v19\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.09: With an outfit on, the FASHION hat, hair, face, tattoo and clothing tiles still show each piece. Check 19.09 fails on v19.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
