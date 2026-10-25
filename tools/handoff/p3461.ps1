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

# WHAT IS NEW SUBTITLE ON TOKENS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
max-width:440px;margin:0;font:800 56px/1.15 var(--f-cond);color:var(--tx-1);overflow-wrap:anywhere;}
'@ @'
max-width:440px;margin:0;font-family:var(--f-cond);font-weight:800;font-size:var(--fs-hero);line-height:1.15;color:var(--tx-1);overflow-wrap:anywhere;}
'@

SubRx @'
#root #wnmodal #wnsub{grid-column:1;grid-row:2;font-size:32px;max-width:none;}
'@ @'
#root #wnmodal #wnsub{grid-column:1;grid-row:2;font-size:var(--fs-title);max-width:none;}
'@

SubRx @'
var VER='34.60';
'@ @'
var VER='34.61';
'@

$pat = "(?m)^  now:'v34\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.61: No visible change. Check 34.61 fails on v34.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
