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

# DAILY RESTORE ACTION AND SECTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-cx-dailyrestorefinish), daily restore critic 2026-10-20: one primary restore action, a quiet source picker and undo, compact date details and readable existing key hints. */
#root #settingsmodal #setlist .save-restore-actions{ align-items:center; }
#root #settingsmodal #setlist .save-restore-actions > #set_restore{ height:56px; min-height:56px; background:var(--acc) !important; color:var(--acc-ink) !important; border-color:var(--acc) !important; font-weight:700; }
#root #settingsmodal #setlist .save-restore-actions > #set_restore:hover:not(:disabled){ background:var(--acc-hover) !important; }
#root #settingsmodal #setlist .save-restore-actions > #set_restore:focus-visible, #root #settingsmodal #setlist .save-restore-actions > #set_restore.padfocus{ outline:2px solid var(--tx-1) !important; outline-offset:-6px !important; }
#root #settingsmodal #setlist .save-restore-actions > #set_restore_source{ display:inline-flex; align-items:center; justify-content:space-between; gap:8px; }
#root #settingsmodal #setlist #set_restore_source::before{ content:'\2039'; }
#root #settingsmodal #setlist #set_restore_source::after{ content:'\203a'; }
#root #settingsmodal #setlist #set_restore_source::before, #root #settingsmodal #setlist #set_restore_source::after{ color:var(--tx-2); font:600 var(--fs-body)/1 var(--f-cond); }
#root #settingsmodal #setdetail.daily-restore-detail .sdk{ font-size:var(--fs-body); font-weight:600; }
#root #settingsmodal #setdetail.daily-restore-detail .daily-selected{ font-size:var(--fs-body); font-weight:600; color:var(--tx-2); }
#root #settingsmodal #setdetail.daily-restore-detail .daily-meta dd:first-of-type{ font:700 var(--fs-title)/1.2 var(--f-cond); }
#root #settingsmodal #setlist .row.save-key-hint > span.hint{ display:flex; flex:0 0 calc(var(--sp-5) * 6); justify-content:center; align-items:center; font-size:var(--fs-label) !important; color:var(--tx-2); }
#root #settingsmodal #setlist .save-key-hint kbd{ display:inline-block; min-width:40px; box-sizing:border-box; padding:4px 8px; border:1px solid var(--ui-line-hi); border-radius:var(--rad); font:600 var(--fs-label)/1.2 var(--f-cond); text-align:center; }
</style><canvas id="cv"></canvas>
'@

SubRx @'
var SETSEC=['THE RAID','AUDIO','CONTROLS','CONTROLLER','DISPLAY','ACCESSIBILITY'];
'@ @'
var SETSEC=['THE RAID','AUDIO','CONTROLS','CONTROLLER','DISPLAY','ACCESSIBILITY','SAVES AND TOOLS']; // v28.xx (cw-cx-dailyrestorefinish): include the existing save section in its existing navigation.
'@

SubRx @'
    if(!b) continue;
    h+=setSecHead(n)+b; j+='<button type="button" data-sec="'+n+'">'+n+'</button>';
'@ @'
    // v28.xx (cw-cx-dailyrestorefinish): its existing rows and header are appended below, so add only the navigation item here.
    if(!b){ if(n==='SAVES AND TOOLS') j+='<button type="button" data-sec="'+n+'">saves and tools</button>'; continue; }
    h+=setSecHead(n)+b; j+='<button type="button" data-sec="'+n+'">'+n+'</button>';
'@

SubRx @'
  bs=host.querySelectorAll('.setjump button');
'@ @'
  // v28.xx (cw-cx-dailyrestorefinish): a focused restore row belongs to saves, even when display rows remain visible above it.
  if(host.querySelector('.save-restore:focus-within,.save-restore:has(.padfocus),.setjump button[data-sec="SAVES AND TOOLS"]:focus')) cur='SAVES AND TOOLS';
  bs=host.querySelectorAll('.setjump button');
'@

SubRx @'
  host.onscroll=function(){ setSecSpy(host); }; setSecSpy(host);   // v26.xx (settingsfix)
'@ @'
  host.onscroll=function(){ setSecSpy(host); }; setSecSpy(host);   // v26.xx (settingsfix)
  // v28.xx (cw-cx-dailyrestorefinish): keyboard and pad focus update the same section marker as scrolling.
  host.onfocusin=function(){ setSecSpy(host); };
'@

SubRx @'
    if(p&&typeof p.runs==='number'&&isFinite(p.runs)) html+='<dt>runs</dt><dd>'+Math.max(0,Math.floor(p.runs)).toLocaleString()+'</dd>';
'@ @'
    if(p&&typeof p.runs==='number'&&isFinite(p.runs)&&p.runs>0) html+='<dt>runs</dt><dd>'+Math.floor(p.runs).toLocaleString()+'</dd>'; // v28.xx (cw-cx-dailyrestorefinish): omit empty career stats.
'@

SubRx @'
  return html+'<div class="sdh">undo keeps current save</div>';
'@ @'
  return html+'<div class="sdh">undo last restore</div>'; // v28.xx (cw-cx-dailyrestorefinish): name the action instead of implying that undo makes a backup.
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Controls legend</b><div class="hint">H in a raid cycles compact, full and off. Compact is the default.</div></div>'+
    '<span class="hint">H</span></div>'+
'@ @'
    '<div class="row save-key-hint"><div style="flex:1"><b>Controls legend</b><div class="hint">H in a raid cycles compact, full and off. Compact is the default.</div></div>'+
    '<span class="hint"><kbd>h</kbd></span></div>'+
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Mouse cursor</b><div class="hint">The cursor hides while you aim and shows with the backpack open. BACKSPACE brings it back.</div></div>'+
    '<span class="hint">BKSP</span></div>'+
'@ @'
    '<div class="row save-key-hint"><div style="flex:1"><b>Mouse cursor</b><div class="hint">The cursor hides while you aim and shows with the backpack open. BACKSPACE brings it back.</div></div>'+
    '<span class="hint"><kbd>bksp</kbd></span></div>'+
'@

SubRx @'
  [].forEach.call(host.querySelectorAll('.setjump button'),function(b){ b.onclick=function(){ if(b.getAttribute('data-go')){ openSettings(b.getAttribute('data-go')); return; } setSecJump(host,b.getAttribute('data-sec')); setSecSpy(host); }; });
'@ @'
  [].forEach.call(host.querySelectorAll('.setjump button'),function(b){ b.onclick=function(){ b.focus({preventScroll:true}); if(b.getAttribute('data-go')){ openSettings(b.getAttribute('data-go')); return; } setSecJump(host,b.getAttribute('data-sec')); setSecSpy(host); }; }); // v28.xx (cw-cx-dailyrestorefinish): navigation takes focus away from the previous restore control.
'@

SubRx @'
var VER='32.94';
'@ @'
var VER='32.95';
'@

$pat = "(?m)^  now:'v32\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.95: Settings marks saves and tools while its restore row is focused. Restore is the primary action, undo stays secondary, dated details are compact, and the two nearby key hints are readable. Check 32.95 fails on v32.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
