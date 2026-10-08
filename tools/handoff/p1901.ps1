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

# AN EMPTY BELT KEY IS JUST A KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      } else {
        ctx.fillRect(cx2-bw*0.05,cy2-bw*0.20,bw*0.10,bw*0.34);
'@ @'
      } else if(S.kind!=='empty'){   // v19.01, seen on the 4K screenshots (2026-10-07): an empty key drew this fallback T and a 0, like a broken item; it is just the key now
        ctx.fillRect(cx2-bw*0.05,cy2-bw*0.20,bw*0.10,bw*0.34);
'@

SubRx @'
      if(S.count!==null&&S.count!==undefined){
'@ @'
      if(S.count!==null&&S.count!==undefined&&S.kind!=='empty'){   // v19.01: no count on an empty key
'@

SubRx @'
var VER='19.00';
'@ @'
var VER='19.01';
'@

$pat = "(?m)^  now:'v19\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.01: Empty belt keys show only their number. Check 19.01 fails on v19.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
