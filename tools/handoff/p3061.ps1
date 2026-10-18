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

# THE ACCENT IS LIME YELLOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    --acc:#f5b73b; --acc-ink:#1a1205; --acc-dim:rgba(245,183,59,.16);
'@ @'
    --acc:#e6ff3d; --acc-ink:#11150a; --acc-dim:rgba(230,255,61,.16);
'@

SubRx @'
  .pmore:hover { background:rgba(245,183,59,.08); }
'@ @'
  .pmore:hover { background:rgba(230,255,61,.08); }
'@

SubRx @'
  .row:hover { background:rgba(245,183,59,.06); }
'@ @'
  .row:hover { background:rgba(230,255,61,.06); }
'@

SubRx @'
.avslot:hover{ background:rgba(245,183,59,.10); }
'@ @'
.avslot:hover{ background:rgba(230,255,61,.10); }
'@

SubRx @'
.avslot.on{ background:rgba(245,183,59,.16); }
'@ @'
.avslot.on{ background:rgba(230,255,61,.16); }
'@

SubRx @'
  .imenurow:hover{ background:rgba(245,183,59,.14); color:#fff; }
'@ @'
  .imenurow:hover{ background:rgba(230,255,61,.14); color:#fff; }
'@

SubRx @'
  .vcell:hover{ background:rgba(245,183,59,.10); }
'@ @'
  .vcell:hover{ background:rgba(230,255,61,.10); }
'@

SubRx @'
  .cell:hover{ background:rgba(245,183,59,.10); transform:translateY(-1px); }
'@ @'
  .cell:hover{ background:rgba(230,255,61,.10); transform:translateY(-1px); }
'@

SubRx @'
  button:hover:not(:disabled){ border-color:var(--amber); color:var(--amber); background:rgba(245,183,59,.08); }
'@ @'
  button:hover:not(:disabled){ border-color:var(--amber); color:var(--amber); background:rgba(230,255,61,.08); }
'@

SubRx @'
  .ghost:hover{ background:rgba(245,183,59,.09); }
'@ @'
  .ghost:hover{ background:rgba(230,255,61,.09); }
'@

SubRx @'
  #root button:hover:not(:disabled){ background:rgba(245,183,59,.10); box-shadow:0 0 0 1px rgba(245,183,59,.25) inset; }
'@ @'
  #root button:hover:not(:disabled){ background:rgba(230,255,61,.10); box-shadow:0 0 0 1px rgba(230,255,61,.25) inset; }
'@

SubRx @'
  #root .deploy.ghost{ background:transparent; color:var(--amber); border-color:rgba(245,183,59,.55); box-shadow:none; }
'@ @'
  #root .deploy.ghost{ background:transparent; color:var(--amber); border-color:rgba(230,255,61,.55); box-shadow:none; }
'@

SubRx @'
  #root .deploy.ghost:hover:not(:disabled){ background:rgba(245,183,59,.10); color:var(--amber); }
'@ @'
  #root .deploy.ghost:hover:not(:disabled){ background:rgba(230,255,61,.10); color:var(--amber); }
'@

SubRx @'
  #root .vbuy:hover:not(:disabled){ background:#f7c25a; color:var(--acc-ink); }
'@ @'
  #root .vbuy:hover:not(:disabled){ background:#f0ff7a; color:var(--acc-ink); }
'@

SubRx @'
  #root #barmodal button[data-bz]:hover:not(:disabled){ background:#f7c25a; border-color:#f7c25a; color:var(--acc-ink); }
'@ @'
  #root #barmodal button[data-bz]:hover:not(:disabled){ background:#f0ff7a; border-color:#f0ff7a; color:var(--acc-ink); }
'@

SubRx @'
  #root #pausebox #resumebtn:hover:not(:disabled){ background:#f7c25a; border-color:#f7c25a; color:var(--acc-ink); }
'@ @'
  #root #pausebox #resumebtn:hover:not(:disabled){ background:#f0ff7a; border-color:#f0ff7a; color:var(--acc-ink); }
'@

SubRx @'
  #root #modemenu #moderetry:hover:not(:disabled){ background:#f7c25a; border-color:#f7c25a; color:var(--acc-ink); }
'@ @'
  #root #modemenu #moderetry:hover:not(:disabled){ background:#f0ff7a; border-color:#f0ff7a; color:var(--acc-ink); }
'@

SubRx @'
  #root #gamblebtn:hover:not(:disabled){ background:#f7c25a; border-color:#f7c25a !important; }
'@ @'
  #root #gamblebtn:hover:not(:disabled){ background:#f0ff7a; border-color:#f0ff7a !important; }
'@

SubRx @'
  #root .deploy:active:not(:disabled), #root #oc_btn:active:not(:disabled), #root .ui-btn.pri:active:not(:disabled){ background:#dfa52f; }
'@ @'
  #root .deploy:active:not(:disabled), #root #oc_btn:active:not(:disabled), #root .ui-btn.pri:active:not(:disabled){ background:#c8e22c; }
'@

SubRx @'
  #root .cell:hover, #root .vcell:hover{ background:linear-gradient(180deg,rgba(245,183,59,.14) 0%,rgba(0,0,0,.30) 100%); transform:translateY(-2px);
'@ @'
  #root .cell:hover, #root .vcell:hover{ background:linear-gradient(180deg,rgba(230,255,61,.14) 0%,rgba(0,0,0,.30) 100%); transform:translateY(-2px);
'@

SubRx @'
  #root .vcell.on{ background:linear-gradient(180deg,rgba(245,183,59,.22) 0%,rgba(245,183,59,.08) 100%); }
'@ @'
  #root .vcell.on{ background:linear-gradient(180deg,rgba(230,255,61,.22) 0%,rgba(230,255,61,.08) 100%); }
'@

SubRx @'
  #root input:not([type=range]):focus, #root textarea:focus{ border-color:var(--amber); outline:none; box-shadow:0 0 0 2px rgba(245,183,59,.22); }
'@ @'
  #root input:not([type=range]):focus, #root textarea:focus{ border-color:var(--amber); outline:none; box-shadow:0 0 0 2px rgba(230,255,61,.22); }
'@

SubRx @'
  .vcell.on{ border-color:var(--amber); background:rgba(245,183,59,.15);
'@ @'
  .vcell.on{ border-color:var(--amber); background:rgba(230,255,61,.15);
'@

SubRx @'
    box-shadow:0 0 0 6px rgba(245,183,59,.35), 0 0 22px 4px rgba(245,183,59,.45) !important; }
'@ @'
    box-shadow:0 0 0 6px rgba(230,255,61,.35), 0 0 22px 4px rgba(230,255,61,.45) !important; }
'@

SubRx @'
    box-shadow:inset 4px 0 0 var(--tx-1), inset 0 -3px 0 var(--bar,transparent), 0 0 0 6px rgba(245,183,59,.22), 0 0 0 7px rgba(11,12,13,.6) !important; }
'@ @'
    box-shadow:inset 4px 0 0 var(--tx-1), inset 0 -3px 0 var(--bar,transparent), 0 0 0 6px rgba(230,255,61,.22), 0 0 0 7px rgba(11,12,13,.6) !important; }
'@

SubRx @'
  <div id="wirtsec_offer" style="border:1px solid var(--amber);padding:10px 12px;margin:14px 0 0;background:rgba(245,183,59,.05)">
'@ @'
  <div id="wirtsec_offer" style="border:1px solid var(--amber);padding:10px 12px;margin:14px 0 0;background:rgba(230,255,61,.05)">
'@

SubRx @'
      <div id="seasonfill" style="height:100%;width:0%;background:linear-gradient(90deg,#f5b73b,#f5b73b)"></div>
'@ @'
      <div id="seasonfill" style="height:100%;width:0%;background:linear-gradient(90deg,#e6ff3d,#e6ff3d)"></div>
'@

SubRx @'
  if(w>c+20){ ctx.fillStyle='#f5b73b'; ctx.fillRect(x+c+4,y,Math.min(36,w*0.25),2); }   // the amber tick of the menu plate (ui6)
'@ @'
  if(w>c+20){ ctx.fillStyle='#e6ff3d'; ctx.fillRect(x+c+4,y,Math.min(36,w*0.25),2); }   // the amber tick of the menu plate (ui6)
'@

SubRx @'
  r.style.cssText='position:fixed;left:0;top:0;pointer-events:none;z-index:99999;box-sizing:border-box;border:2px solid #f5b73b;border-radius:6px;box-shadow:0 0 14px 2px rgba(245,183,59,.4);display:none;will-change:transform';
'@ @'
  r.style.cssText='position:fixed;left:0;top:0;pointer-events:none;z-index:99999;box-sizing:border-box;border:2px solid #e6ff3d;border-radius:6px;box-shadow:0 0 14px 2px rgba(230,255,61,.4);display:none;will-change:transform';
'@

SubRx @'
    --btn-h:56px; --btn-h-sm:48px; --btn-h-xs:40px; --menu-w:560px; --acc-hover:#f7c25a; --acc-press:#dfa52f;
'@ @'
    --btn-h:56px; --btn-h-sm:48px; --btn-h-xs:40px; --menu-w:560px; --acc-hover:#f0ff7a; --acc-press:#c8e22c;
'@

SubRx @'
  #root .deploy:hover:not(:disabled), #root #oc_btn:hover:not(:disabled), #root .ui-btn.pri:hover:not(:disabled){ background:#f7c25a; background-image:none; border-color:#f7c25a; color:var(--acc-ink); filter:none; box-shadow:none; }
'@ @'
  #root .deploy:hover:not(:disabled), #root #oc_btn:hover:not(:disabled), #root .ui-btn.pri:hover:not(:disabled){ background:#f0ff7a; background-image:none; border-color:#f0ff7a; color:var(--acc-ink); filter:none; box-shadow:none; }
'@

SubRx @'
  tx_1:'#efe9dc', tx_2:'#aaa498', tx_3:'#7a766e', tx_off:'#55524c', acc:'#f5b73b', acc_ink:'#1a1205', acc_dim:'rgba(245,183,59,.16)',
'@ @'
  // v28.xx (cw-limeacc), his Q46 (2026-10-18): the accent is lime yellow, the most visible shade on the dark. warn stays the old amber on purpose, so a warning is never the accent.
  tx_1:'#efe9dc', tx_2:'#aaa498', tx_3:'#7a766e', tx_off:'#55524c', acc:'#e6ff3d', acc_ink:'#11150a', acc_dim:'rgba(230,255,61,.16)',
'@

SubRx @'
var VER='30.60';
'@ @'
var VER='30.61';
'@

$pat = "(?m)^  now:'v30\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.61: Main buttons, the selected tab and the focus ring are lime yellow instead of amber. Check 30.61 fails on v30.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
