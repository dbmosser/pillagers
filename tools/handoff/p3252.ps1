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

# PRE-RAID: SHARP MAP NAMES, A QUIET SELECTED STATE, ROWS THAT FILL THE PACK, A SMALLER ASCEND PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
width="640" height="'+Math.round(640*M.h/M.w)+'"
'@ @'
width="960" height="'+Math.round(960*M.h/M.w)+'"
'@

SubRx @'
#root #sectormodal .srchip.on, #root #sectormodal .kitb.on{ background:rgba(230,255,61,.16); border-color:var(--acc); box-shadow:inset 0 0 0 1px var(--acc); color:var(--tx-1); }
'@ @'
#root #sectormodal .srchip.on, #root #sectormodal .kitb.on{ background:var(--ui-hover); border-color:var(--ui-line-hi); box-shadow:inset 3px 0 0 var(--acc); color:var(--tx-1); }
'@

SubRx @'
#sectormodal .srprow{ height:46px; display:flex;
'@ @'
#sectormodal .srprow{ flex:1 0 46px; max-height:58px; display:flex;
'@

SubRx @'
#sectormodal .srprow.g{ margin-top:6px; }
'@ @'
#sectormodal .srprow.g{ margin-top:0; border-top:1px solid var(--ui-line-hi); }
'@

SubRx @'
#sectormodal .srplist{ flex:1 1 auto; min-height:0; overflow-y:auto; }
'@ @'
#sectormodal .srplist{ flex:1 1 auto; min-height:0; overflow-y:auto; display:flex; flex-direction:column; }
'@

SubRx @'
#sectormodal .srplate{ flex:none; height:72px;
'@ @'
#sectormodal .srplate{ flex:none; height:60px;
'@

SubRx @'
font:800 52px/1 var(--f-cond); letter-spacing:.05em; }
'@ @'
font:800 44px/1 var(--f-cond); letter-spacing:.05em; }
'@

SubRx @'
border:1px solid var(--ui-line-hi); background:none; border-radius:4px; color:var(--warn);
'@ @'
border:0; background:none; border-radius:0; color:var(--warn);
'@

SubRx @'
border:1px solid var(--acc); background:rgba(230,255,61,.16); border-radius:4px; font:600 20px var(--f-cond); color:var(--tx-1); }
'@ @'
border:1px solid var(--ui-line-hi); background:none; border-radius:4px; font:600 20px var(--f-cond); color:var(--tx-1); }
'@

SubRx @'
var VER='32.51';
'@ @'
var VER='32.52';
'@

$pat = "(?m)^  now:'v32\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.52: The pre-raid page has crisp map names, calmer selected chips, an evenly spaced pack and a smaller ascend button. Check 32.52 fails on v32.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
