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

# PRE RAID PACK SCROLL SPACE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #sectormodal #sectorpack{flex:1 1 auto;min-height:150px;padding:8px 0;border-top:1px solid var(--ui-line);border-bottom:1px solid var(--ui-line)}
'@ @'
/* v28.xx (cw-cx-preraid-scroll): reserve rows as well as the belt at 4K; an unsold item has a dash, while an unaffordable price stays readable inside a danger border. */
#root #sectormodal #sectorpack{flex:1 0 280px;min-height:280px;padding:8px 0;border-top:1px solid var(--ui-line);border-bottom:1px solid var(--ui-line)}
#root #sectormodal #sectorpack .srplist{min-height:120px;padding-right:8px;scrollbar-gutter:stable}
#root #sectormodal #sectorpack .srbuy.dis{opacity:1;color:var(--tx-1);border-color:var(--danger)}
#root #sectormodal #sectorpack .srbuy.sp{display:grid;place-items:center}
#root #sectormodal #sectorpack .srbuy.sp::after{content:'-';color:var(--tx-2);font:600 16px var(--f-cond)}
#root #sectormodal #srside{overflow-y:auto;padding-right:4px}
/* v28.xx (cw-cx-preraid-scroll): viewport units also grow under menu zoom; divide the pre-raid card margins by that zoom so the 4K card keeps its chosen 5 percent margins. */
#root #sectormodal.modal.ui-win{padding:calc(5vh / var(--sectorzoom,1) + 22px) calc(5vw / var(--sectorzoom,1) + 22px)!important}
#root #sectormodal.modal.ui-win::before{inset:calc(5vh / var(--sectorzoom,1)) calc(5vw / var(--sectorzoom,1))!important}
#root #sectormodal > .ui-foot > .ui-back{top:calc(5vh / var(--sectorzoom,1) + 12px)!important;right:calc(5vw / var(--sectorzoom,1) + 16px)!important}
'@

SubRx @'
    m.style.zoom=(m.id==='hub')?(_sf*0.92):_sf;
'@ @'
    m.style.zoom=(m.id==='hub')?(_sf*0.92):_sf;
    if(m.id==='sectormodal') m.style.setProperty('--sectorzoom',String(_sf));   // v28.xx (cw-cx-preraid-scroll): the pre-raid card keeps its 5 percent physical margins under menu zoom.
'@

SubRx @'
var VER='36.05';
'@ @'
var VER='36.06';
'@

$pat = "(?m)^  now:'v36\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.06: The pack reserves 120 px for scrolling rows above the belt. The pre-raid card keeps its chosen 5 percent physical margins at 4K. Prices use primary text with a danger border when unaffordable; unsold slots show a dash. Scrollbars have 8 px clearance and the condition list scrolls inside its panel. Map type, Terms and rewards stay as chosen. Watch: at 4K scroll the pack and condition column, and reach ascend in the right column. Check 36.06 fails on v36.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
