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

# STATUS DETAIL TYPE AND HIERARCHY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  nf=FS(TYPE.head); vf=FS(TYPE.label);   // v28.xx (cw-cx-statusread): shared status type grows from about 16/13 to 20/16 px at 1080p.
'@ @'
  // v28.xx (cw-cx-statusdetail): the shared status detail has a real 16px floor before the existing resolution and TV scaling.
  nf=FS(TYPE.head); vf=FS(TYPE.label).replace(/([\d.]+)px/,function(m,n){ return Math.max(parseFloat(n),16*uiScale())+'px'; });
'@

SubRx @'
      ctx.font=vf; ctx.fillStyle='#cdd6dd'; ctx.fillText(E.v||'',tx,cy+LH(11));
'@ @'
      ctx.font=vf; ctx.fillStyle='#aaa498'; ctx.fillText(E.v||'',tx,cy+LH(11));   // v28.xx (cw-cx-statusdetail): style-guide tx-2 keeps the bonus below the status name in the hierarchy.
'@

SubRx @'
var VER='36.21';
'@ @'
var VER='36.22';
'@

$pat = "(?m)^  now:'v36\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.22: Status details use a 16px floor and muted ink below the larger status name. Check 36.22 fails on v36.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
