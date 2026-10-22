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

# UNDERCROFT BODY READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<style id="pix-fashion-fit">
'@ @'
<style id="uc-window-body">
/* v28.xx (cw-cx-ucbody): task 88, second visual attempt on gambler/stats; keep the centred card, one common edge and all existing controls. */
#root #gamblemodal #wirtsec_gamble{display:flex;flex-direction:column;align-items:flex-start;min-height:320px;}
#root #gamblemodal #wirtsec_gamble > div:first-child{font-size:64px !important;line-height:1.05 !important;font-weight:700 !important;letter-spacing:0 !important;color:var(--tx-1) !important;margin-bottom:16px !important;}
#root #gamblemodal #gamblelist{width:100%;flex:1 1 auto;min-height:0;font-size:22px;}
#root #gamblemodal #wirtsec_gamble > div:last-child{flex:none;width:100%;min-height:104px;box-sizing:border-box;padding-bottom:40px;align-items:flex-start;margin-top:16px !important;}
#root #gamblemodal #gamblebtn{position:relative;flex:none;width:320px !important;max-width:100%;min-width:0;min-height:64px;font-size:24px;}
#root #gamblemodal #gamblebtn:disabled,#root #gamblemodal #wirtlotbtn:disabled{border-color:var(--ui-line-hi) !important;color:var(--tx-1) !important;}
#root #gamblemodal #gamblebtn[data-need]:not([data-need=""])::after{position:absolute;top:calc(100% + 8px);left:0;right:0;margin:0;text-align:left;font-size:18px;line-height:1.4;}
#root #gamblemodal #wirtlotbtn[data-need]:not([data-need=""])::after{display:block;margin:4px 0 0;font-size:18px;}
#root #gamblemodal #wirtsec_offer > div:first-child{font-size:20px !important;color:var(--tx-1) !important;}
#root #gamblemodal #wirtlot > span > span:nth-child(2){font-size:36px;}
#root #gamblemodal #wirtlot > span > span:nth-child(2) > span,#root #gamblemodal #wirtlot > span > span:nth-child(n+3){font-size:20px !important;}
/* v28.xx (cw-cx-ucbody): compensate for menu zoom so the visible label size clears 16px at 1080; keep one lime experience hero, as the style guide permits for a hero number. */
#root #opane_rec .scard .sk{font-size:20px;min-height:50px;}
#root #opane_rec .scard .ss{font-size:20px;line-height:1.4;}
#root #opane_rec .scard .sv{font-size:36px;min-height:41.4px;}
#root #opane_rec .scard .sv.word{min-height:41.4px;}
#root #opane_rec .scard:nth-child(7) .sv{font-size:64px;}
/* v28.xx (cw-cx-ucbody): Q8, with no logged runs the heading already says zero. Fold only the undefined/repeated run metrics and their empty explanations; the first real log row restores every metric automatically. */
#root #opane_rec:not(:has(#loglist .runline)) #statgrid > .scard:nth-child(-n+14):not(:nth-child(6)):not(:nth-child(7)):not(:nth-child(8)){display:none;}
#root #opane_rec:not(:has(#loglist .runline)) #statgrid > .scard:nth-child(7){order:-2;}
#root #opane_rec:not(:has(#loglist .runline)) #statgrid > .scard:nth-child(8){order:-1;grid-column:span 1;}
#root #opane_rec:not(:has(#loglist .runline)) #statgrid > .scard:nth-child(6){grid-column:span 1;}
#root #opane_rec:not(:has(#loglist .runline)) > #loglist,#root #opane_rec:not(:has(#loglist .runline)) > .crlab{display:none !important;}
#root #opane_rec .scard:nth-child(5) .ss:not(:has(br)){display:none;}
/* v28.xx (cw-cx-ucbody): existing achievement name/goal pairs read as two columns of cards rather than four loose text cells; preserve earned state through its green edge. */
#root #opane_rec #achlist{gap:12px 16px;}
#root #opane_rec #achlist > div:not(:first-child){display:flex !important;flex-direction:column;gap:4px !important;min-height:76px;box-sizing:border-box;padding:12px 16px !important;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-left:3px solid var(--ui-line-hi);font-size:20px !important;}
#root #opane_rec #achlist > div:not(:first-child) > span{flex:none !important;}
#root #opane_rec #achlist > div:not(:first-child) > span:first-child{font:600 22px/1.2 var(--f-cond);color:var(--tx-1);}
#root #opane_rec #achlist > div[style*="var(--amber)"]{border-left-color:var(--ok);}
/* v28.xx (cw-cx-ucbody): a toast may cross the outer margin (style guide section 3); put it above these two cards so it cannot cover a goal or a control. Bar is already finished and is not restyled. */
body:has(#gamblemodal.on) #hubtoast,body:has(#opmodal.on #opane_rec[style*="display: flex"]) #hubtoast{top:4px;bottom:auto;padding:6px 16px;font-size:18px;line-height:1.2;background:var(--ui-raised);}
@media(max-width:1100px){
  #root #opane_rec:not(:has(#loglist .runline)) #statgrid > .scard:nth-child(7),#root #opane_rec:not(:has(#loglist .runline)) #statgrid > .scard:nth-child(8),#root #opane_rec:not(:has(#loglist .runline)) #statgrid > .scard:nth-child(6){grid-column:1/-1;}
}
</style>
<style id="pix-fashion-fit">
'@

SubRx @'
var VER='33.97';
'@ @'
var VER='33.98';
'@

$pat = "(?m)^  now:'v33\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.98: A large gamble heading and compact action, readable stats and paired achievements, with empty metrics folded until a real run exists. Check 33.98 fails on v33.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
