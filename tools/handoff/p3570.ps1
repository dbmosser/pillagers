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

# THE SCORE MULTIPLIER LINES SHOW AND LINE UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(oc&&o.dm>1) for(i=0;i<ln.length;i++) if(ln[i][0]==='aos'){ ln.splice(i+1,0,['aor aodm','settings x'+(+o.dm).toFixed(2)]); break; }   // v35.xx (cw-dmulshow): the settings multiplier, once, under the score
'@ @'
    if(oc&&o.dm>1) ln.splice(1,0,['aoh','settings x'+(+o.dm).toFixed(2)]);   // v35.xx (cw-dmulfix): the settings multiplier, once, a heading line under extracted x2 (the aor rows are hidden on the restyled card)
'@

SubRx @'
<b id="set_dmul" style="padding:6px 12px;min-width:92px;text-align:center;color:var(--amber)">
'@ @'
<b id="set_dmul" style="display:inline-flex;justify-content:center;align-items:center;box-sizing:border-box;margin-left:0;min-width:calc(var(--sp-5) * 6);min-height:var(--btn-h-sm);padding:6px 12px;border:1px solid transparent;font-size:var(--fs-body);font-weight:600;letter-spacing:var(--track);color:var(--amber)">
'@

SubRx @'
var VER='35.69';
'@ @'
var VER='35.70';
'@

$pat = "(?m)^  now:'v35\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.70: the demo run over card shows settings x under extracted x2; the settings score value lines up with the other values Check 35.70 fails on v35.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
