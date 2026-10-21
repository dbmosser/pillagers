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

# PUBLIC REPORT AND NEWS READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-cx-o91b-newsreport): critic on the public recorder, 10-21: cap the raw preview, keep copy primary and use the shared text sizes. Copy and restore still use the original data. The 130 percent default menu scale turns this preview cap into 240 screen pixels at 1080p. */
#root #settingsmodal.recmode #spane_rec{max-width:1320px;margin:0;width:100%;min-height:0;overflow:auto;box-sizing:border-box;padding:24px 0;align-self:flex-start;justify-content:flex-start;}
#root #settingsmodal.recmode #spane_rec > .msub{display:block !important;font-size:var(--fs-body);line-height:1.4;color:var(--tx-2);margin:0 0 16px;}
#root #settingsmodal.recmode #exporttext{flex:none !important;min-height:calc(240px / 1.3) !important;height:calc(240px / 1.3);max-height:calc(240px / 1.3);box-sizing:border-box;padding:16px;font:400 16px/24px var(--f-body);color:var(--tx-2);border:1px solid var(--ui-line-hi);text-transform:lowercase !important;resize:none;}
#root #settingsmodal.recmode #exporttext + div{gap:16px !important;margin-top:16px !important;align-items:center;}
#root #settingsmodal.recmode #copybtn{height:56px;min-height:56px;min-width:200px;padding:0 32px !important;font-size:var(--fs-body);font-weight:700;background:var(--acc);color:var(--acc-ink);border-color:var(--acc);}
#root #settingsmodal.recmode #wipelog{height:56px;min-height:56px;padding:0 24px !important;font-size:var(--fs-label);background:transparent;color:var(--tx-2) !important;border-color:var(--ui-line-hi) !important;}
#root #settingsmodal.recmode #wipelog:hover,#root #settingsmodal.recmode #wipelog:focus-visible,#root #settingsmodal.recmode #wipelog.padfocus{color:var(--danger) !important;border-color:var(--danger) !important;}
#root #settingsmodal.recmode #exporttext + div + div{margin-top:32px !important;padding-top:24px !important;padding-bottom:24px;}
#root #settingsmodal.recmode #exporttext + div + div > div:first-child{font-size:var(--fs-label) !important;line-height:24px;color:var(--tx-2) !important;letter-spacing:var(--track) !important;margin-bottom:8px;}
#root #settingsmodal.recmode #rescode{box-sizing:border-box;height:56px;min-height:56px;padding:12px 16px;border:1px solid var(--ui-line-hi);font-size:var(--fs-body);line-height:28px;}
#root #settingsmodal.recmode #rescode + div{margin-top:16px !important;gap:16px !important;}
#root #settingsmodal.recmode #resread{min-height:56px;padding:0 24px !important;font-size:var(--fs-label);}
#root #settingsmodal.recmode #settabs .invtab{font-size:var(--fs-body);min-height:48px;}
/* v28.xx (cw-cx-o91b-newsreport): the real pause news window uses 20px body notes and the existing near-full-screen modal, not the retired forced floor notice. */
#root #wnmodal{align-items:stretch !important;justify-content:flex-start !important;text-align:left !important;}
#root #wnmodal h3{font-size:var(--fs-title);padding-right:64px;}
#root #wnmodal #wnlist{max-width:none !important;width:100%;font-size:var(--fs-body) !important;line-height:1.6 !important;margin:24px 0 !important;}
#root #wnmodal #wnlist > div{padding:16px 0;margin:0 !important;border-bottom:1px solid var(--ui-line);}
#root #wnmodal #wnlist > div:last-child{border-bottom:0;}
#root #settingsmodal.recmode #spane_rec > div:has(> #rescode) > .msub{display:block !important;font-size:var(--fs-body);line-height:1.4;color:var(--tx-2);margin:8px 0 16px;}
#root #settingsmodal.recmode #reswhat,#root #settingsmodal.recmode #resconfirm,#root #settingsmodal.recmode #resconfirm span,#root #settingsmodal.recmode #resword{font-size:var(--fs-label) !important;line-height:1.5;}
#root #settingsmodal.recmode #resword,#root #settingsmodal.recmode #resgo,#root #settingsmodal.recmode #resno{min-height:48px;box-sizing:border-box;}
/* v28.xx (cw-cx-o91b-newsreport): the existing news close control shares the settings header position and close glyph. */
#root #wnmodal{position:absolute;padding:48px; }
#root #wnmodal #wnclose{position:absolute;top:48px;right:48px;width:48px;height:48px;min-width:0 !important;padding:0 !important;font-size:0 !important;background:transparent;border:1px solid var(--ui-line-hi);color:var(--tx-1);}
#root #wnmodal #wnclose::after{content:'\00d7';font:400 var(--fs-title)/1 var(--f-cond);}
#root #wnmodal #wnclose:hover,#root #wnmodal #wnclose:focus-visible,#root #wnmodal #wnclose.padfocus{color:var(--acc);border-color:var(--acc);}
#root #wnmodal #wnsub{font-size:var(--fs-label);color:var(--tx-2);line-height:1.5;}
</style><canvas id="cv"></canvas>
'@

SubRx @'
var VER='33.55';
'@ @'
var VER='33.56';
'@

$pat = "(?m)^  now:'v33\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.56: The recorder preview is 240px tall, copy is the filled primary action, restore has room and pause news uses 20px body text. Check 33.56 fails on v33.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
