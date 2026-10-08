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

# THE RACKS PAGE IS READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div id="mfstatus" style="padding:6px 12px;font-size:11px"></div>
'@ @'
<!-- v20.22, seen on the 4K Mainframe screenshots (2026-10-08): the RACKS page was 11px throughout; 14 now --><div id="mfstatus" style="padding:6px 12px;font-size:14px"></div>
'@

SubRx @'
<div id="mfhint" class="hint" style="margin-top:5px;font-size:11px;line-height:1.4"></div>
'@ @'
<div id="mfhint" class="hint" style="margin-top:5px;font-size:14px;line-height:1.4"></div>
'@

SubRx @'
<div id="mfarrayhint" class="hint" style="margin-top:5px;font-size:11px;line-height:1.4"></div>
'@ @'
<div id="mfarrayhint" class="hint" style="margin-top:5px;font-size:14px;line-height:1.4"></div>
'@

SubRx @'
<div id="mfslothint" class="hint" style="margin-top:5px;font-size:11px;line-height:1.4"></div>
'@ @'
<div id="mfslothint" class="hint" style="margin-top:5px;font-size:14px;line-height:1.4"></div>
'@

SubRx @'
<div id="mfghosthint" class="hint" style="margin-top:5px;font-size:11px;line-height:1.4"></div>
'@ @'
<div id="mfghosthint" class="hint" style="margin-top:5px;font-size:14px;line-height:1.4"></div>
'@

SubRx @'
<input id="mfghostname" placeholder="friend&#39;s name" maxlength="18"
        style="flex:1;background:rgba(9,14,40,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:'Rubik',system-ui,sans-serif;font-size:12px;padding:6px">
'@ @'
<input id="mfghostname" placeholder="friend&#39;s name" maxlength="18"
        style="flex:1;background:rgba(9,14,40,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:'Rubik',system-ui,sans-serif;font-size:14px;padding:7px">
'@

SubRx @'
var VER='20.21';
'@ @'
var VER='20.22';
'@

$pat = "(?m)^  now:'v20\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.22: The Mainframe RACKS page is easier to read. Check 20.22 fails on v20.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
