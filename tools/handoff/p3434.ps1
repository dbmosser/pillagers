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

# Wirt window fills its card with two panels and one lime primary (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<style id="mf-racks-rewards">
'@ @'
<style id="uc-gamble-card">
/* v34.xx (cw-gamblecard), task 108, critic 2 on screen 11 ("the gamble panel is a big title over a void with a small grey button, nothing on screen is the clear primary action, and the bottom third is dead space"). Looks only: the two existing panels sit side by side and fill the card (offer item bigger, both buttons on the panel floor), the inner 64px heading is the 16px section label (one title: the window title), the gamble button is the one lime 56px primary when affordable and the quiet raised style with its red need line when not, pad focus is a 3px lime ring. No readout, price, roll or save changes. */
#root #gamblemodal.modal.ui-win.on{display:grid !important;grid-template-columns:minmax(0,1fr) minmax(0,1fr);grid-template-rows:auto minmax(0,1fr) auto;column-gap:24px;row-gap:0;align-items:stretch !important;justify-content:flex-start !important;}
#root #gamblemodal > h3,#root #gamblemodal > .ui-foot{grid-column:1 / -1;}
#root #gamblemodal #wirtsec_gamble,#root #gamblemodal #wirtsec_offer{grid-row:2;display:flex !important;flex-direction:column;align-items:stretch !important;box-sizing:border-box;width:auto !important;max-width:none !important;min-height:0 !important;margin:0 !important;padding:24px !important;}
#root #gamblemodal #wirtsec_offer{border-left:1px solid var(--ui-line-hi) !important;}
#root #gamblemodal #wirtsec_gamble > div:first-child,#root #gamblemodal #wirtsec_offer > div:first-child{font:600 16px/1.4 var(--f-cond) !important;letter-spacing:.04em !important;color:var(--tx-2) !important;margin:0 0 24px !important;}
#root #gamblemodal #gamblelist{flex:1 1 auto;min-height:0;max-height:none !important;width:100%;overflow:auto;}
#root #gamblemodal #wirtsec_gamble > div:last-child{flex:none;min-height:0;margin:24px 0 0 !important;padding-bottom:32px;display:flex;align-items:flex-start;}
#root #gamblemodal #gamblebtn{position:relative;flex:none;width:100% !important;min-width:0;min-height:56px;font-size:20px;}
#root #gamblemodal #gamblebtn:disabled{background:var(--ui-raised) !important;color:var(--tx-2) !important;border:1px solid var(--ui-line-hi) !important;}
#root #gamblemodal #wirtlot{flex:1 1 auto;display:flex !important;flex-direction:column;align-items:stretch !important;gap:24px !important;min-height:0;}
#root #gamblemodal #wirtlot > span[title]{align-self:center;width:192px !important;height:192px !important;}
#root #gamblemodal #wirtlot > span[title] img{width:176px !important;height:176px !important;}
#root #gamblemodal #wirtlot > span:not([title]){flex:1 1 auto;}
#root #gamblemodal #wirtlotbtn{position:relative;flex:none;width:100%;min-width:0;min-height:56px;margin-bottom:32px;}
#root #gamblemodal #gamblebtn[data-need]:not([data-need=""])::after,#root #gamblemodal #wirtlotbtn[data-need]:not([data-need=""])::after{position:absolute;top:calc(100% + 8px);left:0;right:0;margin:0;text-align:left;font-size:16px;line-height:1.4;display:block;}
#root #gamblemodal #gamblebtn:focus-visible,#root #gamblemodal #wirtlotbtn:focus-visible,#root #gamblemodal button.padfocus{outline:3px solid var(--acc) !important;outline-offset:2px;}
</style><style id="mf-racks-rewards">
'@

SubRx @'
var VER='34.33';
'@ @'
var VER='34.34';
'@

$pat = "(?m)^  now:'v34\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.34: Wirt window uses the whole card and the gamble button is the clear main action. Check 34.34 fails on v34.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
