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

# A TATTOO TILE IS A CLOSE-UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(kind==='face'||kind==='hat'||kind==='beard'||kind==='cut'){
      hh=Math.max(6,(b.up+b.dn)*0.42); s=Math.max(2,Math.min(7,104/hh));
'@ @'
    if(kind==='face'||kind==='hat'||kind==='beard'||kind==='cut'||kind==='tattoo'){
      // v18.83, seen on the FASHION screenshot (2026-10-07): a tattoo shown on the whole small figure could not be seen at all, every
      // TATTOO tile alike. Tattoos get a close-up too, a little wider than the head ones (face, neck and the tops of the arms).
      hh=Math.max(6,(b.up+b.dn)*((kind==='tattoo')?0.6:0.42)); s=Math.max(2,Math.min(7,104/hh));
'@

SubRx @'
var VER='18.82';
'@ @'
var VER='18.83';
'@

$pat = "(?m)^  now:'v18\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.83: The FASHION tattoo tiles show the tattoo up close. Check 18.83 fails on v18.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
