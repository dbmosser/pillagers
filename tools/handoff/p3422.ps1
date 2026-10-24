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

# Welcome pack and party card: one primary, an X, no explaining lines (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #partymodal textarea{ font-size:16px; }
'@ @'
#root #partymodal textarea{ font-size:16px; }
/* v34.22 (cw-wpcard), the critic on 02 and 07 (both 2 of 5): "explaining paragraph, rarity-coloured names, a bare close button with no X, buttons 680px apart" and "a small column of text floating in a 90 percent card, a lime sentence, no main action, a tall empty textarea". Welcome pack: no intro line, no stash hints, one 72px row per item (64px icon tile, 3px rarity bar, name in tx-1, count at the right edge), one lime primary at the right, an X in the card corner instead of the close button (same button, same esc). Party: a fitted 960 card like the welcome pack, title left, one short grey status line, host a party the lime primary, the invite field one 56px line with join beside it, the trade line gone (it is not a party action). His words and what the pack gives are untouched. Restyle only. */
#root #welcomemodal .msub{ display:none; }
#root #welcomelist .row{ height:72px; box-sizing:border-box; padding:0; align-items:center; border-bottom:1px solid var(--ui-line); }
#root #welcomelist .row:last-child{ border-bottom:0; }
#root #welcomelist .row .hint{ display:none; }
#root #welcomelist .row canvas.wpic{ width:56px; height:56px; padding:3px; box-sizing:content-box; background:var(--ui-raised); border:1px solid var(--ui-line-hi); border-radius:var(--rad); }
#root #welcomelist .row > div{ display:flex; align-items:center; }
#root #welcomelist .row b{ -webkit-text-fill-color:var(--tx-1); display:flex; align-items:center; gap:12px; font-size:20px; }
#root #welcomelist .row b::before{ content:''; width:3px; height:28px; background:currentColor; flex:none; }
#root #welcomelist .row .wq{ margin-left:auto; font-size:20px; color:var(--tx-2); font-weight:700; }
#root #welcomemodal > .ui-foot{ justify-content:flex-end; }
#root #welcomemodal > .ui-foot > #welcomeno, #root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back{ position:absolute; top:calc(50% - var(--cfh,840px) / 2 + var(--sp-2)); right:calc(50% - 480px + var(--sp-2)); bottom:auto; z-index:5; width:var(--sp-5); height:var(--sp-5); min-width:0 !important; min-height:0 !important; padding:0 !important; margin:0 !important; font-size:0 !important; display:flex; align-items:center; justify-content:center; background:transparent; border:1px solid var(--ui-line-hi); }
#root #welcomemodal > .ui-foot > #welcomeno::after, #root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back::after{ content:''; --xc:var(--tx-2); width:var(--sp-3); height:var(--sp-3); background:linear-gradient(45deg, transparent 44%, var(--xc) 44% 56%, transparent 56%), linear-gradient(-45deg, transparent 44%, var(--xc) 44% 56%, transparent 56%); }
#root #welcomemodal > .ui-foot > #welcomeno:hover::after, #root #welcomemodal > .ui-foot > #welcomeno:focus-visible::after, #root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back:hover::after, #root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back:focus-visible::after{ --xc:var(--tx-1); }
#root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back{ top:calc(50% - var(--cfh,440px) / 2 + var(--sp-2)); }
#root #partymodal.ui-win:not(#zz1):not(#zz2)::before{ inset:50% auto auto 50%; width:min(960px,calc(100% - 28px)); height:min(var(--cfh,440px),calc(100% - 28px)); transform:translate(-50%,-50%); }
#root #partymodal.ui-win:not(#zz1):not(#zz2){ padding:0 max(14px, calc(50% - 440px)); }
#root #partymodal h3{ text-align:left; width:100%; font-size:32px; }
#root #partymodal .msub{ font-size:16px; color:var(--tx-2); }
#root #partymodal #partystat{ color:var(--tx-2) !important; font-weight:400 !important; }
#root #partymodal #partytrade{ display:none; }
#root #partymodal #partystart{ flex-wrap:nowrap; gap:var(--sp-2); align-items:stretch; margin-top:var(--sp-3); }
#root #partymodal #partystart > div{ display:flex; gap:var(--sp-2); align-items:stretch; min-width:0; }
#root #partymodal #partyin{ flex:1; min-width:0; width:auto; height:var(--btn-h); min-height:var(--btn-h); resize:none; padding:var(--sp-2); box-sizing:border-box; margin:0; }
#root #partymodal #partyhost, #root #partymodal #partyjoin{ min-height:var(--btn-h); min-width:200px; font-size:20px; margin:0 !important; }
#root #partymodal #partyhost{ background:var(--acc); color:var(--acc-ink); border-color:var(--acc); }
#root #partymodal #partyhost:focus-visible, #root #welcometake:focus-visible{ outline:2px solid var(--tx-1); outline-offset:3px; }
'@

SubRx @'
it.name+(counts[k]>1?' x'+counts[k]:'')+'</b><div class="hint">to your stash</div>
'@ @'
it.name+'</b>'+(counts[k]>1?'<span class="wq">x'+counts[k]+'</span>':'')+'<div class="hint">to your stash</div>
'@

SubRx @'
placeholder="To join, paste the invite code your host sent you. It starts PTY1o."
'@ @'
placeholder="invite code"
'@

SubRx @'
'Not in a party. Host one, or paste an invite code from a friend.'
'@ @'
'Not in a party.'
'@

SubRx @'
var VER='34.21';
'@ @'
var VER='34.22';
'@

$pat = "(?m)^  now:'v34\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.22: The welcome pack and the party card are cleaner: one lime button, an X in the corner, no explaining lines. Check 34.22 fails on v34.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
