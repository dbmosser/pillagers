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

# NEWS AND RECORDER LAYOUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-cx-o91b-windowlayout): critic round 1, news 2 and recorder 3. HIS Q43 keeps the near-full-screen card. Keep every word and control; give the newest row structure and keep the header below the currency strip. */
#root #wnmodal{padding:max(calc(5vh + 24px),96px) calc(5vw + 24px) 48px;background:var(--scrim);}
#root #wnmodal::before{inset:5vh 5vw;border-radius:var(--rad);border:1px solid var(--ui-line-hi);background:linear-gradient(var(--acc),var(--acc)) 24px 0/36px 2px no-repeat,var(--ui-bg);box-shadow:none;}
#root #wnmodal h3{font:700 var(--fs-title)/1.25 var(--f-cond);color:var(--tx-1);letter-spacing:var(--track);margin:0 0 16px;padding-right:72px;min-height:48px;}
#root #wnmodal #wnsub{font:400 var(--fs-label)/1.5 var(--f-body);color:var(--tx-2);margin:0;}
#root #wnmodal #wnclose{top:max(calc(5vh + 24px),96px);right:calc(5vw + 24px);border-color:var(--ui-line-hi);border-radius:var(--rad);}
#root #wnmodal #wnclose:hover,#root #wnmodal #wnclose:focus-visible,#root #wnmodal #wnclose.padfocus{border-color:var(--acc);outline:2px solid var(--acc);outline-offset:2px;}
#root #wnmodal #wnlist{box-sizing:border-box;max-width:900px !important;max-height:none;min-height:0;overflow:auto;margin:24px auto 0 !important;padding:0 0 24px;font:600 var(--fs-body)/1.4 var(--f-cond);color:var(--tx-1);}
#root #wnmodal #wnlist > div{display:flex;align-items:center;box-sizing:border-box;min-height:72px;padding:16px 24px;border-bottom:1px solid var(--ui-line-hi);}
#root #wnmodal #wnlist > div:first-child{background:var(--ui-raised);box-shadow:inset 3px 0 0 var(--acc);}
/* v28.xx (cw-cx-o91b-windowlayout): the style guide keeps unrelated floor toasts clear of open windows. Currency remains visible on news. */
body:has(#wnmodal.on) #hubtoast,body:has(#settingsmodal.recmode.on) #hubtoast{visibility:hidden;opacity:0;pointer-events:none;}
/* v28.xx (cw-cx-o91b-windowlayout): recorder column 1100px, restore section at the foot, 20px section names and actions, 16px existing warning. Raw data and restore logic stay intact. */
#root #settingsmodal.recmode #spane_rec{max-width:1100px;margin:0 auto;align-self:center;padding-bottom:0;}
#root #settingsmodal.recmode #spane_rec > .msub{font:600 var(--fs-body)/1.4 var(--f-cond);color:var(--tx-1);}
#root #settingsmodal.recmode #exporttext{min-height:calc(160px / 1.3) !important;height:calc(160px / 1.3);max-height:calc(160px / 1.3);font:400 var(--fs-body)/28px var(--f-body);color:var(--tx-1);padding-bottom:24px;white-space:pre-wrap;overflow-wrap:anywhere;scrollbar-width:thin;scrollbar-color:var(--ui-line-hi) var(--ui-bg);-webkit-mask-image:linear-gradient(to bottom,#000 calc(100% - 24px),transparent);mask-image:linear-gradient(to bottom,#000 calc(100% - 24px),transparent);}
#root #settingsmodal.recmode #exporttext::-webkit-scrollbar{width:6px;height:6px;}
#root #settingsmodal.recmode #exporttext::-webkit-scrollbar-thumb{background:var(--ui-line-hi);border-radius:var(--rad);}
#root #settingsmodal.recmode #exporttext + div + div{margin-top:auto !important;flex-shrink:0;}
#root #settingsmodal.recmode #exporttext + div + div > div:first-child{font:600 var(--fs-body)/1.4 var(--f-cond);font-size:var(--fs-body) !important;color:var(--tx-1) !important;}
#root #settingsmodal.recmode #spane_rec > div:has(> #rescode) > .msub{font-size:var(--fs-label);line-height:1.5;color:var(--tx-2);}
#root #settingsmodal.recmode #copybtn{font:700 var(--fs-body)/1 var(--f-cond);letter-spacing:var(--track);border-radius:var(--rad);}
#root #settingsmodal.recmode #wipelog,#root #settingsmodal.recmode #resread{height:56px;min-height:56px;font:600 var(--fs-body)/1 var(--f-cond);letter-spacing:var(--track);border-radius:var(--rad);}
#root #settingsmodal.recmode #wipelog{color:var(--danger) !important;border-color:var(--danger) !important;}
#root #settingsmodal.recmode #resread{color:var(--tx-1);border-color:var(--ui-line-hi);}
#root #settingsmodal.recmode #wipelog:focus-visible,#root #settingsmodal.recmode #wipelog.padfocus,#root #settingsmodal.recmode #resread:focus-visible,#root #settingsmodal.recmode #resread.padfocus{outline:2px solid var(--acc);outline-offset:2px;border-color:var(--acc) !important;}
</style><canvas id="cv"></canvas>
'@

SubRx @'
var VER='33.66';
'@ @'
var VER='33.67';
'@

$pat = "(?m)^  now:'v33\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.67: News has 72px rows with a newest accent and a clear header. The recorder column is centered with a quieter warning and a fading preview. Check 33.67 fails on v33.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
