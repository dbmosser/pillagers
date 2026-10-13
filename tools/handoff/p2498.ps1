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

# SETTINGS HAS A DETAIL PANE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <div id="setlist" class="plist"></div>
'@ @'
    <!-- vNN.xx (ui5q2o, his #50): the list and, beside it, the detail pane for the row under the mouse or the pad -->
    <div id="setwrap"><div id="setlist" class="plist"></div><div id="setdetail" aria-live="polite"></div></div>
'@

SubRx @'
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@ @'
  /* vNN.xx, UI REDESIGN ui5q2o (his #50, from the AAA judge of the Settings shot): A DETAIL PANE. The right third of the Settings window
     was empty beside the list. It is a detail pane now, as in the settings of the shooters he named: the row under the mouse or the
     pad (the first row when nothing is pointed at) with its name large, its value, and its whole description in a readable size.
     The list and its rows are unchanged. */
  #root #settingsmodal #spane_display{ max-width:none; }
  #root #setwrap{ display:flex; gap:24px; flex:1; min-height:0; align-items:stretch; }
  #root #setwrap > #setlist{ flex:0 1 1320px; min-width:0; }
  #root #setdetail{ flex:1 1 380px; min-width:0; max-width:560px; align-self:flex-start; box-sizing:border-box; padding:26px 28px;
    border:1px solid var(--ui-line); background:rgba(255,255,255,.025); box-shadow:inset 0 3px 0 var(--acc); }
  #root #setdetail:empty{ display:none; }
  #root #setdetail .sdk{ font-family:var(--f-cond); font-weight:700; font-size:30px; line-height:1.1; letter-spacing:.04em; text-transform:uppercase; color:var(--tx-1); }
  #root #setdetail .sdv{ display:inline-block; margin-top:14px; padding:6px 12px; border:1px solid var(--acc); color:var(--acc); font-family:var(--f-cond);
    font-weight:700; font-size:20px; letter-spacing:.1em; text-transform:uppercase; }
  #root #setdetail .sdh{ margin-top:18px; font-size:17px; line-height:1.6; color:var(--tx-2); }
  /* vNN.xx, UI REDESIGN ui5q1c (his #50, from the AAA judge
'@

SubRx @'
document.getElementById('pausesetbtn').onclick=function(){ openSettings(); };
'@ @'
document.getElementById('pausesetbtn').onclick=function(){ openSettings(); };
// vNN.xx, UI REDESIGN ui5q2o (his #50, the Settings shot): THE DETAIL PANE beside the settings list shows the row under the mouse,
// the keyboard or the pad (.padfocus), or the first row when nothing is pointed at, and follows the list when it is redrawn.
(function(){
  var sl=document.getElementById('setlist'), dt=document.getElementById('setdetail'), hov=null, pend=0;
  if(!sl||!dt) return;
  function real(r){ return r&&r.querySelector&&r.querySelector('div > b')&&!/opacity:\s*\.7/.test(r.getAttribute('style')||''); }
  function rowOf(t){ var r=(t&&t.closest)?t.closest('.row'):null; return (r&&sl.contains(r))?r:null; }
  function sync(){
    pend=0;
    var pf=sl.querySelector('.padfocus'), r=pf?rowOf(pf):null, q, i;
    if(!real(r)&&hov){ q=sl.querySelectorAll('.row'); for(i=0;i<q.length;i++){ var bb=q[i].querySelector('div > b'); if(bb&&bb.textContent===hov){ r=q[i]; break; } } }
    if(!real(r)){ q=sl.querySelectorAll('.row'); r=null; for(i=0;i<q.length;i++) if(real(q[i])){ r=q[i]; break; } }
    if(!r){ if(dt.innerHTML) dt.innerHTML=''; return; }
    var b=r.querySelector('div > b'), h=r.querySelector('.hint'), v=r.querySelector('button'), sel=r.querySelector('select');
    var vt=v?v.textContent:(sel&&sel.options[sel.selectedIndex]?sel.options[sel.selectedIndex].text:'');
    var html='<div class="sdk">'+escHtml(b.textContent)+'</div>'+(vt?'<div class="sdv">'+escHtml(vt)+'</div>':'')+(h&&h.textContent?'<div class="sdh">'+escHtml(h.textContent)+'</div>':'');
    if(dt.innerHTML!==html) dt.innerHTML=html;
  }
  function soon(){ if(!pend){ pend=1; setTimeout(sync,0); } }
  sl.addEventListener('mouseover',function(e){ var r=rowOf(e.target); if(real(r)){ hov=r.querySelector('div > b').textContent; soon(); } });
  sl.addEventListener('focusin',function(e){ var r=rowOf(e.target); if(real(r)){ hov=r.querySelector('div > b').textContent; soon(); } });
  try{ new MutationObserver(soon).observe(sl,{childList:true,subtree:true,characterData:true,attributes:true,attributeFilter:['class']}); }catch(_mo){}
  window.__setDetailSync=sync;
})();
'@

SubRx @'
var VER='24.97';
'@ @'
var VER='24.98';
'@

$pat = "(?m)^  now:'v24\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.98: Settings shows the pointed setting large in a detail pane beside the list. Check 24.98 fails on v24.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
