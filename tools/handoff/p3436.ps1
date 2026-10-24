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

# Wirt panels fit their content, labels at body size (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<style id="mf-racks-rewards">
'@ @'
<style id="uc-gamble-card2">
/* v34.xx (cw-gamblecard2), task 108 second pass, picture of v34.34: the two panels were stretched the whole card height, so each held a void between a tiny label and its button. Now they are as tall as their content (item, name, button) under the header, the section labels are the 20px body size in tx-1 so the eye reads what each panel is, and the roll list keeps a 200px area. Looks only. */
#root #gamblemodal.modal.ui-win.on{grid-template-rows:auto auto minmax(0,1fr);}
#root #gamblemodal > .ui-foot{grid-row:3;}
#root #gamblemodal #wirtsec_gamble > div:first-child,#root #gamblemodal #wirtsec_offer > div:first-child{font-size:20px !important;color:var(--tx-1) !important;}
#root #gamblemodal #gamblelist{min-height:200px;}
</style><style id="mf-racks-rewards">
'@

SubRx @'
var VER='34.35';
'@ @'
var VER='34.36';
'@

$pat = "(?m)^  now:'v34\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.36: Wirt window panels no longer run to the bottom of the card. Check 34.36 fails on v34.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
