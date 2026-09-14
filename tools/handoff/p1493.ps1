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
  var pm=P&&P.txt, v=pm?pm[s]:undefined;
  if(typeof v!=='string'&&TXSHIP) v=TXSHIP[s];   // v11.42: shipped default under his profile
  if(typeof v==='string') return v;
'@ @'
  var pm=P&&P.txt, v=pm?pm[s]:undefined;
  if(typeof v==='string') return v;
  // v14.93, words audit finding 6: HIS OWN PATTERN BEATS A BAKED EXACT LINE. His rewording of a number line saves a pattern for
  // any number, but a line baked at one number was consulted first, so at exactly that number the old wording came back,
  // against "His own P.txt wins" at TXSHIP. His pattern is looked up before the baked line.
  if(TXPANY&&pm&&P.txp&&/\d/.test(s)){ var sp0=txSplit(s), pv0=P.txp[sp0.pat]; if(typeof pv0==='string'&&sp0.nums.length) return txFill(pv0,sp0.nums); }
  if(TXSHIP) v=TXSHIP[s];   // v11.42: shipped default under his profile
  if(typeof v==='string') return v;
'@
SubRx @'
var VER='14.92';
'@ @'
var VER='14.93';
'@

$pat = "(?m)^  now:'v14\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.93: HIS OWN PATTERN BEATS A BAKED EXACT LINE. His rewording of a line with a number saves a pattern for any number, but a line baked into the file at one number was looked up first, so at exactly that number the old wording came back. His pattern is now looked up before the baked line. Check 14.93 saves a pattern over a baked number line; it fails on v14.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
