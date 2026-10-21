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

# NEWS AND REPORT SPACING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-cx-o91b-finalspacing): critic round 3. Keep HIS Q43 near-full-screen window and every word. The currency stays visible above the frame. The existing version and notes form two columns, without adding copy or controls. */
#root #wnmodal{padding:max(calc(5vh + 24px),120px) calc(5vw + 24px) calc(5vh + 24px);grid-template-columns:minmax(240px,1fr) minmax(0,900px);grid-template-rows:56px minmax(0,1fr);gap:32px 48px;}
#root #wnmodal.on{display:grid !important;}
#root #wnmodal::before{inset:max(5vh,96px) 5vw 5vh;background:var(--ui-bg);}
#root #wnmodal h3{grid-column:1 / -1;grid-row:1;min-height:56px;margin:0;display:flex;align-items:center;}
#root #wnmodal #wnclose{top:max(calc(5vh + 24px),120px);}
#root #wnmodal #wnsub{grid-column:1;grid-row:2;align-self:center;max-width:440px;margin:0;font:800 56px/1.15 var(--f-cond);color:var(--tx-1);overflow-wrap:anywhere;}
#root #wnmodal #wnlist{grid-column:2;grid-row:2;align-self:center;margin:0 !important;padding:0;max-height:100%;font-size:var(--fs-body) !important;}
#root #wnmodal #wnlist > div{min-height:112px;padding:24px 32px;font:600 var(--fs-title)/1.25 var(--f-cond);color:var(--tx-2);}
#root #wnmodal #wnlist > div:first-child{color:var(--tx-1);box-shadow:inset 4px 0 0 var(--acc);}
/* v28.xx (cw-cx-o91b-finalspacing): the task caps the preview at 240 screen pixels at 1080p. 184 CSS pixels is 239.2 at the normal 130 percent scale. Six 24px lines fit between 16px top and 22px bottom padding, leaving the existing fade in the bottom padding. Group restore 32px below the actions instead of pinning it to the footer. */
#root #settingsmodal.recmode #spane_rec{justify-content:safe center;}
#root #settingsmodal.recmode #exporttext{min-height:184px !important;height:184px;max-height:184px;padding:16px 16px 22px;line-height:24px;-webkit-mask-image:linear-gradient(to bottom,#000 calc(100% - 8px),transparent);mask-image:linear-gradient(to bottom,#000 calc(100% - 8px),transparent);}
#root #settingsmodal.recmode #exporttext + div{margin-top:24px !important;flex-shrink:0;}
#root #settingsmodal.recmode #exporttext + div + div{margin-top:32px !important;}
#root #settingsmodal.recmode #spane_rec > div:has(> #rescode) > .msub{font:400 16px/1.5 var(--f-body);font-size:16px !important;color:var(--tx-2);}
#root #settingsmodal.recmode > h3{min-height:56px;display:flex;align-items:center;}
#root #settingsmodal.recmode #settabs{top:var(--py);height:56px;align-items:center;gap:16px;}
#root #settingsmodal.recmode #settabs .invtab{font:700 var(--fs-body)/1 var(--f-cond);min-height:48px;color:var(--tx-2);border-bottom-width:3px;}
#root #settingsmodal.recmode #settabs .invtab.on{color:var(--tx-1);border-bottom-color:var(--acc);}
@media(max-width:1100px){
  #root #wnmodal{grid-template-columns:minmax(0,1fr);grid-template-rows:56px auto minmax(0,1fr);gap:24px;}
  #root #wnmodal #wnsub{grid-column:1;grid-row:2;font-size:32px;max-width:none;}
  #root #wnmodal #wnlist{grid-column:1;grid-row:3;}
}
</style><canvas id="cv"></canvas>
'@

SubRx @'
var VER='33.69';
'@ @'
var VER='33.70';
'@

$pat = "(?m)^  now:'v33\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.70: The frame clears currency, the existing version anchors the notes, and the recorder groups a six-line preview with restore. Check 33.70 fails on v33.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
