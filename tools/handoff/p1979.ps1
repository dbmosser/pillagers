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

# THE STASH BELT NUMBERS ARE READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      (it?iconImgHTML(k,22):'<span style="color:var(--ash);font-size:10.5px">'+(i+1)+'</span>')+
      (it?'<span style="position:absolute;right:2px;bottom:0;font-size:10.5px;color:var(--ash)">'+(i+1)+'</span>':'')+
'@ @'
      // v19.79, seen on the 4K stash screenshot (2026-10-08): the key numbers in the belt slots were 10.5px, a speck in a 62px slot
      // on a TV. 14 in an empty slot, 12 in the corner of a filled one, with the stack count beside it.
      (it?iconImgHTML(k,22):'<span style="color:var(--ash);font-size:14px">'+(i+1)+'</span>')+
      (it?'<span style="position:absolute;right:2px;bottom:0;font-size:12px;color:var(--ash)">'+(i+1)+'</span>':'')+
'@

SubRx @'
((it&&packedCount(k)>1)?'<span style="position:absolute;left:2px;top:0;font-size:10.5px;color:var(--amber)">x'
'@ @'
((it&&packedCount(k)>1)?'<span style="position:absolute;left:2px;top:0;font-size:12px;color:var(--amber)">x'
'@

SubRx @'
var VER='19.78';
'@ @'
var VER='19.79';
'@

$pat = "(?m)^  now:'v19\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.79: The key numbers in the stash belt slots are easier to read. Check 19.79 fails on v19.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
