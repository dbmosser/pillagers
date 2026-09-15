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
         rv:P.rivals||{},
'@ @'
         rv:P.rivals||{},
         cc:P.cdone||0,   // v15.01, save audit finding 2: the contracts he completed, beside the standing it already carries
'@
SubRx @'
  P.rivals=(o.rv&&typeof o.rv==='object'&&!Array.isArray(o.rv))?o.rv:{};
'@ @'
  P.rivals=(o.rv&&typeof o.rv==='object'&&!Array.isArray(o.rv))?o.rv:{};
  // v15.01, save audit finding 2: THE CONTRACTS COMPLETED COUNT IS THE RESTORED CHARACTER'S. The code carried the contract standing
  // printed on the board but not the count printed beside it, so the board read the replaced character's count against the
  // restored character's standing.
  P.cdone=o.cc|0;
'@
SubRx @'
var VER='15.00';
'@ @'
var VER='15.01';
'@

$pat = "(?m)^  now:'v15\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.01: A RESTORE CODE CARRIES THE CONTRACTS COMPLETED COUNT. The code carried the contract standing but not the count the board prints beside it, so after a restore the board showed the replaced character count against the restored character standing. The count now travels with the code. Check 15.01 makes a code at seven contracts and restores it over ninety nine; it fails on v15.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
