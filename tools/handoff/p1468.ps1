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
  var hat=pick('hat',['crown']);
'@ @'
  // v14.68, wardrobe audit finding 5: A HAT MARKED crowd:0 IS NEVER ON A PILLAGER. His v11.13 ruling made the Spartan Helmet and the
  // Ghost Mask his alone, like the crown, and the Undercroft crowd respects it, but this pick skipped only the crown, so about
  // one pillager in eight wore one of his hats. Every crowd:0 hat is skipped with the crown; the hash advances the same way.
  var hat=pick('hat',['crown'].concat(COSMETICS.filter(function(c){ return c.kind==='hat'&&c.crowd===0; }).map(function(c){ return c.id; })));
'@
SubRx @'
var VER='14.67';
'@ @'
var VER='14.68';
'@

$pat = "(?m)^  now:'v14\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.68: HIS HATS ARE NEVER ON A PILLAGER. His ruling made the Spartan Helmet and the Ghost Mask his alone, like the crown, but raid pillagers skipped only the crown, so about one in eight wore one of his hats. Every hat marked his alone is now skipped. Check 14.68 draws 600 pillager looks; it fails on v14.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
