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

# PRE-RAID: ONE BUY SLOT ON EVERY PACK ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var o=packBuyOk(k); if(!o) return '';
'@ @'
var o=packBuyOk(k); if(!o) return '<span class="srbuy sp"></span>'; /* v28.xx (cw-packbuy2): a row with no buy keeps the slot so every stepper lines up */
'@

SubRx @'
min-width:76px; height:44px; padding:0 10px; background:var(--ui-raised); border:1px solid var(--acc); border-radius:0; color:var(--acc); font:700 18px var(--f-cond);
'@ @'
width:66px; min-width:0; height:44px; padding:0 4px; background:var(--ui-raised); border:1px solid var(--acc); border-radius:0; color:var(--acc); font:700 16px var(--f-cond);
'@

SubRx @'
#root #sectormodal .srprow .srbuy.dis{
'@ @'
#root #sectormodal .srprow span.srbuy.sp{ width:66px; height:44px; border:0; background:none; } #root #sectormodal .srprow .srbuy.dis{
'@

SubRx @'
var VER='33.46';
'@ @'
var VER='33.47';
'@

$pat = "(?m)^  now:'v33\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.47: The pack rows on the pre-raid page line up again. Check 33.47 fails on v33.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
