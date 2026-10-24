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

# SETTINGS KEEPS THE FOCUSED ROW IN VIEW AND HAS ONE FOCUS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal.recmode #settabs .invtab.on{color:var(--tx-1);border-bottom-color:var(--acc);}
'@ @'
#root #settingsmodal.recmode #settabs .invtab.on{color:var(--tx-1);border-bottom-color:var(--acc);}
/* v34.34 (cw-setscroll) job 107, critic on Settings 27/29/73 (2): "the focused row is clipped at the top", "no section break", "a stray full-width lime button", "a focus state that is ambiguous across the rail and the list". A key or pad step keeps the row clear of the bottom fade (scroll-padding), a thin line and a 32px gap start every section, the rail and the list never both wear the focus look, restore is a quiet box, the pane packs to the top. */
#root #settingsmodal #setlist{ scroll-padding:var(--sp-1) 0 var(--sp-5); }
#root #settingsmodal #setlist .row[style*="opacity:.7"]{ height:1px !important; margin:var(--sp-4) 0 var(--sp-1) !important; background:var(--ui-line); }
#root #settingsmodal #setlist .setjump button:focus-visible, #root #settingsmodal #setlist .setjump button.padfocus{ outline:0 !important; background:var(--ui-raised); color:var(--tx-1); border-left-color:var(--acc) !important; }
#root #settingsmodal #setlist .setjump:has(button:focus-visible, button.padfocus) button.on:not(:focus-visible):not(.padfocus){ background:transparent; color:var(--tx-2); border-left-color:transparent !important; }
#root #settingsmodal #setlist:has(.setjump button:focus-visible, .setjump button.padfocus) .row.dshow:not(.setjump):not(:hover){ background:transparent !important; box-shadow:inset 0 -1px 0 var(--ui-line-hi) !important; }
#root #settingsmodal #setlist .save-restore-actions > #set_restore{ height:var(--btn-h-sm); min-height:var(--btn-h-sm); background:transparent !important; color:var(--tx-1) !important; border-color:var(--ui-line-hi) !important; font-weight:600; }
#root #settingsmodal #setlist .save-restore-actions > #set_restore:hover:not(:disabled), #root #settingsmodal #setlist .save-restore-actions > #set_restore:focus-visible, #root #settingsmodal #setlist .save-restore-actions > #set_restore.padfocus{ background:transparent !important; color:var(--acc) !important; border-color:var(--acc) !important; outline:0 !important; }
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail){ align-content:flex-start; }
'@

SubRx @'
function vis(x){ var a=sl.getBoundingClientRect(), c=x.getBoundingClientRect(), m=(c.top+c.bottom)/2, bar=sl.querySelector('.setjump'), t=a.top+(bar?bar.getBoundingClientRect().height:0); return !a.height||(m>=t&&m<=a.bottom); }
'@ @'
function vis(x){ var a=sl.getBoundingClientRect(), c=x.getBoundingClientRect(), bar=sl.querySelector('.setjump'), t=a.top+(bar?bar.getBoundingClientRect().height:0); return !a.height||(c.top>=t-1&&c.bottom<=a.bottom+1); }   // v34.34 (cw-setscroll): the WHOLE row, so the focus look never lands on a row cut by the top edge
'@

SubRx @'
(h&&h.textContent?'<div class="sdh">'+escHtml(h.textContent)+'</div>':'')
'@ @'
(h&&h.textContent?'<div class="sdh">'+escHtml(setHintShort(h.textContent))+'</div>':'')
'@

SubRx @'
function setSecHead(n){
'@ @'
// v34.34 (cw-setscroll) job 107, critic on Settings 73 (2): "an explaining paragraph in the detail pane". The pane keeps the first clause of a row hint, at most 56 characters. The row and its setting are untouched.
function setHintShort(t){ var s=String(t||'').split(/[:;]|\. | \(/)[0].trim(); if(s.length>56){ s=s.slice(0,56); s=s.slice(0,Math.max(s.lastIndexOf(' '),1)); } return s; }
function setSecHead(n){
'@

SubRx @'
setSecJump(host,b.getAttribute('data-sec')); setSecSpy(host); };
'@ @'
host._secPick=b.getAttribute('data-sec'); setSecJump(host,b.getAttribute('data-sec')); setSecSpy(host); };
'@

SubRx @'
  if(host.querySelector('.save-restore:focus-within,.save-restore:has(.padfocus),.setjump button[data-sec="SAVES AND TOOLS"]:focus')) cur='SAVES AND TOOLS';
'@ @'
  // v34.34 (cw-setscroll) job 107, critic on Settings 73 (2): "mismatched tab and row state". A section too short to reach the top of the list (ACCESSIBILITY) kept the tab above it lit while the chip clicked wore the focus box. The clicked chip stays the lit tab until a wheel turn or a row focus moves on.
  if(host._secPick){ var _pk=document.getElementById(setSecId(host._secPick)), _pt=_pk?_pk.getBoundingClientRect().top:-1e9; if(_pk&&_pt>=ht+bh-6&&_pt<host.getBoundingClientRect().bottom&&!(host.querySelector('.padfocus')&&!host.querySelector('.setjump .padfocus'))) cur=host._secPick; else host._secPick=null; }
  if(host.querySelector('.save-restore:focus-within,.save-restore:has(.padfocus),.setjump button[data-sec="SAVES AND TOOLS"]:focus')) cur='SAVES AND TOOLS';
'@

SubRx @'
  host.onfocusin=function(){ setSecSpy(host); };
'@ @'
  host.onfocusin=function(e){ if(!(e&&e.target&&e.target.closest&&e.target.closest('.setjump'))) host._secPick=null; setSecSpy(host); };   // v34.34 (cw-setscroll)
  host.onwheel=function(){ host._secPick=null; };
'@

SubRx @'
var VER='34.34';
'@ @'
var VER='34.35';
'@

$pat = "(?m)^  now:'v34\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.35: Settings scrolls with the whole focused row in view, shows one focus at a time and has no lime box. Check 34.35 fails on v34.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
