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
  var _otherLock=!!(btn&&btn.disabled&&(P.credits>=o.price));
'@ @'
  // v14.73, stash and trader audit finding 1: A GUN HE OWNS IS LOCKED FOR ITS OWN REASON. An owned gun's row is disabled and
  // reads Owned, but it counted as locked for its own reason only when he could afford it anyway, so a fresh profile with 900
  // selecting the Scav Pistol he already owns got a dead button reading NEED $900 MORE. Owning it is the reason.
  var _otherLock=!!(btn&&btn.disabled&&(P.credits>=o.price||(o.kind==='wep'&&(P.weapons||[]).indexOf(o.k)>=0)));
'@
SubRx @'
var VER='14.72';
'@ @'
var VER='14.73';
'@

$pat = "(?m)^  now:'v14\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.73: THE SHOP DOES NOT ASK FOR MONEY FOR A GUN HE OWNS. An owned gun counted as locked for its own reason only when he could afford it anyway, so selecting the Scav Pistol on a fresh profile showed a dead NEED 900 MORE button. Owning the gun is now its own reason. Check 14.73 selects an owned gun and a gun not owned, both short of the price; it fails on v14.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
