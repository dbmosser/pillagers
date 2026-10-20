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

# DAILY RESTORE CONTROLS FIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-cx-dailyrestoreui), daily restore critic 2026-10-20: keep source, restore and undo visible together, without the global focus rail inside each button. */
#root #settingsmodal #setlist .row.save-restore{ height:auto; min-height:var(--btn-h); flex-wrap:wrap; gap:8px; padding-block:8px; }
#root #settingsmodal #setlist .row.save-restore > div:first-child{ flex:0 0 100% !important; }
#root #settingsmodal #setlist .save-restore-actions{ display:flex; flex:1 1 100%; width:100%; min-width:0; gap:8px; }
#root #settingsmodal #setlist .save-restore-actions > button{ flex:1 1 0; min-width:0 !important; height:44px; min-height:44px; box-sizing:border-box; margin:0 !important; padding:0 12px !important; font:600 var(--fs-body)/1.2 var(--f-cond); letter-spacing:var(--track); white-space:nowrap; color:var(--tx-1) !important; background:transparent !important; border:2px solid var(--ui-line-hi) !important; border-radius:var(--rad); outline:none !important; box-shadow:none !important; clip-path:none; }
#root #settingsmodal #setlist .save-restore-actions > button:focus-visible, #root #settingsmodal #setlist .save-restore-actions > button.padfocus, #root #settingsmodal #setlist .save-restore-actions > button:hover:not(:disabled){ border-color:var(--acc) !important; }
#root #settingsmodal #setlist .row.save-restore:focus-within, #root #settingsmodal #setlist .row.save-restore:has(.padfocus), #root #settingsmodal #setlist .row.save-restore.dshow{ background:var(--ui-raised); box-shadow:inset 3px 0 0 var(--acc); }
#root #settingsmodal #setwrap > #setdetail.daily-restore-detail{ display:block; height:auto; min-height:0; align-self:flex-start; }
#root #settingsmodal #setdetail.daily-restore-detail .sdk{ margin:0; }
#root #settingsmodal #setdetail.daily-restore-detail .daily-selected{ margin-top:16px; color:var(--tx-1); font:700 var(--fs-hero)/1.1 var(--f-cond); }
#root #settingsmodal #setdetail.daily-restore-detail .daily-meta{ display:grid; grid-template-columns:auto 1fr; gap:8px 24px; margin:16px 0 0; font:400 var(--fs-body)/1.4 var(--f-body); }
#root #settingsmodal #setdetail.daily-restore-detail dt{ color:var(--tx-2); }
#root #settingsmodal #setdetail.daily-restore-detail dd{ margin:0; color:var(--tx-1); }
#root #settingsmodal #setdetail.daily-restore-detail .sdh{ margin:16px 0 0; }
</style><canvas id="cv"></canvas>
'@

SubRx @'
    '<div class="row"><div style="flex:1"><b>Restore from a backup</b><div class="hint">file or daily copy; undo available</div></div>'+
    (_dailyChoices.length?'<button id="set_restore_source" aria-label="backup source: file" title="choose backup" style="padding:6px 12px;margin-right:8px"'+_rOff+'>file</button>':'')+
    '<button id="set_restore" style="padding:6px 12px"'+_rOff+'>PICK FILE</button>'+
    // v12.85, 2026-09-11 audit: THE WAY BACK, which the sentence above has been
    // promising since v8.75 and which did not exist. The outgoing profile was
    // already being written to a key nothing ever read. The button only appears
    // when there is something behind it.
    (hasPreRestore()?'<button id="set_unrestore" style="padding:6px 12px;margin-left:8px"'+_rOff+'>UNDO</button>':'')+
    '</div>'+
'@ @'
    '<div class="row save-restore"><div style="flex:1"><b>Restore from a backup</b><div class="hint">file or daily copy; undo available</div></div>'+
    '<div class="save-restore-actions">'+
    (_dailyChoices.length?'<button id="set_restore_source" aria-label="backup source: file" title="choose backup" style="padding:6px 12px;margin-right:8px"'+_rOff+'>file</button>':'')+
    '<button id="set_restore" style="padding:6px 12px"'+_rOff+'>PICK FILE</button>'+
    // v12.85, 2026-09-11 audit: THE WAY BACK, which the sentence above has been
    // promising since v8.75 and which did not exist. The outgoing profile was
    // already being written to a key nothing ever read. The button only appears
    // when there is something behind it.
    (hasPreRestore()?'<button id="set_unrestore" style="padding:6px 12px;margin-left:8px"'+_rOff+'>UNDO</button>':'')+
    '</div></div>'+
'@

SubRx @'
function storeSet(v){
'@ @'
// v28.xx (cw-cx-dailyrestoreui): the existing detail pane names the selected copy and its actual calendar date, never an invented time.
function dailySaveDetailHtml(row){
  var src=row.querySelector('#set_restore_source'),key=src&&src.getAttribute('data-backup-key'),raw,p=null;
  var html='<div class="sdk">restore from a backup</div><div class="daily-selected">'+escHtml(src?src.textContent:'file')+'</div>';
  if(key&&key.indexOf(SKEY+':daily:')===0&&/\d{4}-\d{2}-\d{2}$/.test(key)){
    try{ raw=localStorage.getItem(key);p=JSON.parse(raw); }catch(_e){}
    html+='<dl class="daily-meta"><dt>saved</dt><dd>'+escHtml(key.slice(-10))+'</dd>';
    if(p&&typeof p.runs==='number'&&isFinite(p.runs)) html+='<dt>runs</dt><dd>'+Math.max(0,Math.floor(p.runs)).toLocaleString()+'</dd>';
    html+='</dl>';
  }
  return html+'<div class="sdh">undo keeps current save</div>';
}
function storeSet(v){
'@

SubRx @'
    var html='<div class="sdk">'+escHtml(b.textContent)+'</div>'+(vt?'<div class="sdv">'+escHtml(vt)+'</div>':'')+(h&&h.textContent?'<div class="sdh">'+escHtml(h.textContent)+'</div>':'');
'@ @'
    var html='<div class="sdk">'+escHtml(b.textContent)+'</div>'+(vt?'<div class="sdv">'+escHtml(vt)+'</div>':'')+(h&&h.textContent?'<div class="sdh">'+escHtml(h.textContent)+'</div>':'');
    // v28.xx (cw-cx-dailyrestoreui): only the restore row gets backup details; other Settings rows keep their own descriptions.
    var restoreRow=!!r.querySelector('#set_restore');
    dt.classList.toggle('daily-restore-detail',restoreRow);
    if(restoreRow) html=dailySaveDetailHtml(r);
'@

SubRx @'
    _src.setAttribute('aria-label','backup source: '+_src.textContent);
'@ @'
    _src.setAttribute('aria-label','backup source: '+_src.textContent);
    // v28.xx (cw-cx-dailyrestoreui): the selected side key supplies the detail pane's date and run count.
    _src.setAttribute('data-backup-key',_dailyAt<0?'':_dailyChoices[_dailyAt].key);
'@

SubRx @'
var VER='32.93';
'@ @'
var VER='32.94';
'@

$pat = "(?m)^  now:'v32\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.94: The existing restore row keeps source, restore and undo visible together. Its detail pane shows the selected copy, saved date and run count directly below the title. Check 32.94 fails on v32.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
