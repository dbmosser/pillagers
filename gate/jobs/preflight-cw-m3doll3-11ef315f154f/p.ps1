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

# THE STASH DOLL: LONG NAMES WRAP IN A SLOT, THE LIST FADES AT ITS EDGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  '#root #gearmodal #gearlist{flex:1;min-height:0;display:flex;flex-direction:column;gap:8px;overflow-y:auto;overflow-x:hidden;padding:2px}'+
'@ @'
  // v37.xx (cw-m3doll3), critic P1: the last row was cut mid word by the list edge, so the list fades out over its last 24px; a row the highlight lands on stops clear of the fade. Critic P2: the thumb is the panel line colour, not amber.
  '#root #gearmodal #gearlist{flex:1;min-height:0;display:flex;flex-direction:column;gap:8px;overflow-y:auto;overflow-x:hidden;padding:2px 2px 24px;scroll-padding-bottom:24px;scrollbar-color:var(--ui-line-hi) transparent;-webkit-mask-image:linear-gradient(to bottom,#000 calc(100% - 24px),transparent);mask-image:linear-gradient(to bottom,#000 calc(100% - 24px),transparent)}'+
'@

SubRx @'
  '#root #gearmodal .gslot b{font:700 24px/1.1 var(--f-cond);color:var(--gc);white-space:nowrap}'+
'@ @'
  '#root #gearmodal .gslot b{font:700 24px/1.1 var(--f-cond);color:var(--gc);white-space:normal}'+
'@

SubRx @'
  '#root #gearmodal .gofb b{font:700 var(--fs-body)/1 var(--f-cond);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}'+
'@ @'
  '#root #gearmodal .gofb b{font:700 var(--fs-body)/1.25 var(--f-cond);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}'+
'@

SubRx @'
  '#root #gearmodal #geartip{flex:none;height:248px;overflow:hidden;background:var(--ui-raised)}'+
'@ @'
  '#root #gearmodal #geartip{flex:none;height:248px;overflow:hidden;background:var(--ui-bg)}'+
'@

SubRx @'
var VER='37.47';
'@ @'
var VER='37.48';
'@

$pat = "(?m)^  now:'v37\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.48: a long piece name wraps to two lines in its slot, outfit names show whole, the tip panel is darker so worse reads, the list fades out at its bottom edge and its scroll thumb is the panel line colour Check 37.48 fails on v37.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
