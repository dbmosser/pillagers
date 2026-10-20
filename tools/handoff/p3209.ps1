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

# PAD PICTURE LEADERS ARE CLEANER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var left=[[6,64,342,222],[4,120,334,254],[10,232,354,332],[8,288,440,302],[12,400,408,385],[14,456,386,408],[13,512,408,431],[15,568,430,408]];
'@ @'
var left=[[6,64,342,222],[4,120,334,254],[8,232,440,302],[10,288,354,332],[12,400,408,385],[14,456,386,408],[15,512,430,408],[13,568,408,431]];   // v28.xx (cw-padpic) critic on Pad buttons 74 (2): "leader lines cross each other". The left labels now run in the same top to bottom order as their controls, so those leaders no longer cross.
'@

SubRx @'
'<path d="M'+x+' '+py+' L'+edge+' '+(y-8)+' H'+end+'" fill="none" stroke="var(--ui-line-hi,#4a5257)" stroke-width="2"/>'+
'@ @'
'<path d="M'+x+' '+py+' L'+edge+' '+(y-8)+' H'+end+'" fill="none" stroke="var(--ui-line-hi,#4a5257)" stroke-width="2"/>'+
      '<circle cx="'+x+'" cy="'+py+'" r="5" fill="var(--ui-line-hi,#4a5257)"/>'+
'@

SubRx @'
'<tspan fill="var(--acc,#e6ff3d)">'+PAD_BTN[button].toLowerCase()+'</tspan>
'@ @'
'<tspan fill="var(--tx-2,#aaa498)">'+PAD_BTN[button].toLowerCase()+'</tspan>
'@

SubRx @'
var VER='32.08';
'@ @'
var VER='32.09';
'@

$pat = "(?m)^  now:'v32\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.09: The pad picture has tidier leader lines with dots and calmer key names. Check 32.09 fails on v32.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
