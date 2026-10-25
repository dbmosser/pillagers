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

# PLAY DATA TEXT RULES ON TOKENS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
padding:16px;font:400 16px/24px var(--f-body);color:var(--tx-2);border:1px solid var(--ui-line-hi);text-transform:lowercase !important;resize:none;}
'@ @'
padding:16px;font-family:var(--f-body);font-weight:400;font-size:var(--fs-label);line-height:24px;color:var(--tx-2);border:1px solid var(--ui-line-hi);text-transform:lowercase !important;resize:none;}
'@

SubRx @'
font:400 var(--fs-body)/28px var(--f-body);color:var(--tx-1);padding-bottom:24px;white-space:pre-wrap;overflow-wrap:anywhere;scrollbar-width:thin;scrollbar-color:var(--ui-line-hi) var(--ui-bg);-webkit-mask-image:linear-gradient(to bottom,#000 calc(100% - 24px),transparent);mask-image:linear-gradient(to bottom,#000 calc(100% - 24px),transparent);}
'@ @'
font-family:var(--f-body);font-weight:400;font-size:var(--fs-body);line-height:28px;color:var(--tx-1);padding-bottom:24px;white-space:pre-wrap;overflow-wrap:anywhere;scrollbar-width:thin;scrollbar-color:var(--ui-line-hi) var(--ui-bg);-webkit-mask-image:linear-gradient(to bottom,black calc(100% - 24px),transparent);mask-image:linear-gradient(to bottom,black calc(100% - 24px),transparent);}
'@

SubRx @'
padding:16px 16px 22px;line-height:24px;-webkit-mask-image:linear-gradient(to bottom,#000 calc(100% - 8px),transparent);mask-image:linear-gradient(to bottom,#000 calc(100% - 8px),transparent);}
'@ @'
padding:16px 16px 22px;line-height:24px;-webkit-mask-image:linear-gradient(to bottom,black calc(100% - 8px),transparent);mask-image:linear-gradient(to bottom,black calc(100% - 8px),transparent);}
'@

SubRx @'
var VER='34.57';
'@ @'
var VER='34.58';
'@

$pat = "(?m)^  now:'v34\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.58: No visible change. Check 34.58 fails on v34.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
