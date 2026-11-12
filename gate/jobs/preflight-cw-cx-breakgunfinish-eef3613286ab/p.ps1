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

# CLEAR STASH GUN MENU SELECTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  html #root #hub #stashgrid .cell .cnt{color:var(--tx-1)!important;background:var(--ui-panel)!important;}
'@ @'
  html #root #hub #stashgrid .cell .cnt{color:var(--tx-1)!important;background:var(--ui-panel)!important;}
  /* v28.xx (cw-cx-breakgunfinish): menu selection has its own ring; empty spaces are decoration, never inventory capacity or controls. */
  html #root #hub #stashgrid .cell.stash-selected{outline:2px solid var(--acc)!important;outline-offset:2px;transition-property:background-color,border-color,box-shadow,color,opacity,transform;}
  html #root #hub #stashgrid .stash-space{box-sizing:border-box;height:var(--stash-slot-h);min-width:0;border:1px dashed var(--ui-line);border-radius:var(--rad);background:transparent;opacity:.45;pointer-events:none;}
  html #root #hub #gearbtn{margin-left:16px!important;padding-left:16px!important;border-left:1px solid var(--ui-line)!important;}
  #topright .trcash{font-size:16px;font-weight:600;color:var(--tx-2);margin-right:8px;letter-spacing:.04em;}
'@

SubRx @'
function closeItemMenu(){
  if(IMENU&&IMENU.parentNode) IMENU.parentNode.removeChild(IMENU);
'@ @'
function closeItemMenu(){
  // v28.xx (cw-cx-breakgunfinish): the source ring belongs to this menu, including keyboard opening and closing.
  if(IMENU&&IMENU.stashSource) IMENU.stashSource.classList.remove('stash-selected');
  if(IMENU&&IMENU.parentNode) IMENU.parentNode.removeChild(IMENU);
'@

SubRx @'
    if(x>=b.left&&x<=b.right&&y>=b.top&&y<=b.bottom) source=b;
'@ @'
    // v28.xx (cw-cx-breakgunfinish): both devices identify one source, including a click exactly on a shared tile edge.
    if(!source&&x>=b.left&&x<=b.right&&y>=b.top&&y<=b.bottom){
      source=b; m.stashSource=cells[i]; cells[i].classList.add('stash-selected');
    }
'@

SubRx @'
          b.textContent=String(slot+1);
          if((P.hotAssign||{})[slot]===key) b.className='mine';
'@ @'
          // v28.xx (cw-cx-breakgunfinish): the stash key label matches Digit0, the hotbar and the footer; its action remains slot nine.
          b.textContent=m.classList.contains('stash-actions')&&slot===9?'0':String(slot+1);
          if((P.hotAssign||{})[slot]===key) b.className='mine';
'@

SubRx @'
<div class="loslab">Backpack<b><span id="kitn">0</span> packed</b></div>
'@ @'
<div class="loslab"><b><span id="kitn">0</span> packed</b></div><!-- v28.xx (cw-cx-breakgunfinish): the tab already names the backpack; this row keeps its live count. -->
'@

SubRx @'
  el.innerHTML='\x24'+c+'<span class="trgap"></span><small class="trl">STASH</small>
'@ @'
  el.innerHTML='<span class="trcash">cash</span> \x24'+c+'<span class="trgap"></span><small class="trl">STASH</small>
'@

SubRx @'
function stashFilterApply(){
'@ @'
// v28.xx (cw-cx-breakgunfinish): a faint, noninteractive empty grid fills unused stash space. It never changes a profile, item count or scroll capacity.
function stashBlankSlots(){
  var z=document.getElementById('stashgrid'); if(!z) return;
  [].forEach.call(z.querySelectorAll('.stash-space'),function(e){ e.remove(); });
  if(!z.clientWidth||!z.clientHeight) return;
  var cs=getComputedStyle(z), cols=cs.gridTemplateColumns.trim().split(/\s+/), n=cols.length, w=parseFloat(cols[0]);
  if(!isFinite(w)||w<=0) return;
  var cells=[].filter.call(z.querySelectorAll('.cell'),function(e){ return e.offsetHeight>0; }), rh=cells.length?cells[0].offsetHeight:w;
  var gap=parseFloat(cs.rowGap)||0, h=z.clientHeight-(parseFloat(cs.paddingTop)||0)-(parseFloat(cs.paddingBottom)||0);
  var empty=z.querySelector('.cellempty'), used=cells.length+(empty&&empty.offsetHeight?n:0), rows=Math.floor((h+gap)/(rh+gap));
  var count=Math.min(120,Math.max(0,rows*n-used)), f=document.createDocumentFragment();
  z.style.setProperty('--stash-slot-h',rh+'px');
  for(var i=0;i<count;i++){ var e=document.createElement('div'); e.className='stash-space'; e.setAttribute('aria-hidden','true'); f.appendChild(e); }
  z.appendChild(f);
}
function stashFilterApply(){
'@

SubRx @'
  return n;
}function stashTabOf(k){
'@ @'
  stashBlankSlots(); // v28.xx (cw-cx-breakgunfinish): search redraws only decoration around the visible cells.
  return n;
}function stashTabOf(k){
'@

SubRx @'
var VER='37.69';
'@ @'
var VER='37.70';
'@

$pat = "(?m)^  now:'v37\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.70: The stash gun menu marks its source with a separate 2px lime ring until closing. Its last key reads 0 and still binds slot nine. Empty spaces have faint noninteractive outlines with no inventory limit. The repeated backpack heading is removed, section shortcuts are separated from filters, and cash has a matching label beside stash and bag values. Check 37.70 fails on v37.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
