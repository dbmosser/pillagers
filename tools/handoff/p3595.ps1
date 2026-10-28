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

# THE RUN CARDS FIT AT 4K: KIA TABLES SIDE BY SIDE, DAMAGE IN TWO COLUMNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    DEATH_FEED_HTML=(DEATH_FEED_HTML||'')+recapHtml(T);   // v23.xx (feat3a): DAMAGE TAKEN
'@ @'
    DEATH_FEED_HTML=(DEATH_FEED_HTML||'')+recapHtml(T);   // v23.xx (feat3a): DAMAGE TAKEN
    if(DEATH_FEED_HTML) DEATH_FEED_HTML='<div class="ockia">'+DEATH_FEED_HTML+'</div>';   // v35.xx (cw-endcards): HOW IT WENT and DAMAGE TAKEN side by side (CSS ockia)
'@

SubRx @'
           '<span style="width:92px;text-align:right;opacity:.7">'+fmtMS(e.t)+'</span>'+
'@ @'
           '<span style="width:92px;text-align:right;opacity:.7">'+(Math.floor(Math.max(0,e.t)/60)+':'+('0'+(Math.max(0,e.t)%60)).slice(-2))+'</span>'+   // v35.xx (cw-endcards): 2:24, as the card's time stat reads, so the side by side table fits
'@

SubRx @'
  '#root #oc_manifest .ocrecap>div>div:first-child{letter-spacing:.14em;color:var(--tx-2,#aaa498) !important}');
'@ @'
  '#root #oc_manifest .ocrecap>div>div:first-child{letter-spacing:.14em;color:var(--tx-2,#aaa498) !important}'+
  // v35.xx (cw-endcards), menus master pass 2026-10-28: at 4K a hit history made the KIA card taller than the screen, so its stats and the run feel button slid
  // under the log run button, and the extracted card's DAMAGE TAKEN footnote sat under it with many guns recovered. On the KIA card HOW IT WENT and DAMAGE TAKEN
  // sit side by side at the 16px body size, names left aligned (11.5px rows, stacked, names centred); on the EXTRACTED card the sources take two columns.
  '#root #oc_manifest .ockia{display:grid;grid-template-columns:minmax(0,1.15fr) minmax(0,1fr);column-gap:24px;align-items:start;width:100%;margin:0 0 8px;text-align:left}'+
  '#root #oc_manifest .ockia>div{margin-top:0 !important}'+
  '#root #oc_manifest .ockia>div>div{font-size:16px !important;letter-spacing:.02em}'+
  '#root #oc_manifest .ockia>div>div:first-child{letter-spacing:.14em;color:var(--tx-2,#aaa498) !important}'+
  '#root #oc_manifest .ockia>div:first-child>div:nth-child(2){font-size:14px !important;letter-spacing:.06em}'+
  '#root #oc_manifest .ockia>div:first-child>div>span:nth-child(1){width:44px !important;text-align:left !important}'+
  '#root #oc_manifest .ockia>div:first-child>div>span:nth-child(3){width:60px !important}'+
  '#root #oc_manifest .ockia>div:first-child>div>span:nth-child(4){width:64px !important;white-space:nowrap}'+
  '#root #oc_manifest .ockia>div:last-child>div>span:nth-child(2){width:40px !important}'+
  '#root #oc_manifest .ockia>div:last-child>div>span:nth-child(3){width:auto !important;min-width:44px;white-space:nowrap}'+
  '#root #oc_manifest:has(.ockia) .ocloss{margin-top:8px}#root #oc_manifest:has(.ockia) .octiles{margin-bottom:16px}#root #oc_manifest:has(.ockia) .ocstat{margin-bottom:8px}'+
  '#root #oc_manifest:has(.ockia) span:empty+br{display:none}'+
  '#root #oc_manifest .ocrecap>div{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));column-gap:24px}'+
  '#root #oc_manifest .ocrecap>div>div:first-child{grid-column:1 / -1}'+
  '#root #oc_manifest .ocrecap>div>div>span:last-child{width:auto !important;min-width:48px;white-space:nowrap}');
'@

SubRx @'
var VER='35.94';
'@ @'
var VER='35.95';
'@

$pat = "(?m)^  now:'v35\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.95: the kia card tables sit side by side and the extracted damage list fits above the button Check 35.95 fails on v35.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
