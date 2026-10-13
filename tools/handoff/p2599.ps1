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

# THE PAD WALK SKIPS KEYS WITH NOTHING ON THEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&sl[i].vacant)) break; }
'@ @'
  for(k=0;k<n;k++){ i=(i+dir+n)%n; if(!(sl[i]&&(sl[i].vacant||sl[i].kind==='empty'))) break; }   // v25.xx (belt7): and a key with nothing on it (a throwable, medical or armour key with none of its kind)
'@

SubRx @'
var VER='25.98';
'@ @'
var VER='25.99';
'@

$pat = "(?m)^  now:'v25\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.99: The controller bumpers now walk the belt over keys with nothing on them. Check 25.99 fails on v25.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
