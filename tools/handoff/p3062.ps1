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

# RESIZE HATCH ONLY ON HOVER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var hot=(HUDRESIZE&&HUDRESIZE.id===gk)||hudOnGrip(GB,mouse.x,mouse.y);
'@ @'
      var hot=(HUDRESIZE&&HUDRESIZE.id===gk)||hudOnGrip(GB,mouse.x,mouse.y);
      if(!hot&&!inRect(GB,mouse.x,mouse.y)) continue;   // v28.xx (cw-hudgrips), the style guide (no clutter: chrome only when used): the resize hatch shows only while the pointer is over its panel
'@

SubRx @'
var VER='30.61';
'@ @'
var VER='30.62';
'@

$pat = "(?m)^  now:'v30\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.62: The raid HUD panels show their resize hatch only when the pointer is over them. Check 30.62 fails on v30.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
