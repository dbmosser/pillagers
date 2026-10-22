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

# UNDERCROFT WINDOW FINISH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<style id="pix-fashion-fit">
'@ @'
<style id="uc-window-finish">
/* v28.xx (cw-cx-ucfinish): task 88, existing gambler and bar headers share the card edge; his centred card, one column and close control stay. */
#root #gamblemodal.modal.ui-win,#root #barmodal.modal.ui-win{justify-content:flex-start !important;align-items:center;gap:0;}
#root #gamblemodal > h3,#root #barmodal > h3{box-sizing:border-box;flex:none;align-self:stretch;width:100%;max-width:none;min-height:56px;margin:0 0 24px;padding:0 440px 16px 0;text-align:left;font:700 32px/1.2 var(--f-cond);letter-spacing:.02em;border-bottom:1px solid var(--ui-line);}
#root #gamblemodal > .ui-foot,#root #barmodal > .ui-foot{max-width:none !important;margin-top:auto !important;}
/* v28.xx (cw-cx-ucfinish): Q8, remove duplicate balance, vendor patter and empty-roll explanation; price stays on the existing gamble button and rolled items stay visible. */
#root #wallet_gamble,#root #gamble_line,#root #gamblelist > .hint:only-child{display:none !important;}
#root #gamblemodal #wirtsec_gamble,#root #gamblemodal #wirtsec_offer{box-sizing:border-box;flex:none;width:100%;max-width:1200px;padding:24px !important;border:1px solid var(--ui-line-hi) !important;background:var(--ui-panel) !important;}
#root #gamblemodal #wirtsec_gamble{margin:0 !important;}
#root #gamblemodal #wirtsec_offer{margin:24px 0 0 !important;border-left:3px solid var(--acc) !important;}
#root #gamblemodal #wirtsec_gamble > div:first-child,#root #gamblemodal #wirtsec_offer > div:first-child{font:600 16px/1.4 var(--f-cond) !important;letter-spacing:.04em !important;color:var(--tx-2) !important;margin-bottom:16px !important;}
#root #gamblemodal #gamblelist{max-width:none;max-height:240px !important;border:0 !important;font-size:20px;}
#root #gamblemodal #gamblelist .row{min-height:56px;font-size:20px;}
#root #gamblemodal #gamblebtn,#root #gamblemodal #wirtlotbtn{box-sizing:border-box;min-height:56px;min-width:240px;font:700 20px/1.4 var(--f-cond);letter-spacing:.04em;opacity:1 !important;}
#root #gamblemodal #gamblebtn{width:100%;}
#root #gamblemodal #gamblebtn:not(:disabled){background:var(--acc) !important;color:var(--acc-ink) !important;border-color:var(--acc) !important;}
#root #gamblemodal #gamblebtn:hover:not(:disabled){background:var(--acc-hover) !important;}
#root #gamblemodal #wirtlotbtn:not(:disabled){background:transparent !important;color:var(--tx-1) !important;border-color:var(--ui-line-hi) !important;}
#root #gamblemodal #gamblebtn:disabled,#root #gamblemodal #wirtlotbtn:disabled{background:var(--ui-raised) !important;color:var(--tx-2) !important;border:1px solid var(--danger) !important;}
#root #gamblemodal #gamblebtn[data-need]:not([data-need=""])::after,#root #gamblemodal #wirtlotbtn[data-need]:not([data-need=""])::after{font:600 16px/1.4 var(--f-cond);letter-spacing:.02em;color:#ff8a75;border:0;background:none;padding:0;margin-left:16px;}
#root #gamblemodal #gamblebtn:focus-visible,#root #gamblemodal #wirtlotbtn:focus-visible,#root #gamblemodal button.padfocus{outline:2px solid var(--acc) !important;outline-offset:4px;}
#root #gamblemodal #wirtlot{gap:24px !important;min-width:0;font-size:16px;}
#root #gamblemodal #wirtlot > span[title]{width:128px !important;height:128px !important;border-radius:4px !important;}
#root #gamblemodal #wirtlot > span[title] img{width:112px !important;height:112px !important;object-fit:contain;}
/* v28.xx (cw-cx-ucfinish): Q8, the section already says limited time offer; hide only its duplicate inside the item description. Item, worth and live minutes remain. */
#root #gamblemodal #wirtlot > span > span:first-child{display:none !important;}
#root #gamblemodal #wirtlot > span > span:nth-child(2){font:700 28px/1.25 var(--f-cond);margin-bottom:8px;}
#root #gamblemodal #wirtlot > span > span:nth-child(2) > span{font:400 16px/1.5 var(--f-body);display:block;}
#root #gamblemodal #wirtlot > span > span:nth-child(n+3){font-size:16px !important;color:var(--tx-2) !important;}
/* v28.xx (cw-cx-ucfinish): one further bar styling attempt, 56px action, 24px gap, filled current row; no drink words, effect or timing changed. */
#root #barmodal #bar_now:empty{display:none;}
#root #barmodal #bar_now{font-size:16px;line-height:1.5;}
#root #barmodal #barlist{box-sizing:border-box;margin-top:0;}
#root #barmodal #barlist .row{box-sizing:border-box;gap:24px;padding:24px 16px;border-left:3px solid transparent;}
#root #barmodal #barlist .row:has(button:is(.padfocus,:focus-visible,:hover)),#root #barmodal #barlist:not(:has(button:is(.padfocus,:focus-visible,:hover))) .row:first-child{background:var(--ui-raised);border-left-color:var(--acc);}
#root #barmodal #barlist button[data-bz]{min-height:56px !important;min-width:200px !important;font:700 20px/1.4 var(--f-cond) !important;letter-spacing:.04em;background:transparent !important;color:var(--tx-1) !important;border:1px solid var(--ui-line-hi) !important;}
#root #barmodal #barlist button[data-bz]:not(:disabled):is(.padfocus,:focus-visible,:hover),#root #barmodal #barlist:not(:has(button:is(.padfocus,:focus-visible,:hover))) .row:first-child button[data-bz]:not(:disabled){background:var(--acc) !important;color:var(--acc-ink) !important;border-color:var(--acc) !important;}
#root #barmodal #barlist button[data-bz]:is(.padfocus,:focus-visible){outline:2px solid var(--acc) !important;outline-offset:4px;}
#root #barmodal #barlist button[data-bz]:disabled{background:var(--ui-raised) !important;color:var(--tx-2) !important;}
/* v28.xx (cw-cx-ucfinish): stats use one filling four-column grid, 16px labels, one 56px hero and readable achievements. */
#root #opane_rec > h2{font:600 20px/1.4 var(--f-cond);color:var(--tx-1);letter-spacing:.04em;margin:0 0 16px;}
#root #opane_rec > h2 em{font-style:normal;color:var(--tx-2);}
#root #opane_rec #statgrid{grid-template-columns:repeat(4,minmax(0,1fr));gap:16px;width:100%;}
#root #opane_rec #statgrid > .scard{box-sizing:border-box;grid-column:auto;padding:16px;min-height:136px;border-color:var(--ui-line-hi);background:var(--ui-panel);border-radius:4px;}
#root #opane_rec #statgrid > .scard.wide,#root #opane_rec #statgrid > .scard:nth-child(7){grid-column:span 2;}
#root #opane_rec .scard .sk{font:600 16px/1.25 var(--f-cond);letter-spacing:.04em;color:var(--tx-2);min-height:40px;}
#root #opane_rec .scard .sv{font:700 32px/1.15 var(--f-cond);color:var(--tx-1);min-height:36.8px;}
#root #opane_rec .scard .sv.word{min-height:36.8px;}
#root #opane_rec .scard:nth-child(7) .sv{font-size:56px;font-weight:800;color:var(--acc);}
#root #opane_rec .scard .ss{font-size:16px;line-height:1.5;color:var(--tx-2);}
#root #opane_rec .scard .ss b{color:var(--tx-1);}
/* v28.xx (cw-cx-ucfinish): Q8, best haul already says ever and net lifetime earnings names its measure; remove their repeated explanations. Keep live proficiency parts and notoriety consequences. */
#root #opane_rec .scard:nth-child(4) .ss,#root #opane_rec .scard:nth-child(6) .ss{display:none;}
#root #opane_rec #achlist{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:0 24px;}
#root #opane_rec #achlist > div:first-child{grid-column:1/-1;font:600 20px/1.4 var(--f-cond) !important;letter-spacing:.04em !important;color:var(--tx-1) !important;margin-bottom:8px !important;}
#root #opane_rec #achlist > div:not(:first-child){display:grid !important;grid-template-columns:minmax(0,1fr) minmax(0,1.3fr);gap:16px !important;padding:12px 0 !important;border-bottom:1px solid var(--ui-line);font-size:16px !important;line-height:1.4;color:var(--tx-2) !important;}
#root #opane_rec #achlist > div > span{width:auto !important;min-width:0;}
#root #opane_rec .crlab,#root #opane_rec .runline{font-size:16px;letter-spacing:.04em;}
/* v28.xx (cw-cx-ucfinish): keep the existing toast inside these three cards, 24px above their lower edge. */
body:has(#gamblemodal.on,#barmodal.on,#opane_rec[style*="display: flex"]) #hubtoast{bottom:calc(5vh + 24px);font-size:16px;}
@media(max-width:1100px){
  #root #gamblemodal > h3,#root #barmodal > h3{padding-right:360px;}
  #root #gamblemodal #wirtlot{flex-wrap:wrap;}
  #root #gamblemodal #wirtlotbtn{width:100%;}
  #root #opane_rec #statgrid{grid-template-columns:repeat(2,minmax(0,1fr));}
  #root #opane_rec #achlist{grid-template-columns:minmax(0,1fr);}
}
</style>
<style id="pix-fashion-fit">
'@

SubRx @'
var VER='33.96';
'@ @'
var VER='33.97';
'@

$pat = "(?m)^  now:'v33\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.97: Aligned headers, readable actions, a filling stats grid and one clear hero value in the existing windows. Check 33.97 fails on v33.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
