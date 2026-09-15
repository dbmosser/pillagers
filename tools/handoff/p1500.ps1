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
         ne:P.netEarn||0,
'@ @'
         ne:P.netEarn||0,
         // v15.00, save audit finding 1: HIS STANDING WITH EVERY NAMED PILLAGER. Kills, deaths and standing decide who shoots him
         // on sight and who will take his money as a hire, and the code carried none of it.
         rv:P.rivals||{},
'@
SubRx @'
  P.netEarn=(typeof o.ne==='number')?o.ne:0;
'@ @'
  P.netEarn=(typeof o.ne==='number')?o.ne:0;
  // v15.00, save audit finding 1: THE RESTORED CHARACTER'S GRUDGES, NOT THE REPLACED ONE'S. P.rivals was neither carried nor
  // cleared, so a character who never met a named pillager inherited the grudge of the save he replaced: that pillager shot on
  // sight every raid and refused to be hired. An older code with no standing starts clean.
  P.rivals=(o.rv&&typeof o.rv==='object'&&!Array.isArray(o.rv))?o.rv:{};
'@
SubRx @'
var VER='14.99';
'@ @'
var VER='15.00';
'@

$pat = "(?m)^  now:'v14\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.00: A RESTORE CODE CARRIES HIS STANDING WITH THE NAMED PILLAGERS. Kills, deaths and standing with each named pillager decide who shoots him on sight and who will be hired, and a restore code neither carried them nor cleared them, so the restored character inherited the replaced one. The code now carries them and a restore replaces them. Check 15.00 makes a code with one grudge and restores it over another; it fails on v14.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
