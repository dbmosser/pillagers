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

# THE EXTRACT DISTANCE LINE HAS A PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    hudText(_lbl+' '+metres(zd)+'m',W/2,_yCmp);
'@ @'
    // v28.xx (cw-extplate), the critic (2026-10-19): 'extract 148m is bare teal text, no plate'. The distance line sits on the HUD plate like the score block above it.
    var _epw=Math.round(ctx.measureText(TX(_lbl+' '+metres(zd)+'m')).width+LH(20)), _eph=Math.round(_hCmp*1.5);
    hudPlate(Math.round(W/2-_epw/2),Math.round(_yCmp-_hCmp*1.05),_epw,_eph,null,HUDC.plate);
    ctx.fillStyle=_col;
    hudText(_lbl+' '+metres(zd)+'m',W/2,_yCmp);
'@

SubRx @'
var VER='32.11';
'@ @'
var VER='32.12';
'@

$pat = "(?m)^  now:'v32\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.12: The extract distance sits on a plate like the score. Check 32.12 fails on v32.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
