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

# STASH LOADOUT IN TWO TABS: BACKPACK AND KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="lohead">LOADOUT<em>$<span id="kitval">0</span> going up</em></div>
'@ @'
<div class="lohead"><span class="lotabs" id="lotabs" role="tablist"><button type="button" data-lt="pack" class="on" aria-selected="true">BACKPACK</button><button type="button" data-lt="keys" aria-selected="false">KEYS</button></span><em>$<span id="kitval">0</span> going up</em></div><!-- v28.xx (cw-stashtabs), HIS PICK 2026-10-28: the loadout column in two tabs, on its title line so they cost no height -->
'@

SubRx @'
#root #hub #stashdetail>div>div{line-height:1.3!important;}
'@ @'
#root #hub #stashdetail>div>div{line-height:1.3!important;}
/* v28.xx (cw-stashtabs), HIS PICK (2026-10-28, "Ok I guess go with A"): at his 4K screen the loadout column had 207 to 255px for 410px of content, so the 12 backpack slots got no room and the key hints sat on the gun keys. The column has two tabs now: BACKPACK (the 12 slots at full size, then the hotbar) and KEYS (gun keys and the item wheel). The 160px details strip is a card beside the stash item under the mouse or the pad highlight; it floats, so nothing resizes (his 10-27 order), and its buttons stay on the right-click menu. */
html #root #hub #lotabs{display:flex;align-items:baseline;gap:24px;}
html #root #hub #lotabs button{appearance:none;background:none!important;border:0!important;border-radius:0!important;box-shadow:none!important;min-height:0!important;min-width:0!important;margin:0!important;padding:0!important;font:inherit!important;letter-spacing:inherit;color:var(--tx-2)!important;cursor:pointer;text-decoration:underline 3px transparent;text-underline-offset:8px;}
html #root #hub #lotabs button.on{color:var(--tx-1)!important;text-decoration-color:var(--acc);}
html #root #hub #lotabs button:hover{color:var(--tx-1)!important;}
html #root #hub #kitcol.lt-keys > .losec:not(#kitsetup),html #root #hub #kitcol.lt-keys > #firstkit{display:none!important;}
html #root #hub #kitcol:not(.lt-keys) > #kitsetup{display:none!important;}
html #root #hub #kitcol > #kitsetup{border-top:none!important;}
html #root #hub #kitcol .losec{flex:none!important;}
html #root #hub #kitgrid{flex:none!important;height:auto!important;min-height:0!important;max-height:none!important;overflow:visible!important;grid-template-columns:repeat(6,minmax(0,1fr))!important;gap:8px!important;}
html #root #hub #kitgrid .cell{width:auto!important;height:auto!important;min-height:0!important;aspect-ratio:1/1;}
html #root #hub #stashdetail{position:absolute!important;z-index:40;display:none!important;box-sizing:border-box;width:min(560px,46%);height:auto!important;min-height:0!important;max-height:none!important;overflow:visible!important;pointer-events:none;margin:0!important;padding:12px 16px!important;font-size:var(--fs-label)!important;background:var(--ui-raised)!important;border:1px solid var(--ui-line-hi)!important;}
html #root #hub #stashdetail.sdon{display:block!important;}
html #root #hub #stashdetail #stashacts{display:none!important;}
html #root #hub #stashdetail>div{grid-template-rows:none!important;grid-auto-flow:row!important;grid-template-columns:repeat(2,minmax(0,1fr));}
'@

SubRx @'
  if(el!==old&&el.closest&&el.closest('#stashgrid')){ try{ if(typeof el.onmouseenter==='function') el.onmouseenter(); else el.dispatchEvent(new MouseEvent('mouseenter')); }catch(_me){} }
'@ @'
  if(el!==old&&el.closest&&el.closest('#stashgrid')){ try{ if(typeof el.onmouseenter==='function') el.onmouseenter(); else el.dispatchEvent(new MouseEvent('mouseenter')); }catch(_me){} }
  try{ stashCardAt(el); }catch(_sc){}   // v28.xx (cw-stashtabs): the details card follows the pad highlight
'@

SubRx @'
function padMenu(pressed){
'@ @'
// v28.xx (cw-stashtabs), HIS PICK 2026-10-28: the loadout column's two tabs (BACKPACK, KEYS) and the stash details card. The card is the
// old details strip (#stashdetail, written by the stash cell's onmouseenter as before), floated beside the cell under the mouse or the pad
// highlight, kept inside the window, hidden when nothing is under it. Only stash cells write it, so only stash cells show it.
function stashCardAt(cell){
  var d=document.getElementById('stashdetail'); if(!d) return;
  if(!cell||!cell.closest||!cell.closest('#stashgrid')||!d.innerHTML.trim()){ d.classList.remove('sdon'); return; }
  d.classList.add('sdon');
  var par=d.offsetParent; if(!par) return;
  var z=(d.getBoundingClientRect().width/(d.offsetWidth||1))||1, cr=cell.getBoundingClientRect(), pr=par.getBoundingClientRect(), w=d.offsetWidth, h=d.offsetHeight;
  var x=(cr.right-pr.left)/z+12, y=(cr.top-pr.top)/z;
  if(x+w>par.clientWidth-8) x=(cr.left-pr.left)/z-12-w;
  if(x<8) x=8; if(y+h>par.clientHeight-8) y=par.clientHeight-8-h; if(y<8) y=8;
  d.style.left=Math.round(x)+'px'; d.style.top=Math.round(y)+'px';
}
function stashTabSet(keys){
  var c=document.getElementById('kitcol'); if(!c) return;
  c.classList.toggle('lt-keys',!!keys);
  [].forEach.call(document.querySelectorAll('#lotabs button[data-lt]'),function(b){ var on=(b.getAttribute('data-lt')==='keys')===!!keys; b.classList.toggle('on',on); b.setAttribute('aria-selected',on?'true':'false'); });
}
document.addEventListener('click',function(ev){ var b=ev.target&&ev.target.closest?ev.target.closest('#lotabs button[data-lt]'):null; if(!b) return; stashTabSet(b.getAttribute('data-lt')==='keys'); try{ sndUi('move'); }catch(_su){} });
document.addEventListener('mouseover',function(ev){ var c=ev.target&&ev.target.closest?ev.target.closest('#stashgrid .cell'):null; if(c) setTimeout(function(){ stashCardAt(c); },0); });
document.addEventListener('mouseout',function(ev){ var c=ev.target&&ev.target.closest?ev.target.closest('#stashgrid .cell'):null; if(c&&!(ev.relatedTarget&&c.contains(ev.relatedTarget))) stashCardAt(null); });
function padMenu(pressed){
'@

SubRx @'
var VER='36.20';
'@ @'
var VER='36.21';
'@

$pat = "(?m)^  now:'v36\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.21: the stash loadout has a backpack tab and a keys tab, and item details pop up beside the item Check 36.21 fails on v36.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
