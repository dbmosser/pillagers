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

# THE GAMBLE SHOWS ITS ODDS AND THE STASH HOTBAR LINES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <div class="plist" id="gamblelist" style="border:1px solid var(--steel);max-height:220px"></div>
'@ @'
    <div id="gambleodds"></div><!-- v35.xx (cw-menupolish2): the mystery tile and the odds of each rarity (gambleOddsDraw) -->
    <div class="plist" id="gamblelist" style="border:1px solid var(--steel);max-height:220px"></div>
'@

SubRx @'
function renderGamble(){
'@ @'
// v35.xx (cw-menupolish2), menus master pass 2026-10-28: THE GAMBLE panel was an empty box over its button until a first roll (its "nothing rolled yet" line is
// hidden on purpose), beside an offer panel with a 192px picture. It now has a mystery tile of the same size and the odds of each rarity, read from
// GAMBLE_POOL (a key counts as rare, as the keys are), each in its rarity colour. Display only: the pool, its weights and the price do not move.
function gambleOdds(){
  var by={}, tot=0, i, k, w, r, out=[], order=['common','uncommon','rare','elite','gold'];
  for(i=0;i<GAMBLE_POOL.length;i++){ k=GAMBLE_POOL[i][0]; w=+GAMBLE_POOL[i][1]||0; r=(k==='KEY')?'rare':((typeof dispR==='function'&&dispR(k))||(ITEMS[k]&&ITEMS[k].r)||'common'); by[r]=(by[r]||0)+w; tot+=w; }
  for(i=0;i<order.length;i++) if(by[order[i]]) out.push([order[i],tot?by[order[i]]/tot:0]);
  return out;
}
function gambleOddsDraw(){
  var el=document.getElementById('gambleodds'), O, h, i, pc;
  if(!el) return false;
  O=gambleOdds(); h='<div class="gbtile"><span>?</span></div><div class="gbodds">';
  for(i=0;i<O.length;i++){ pc=Math.round(O[i][1]*100); h+='<div class="gbrow" style="--rc:'+(RCOL[O[i][0]]||'#9da3a8')+'"><span>'+O[i][0]+'</span><i><b style="width:'+pc+'%"></b></i><em>'+pc+'%</em></div>'; }
  el.innerHTML=h+'</div>';
  return true;
}
function renderGamble(){
'@

SubRx @'
  el.innerHTML=h;
  var b=document.getElementById('gamblebtn');
'@ @'
  el.innerHTML=h;
  try{ gambleOddsDraw(); }catch(_god){}   // v35.xx (cw-menupolish2): the mystery tile and the odds
  var b=document.getElementById('gamblebtn');
'@

SubRx @'
#root #gamblemodal #wirtlot > span[title] img{width:176px !important;height:176px !important;}
'@ @'
#root #gamblemodal #wirtlot > span[title] img{width:176px !important;height:176px !important;}
/* v35.xx (cw-menupolish2): THE GAMBLE panel: a 192px mystery tile (the offer picture's size) beside the odds, one row a rarity; the roll list takes what is left: name in its colour, a 6px bar, the percent */
#root #gamblemodal #gambleodds{flex:none;display:flex;flex-direction:row;align-items:center;gap:var(--sp-3);width:100%;}
#root #gamblemodal #wirtsec_gamble #gamblelist{min-height:0;}
#root #gamblemodal #gambleodds .gbtile{flex:none;box-sizing:border-box;width:192px;height:192px;display:flex;align-items:center;justify-content:center;border-radius:var(--rad);background:radial-gradient(circle at 50% 50%,rgba(168,102,224,.24),rgba(0,0,0,0) 68%),var(--ui-raised);font:700 112px/1 var(--f-cond);color:var(--tx-2);}
#root #gamblemodal #gambleodds .gbodds{flex:1 1 auto;min-width:0;display:flex;flex-direction:column;gap:var(--sp-1);}
#root #gamblemodal #gambleodds .gbrow{display:grid;grid-template-columns:calc(var(--sp-1) * 14) 1fr calc(var(--sp-1) * 7);gap:var(--sp-2);align-items:center;font:600 var(--fs-label)/1.4 var(--f-cond);letter-spacing:var(--track);}
#root #gamblemodal #gambleodds .gbrow span{color:var(--rc);}
#root #gamblemodal #gambleodds .gbrow i{display:block;height:6px;border-radius:3px;overflow:hidden;background:var(--ui-line);}
#root #gamblemodal #gambleodds .gbrow i b{display:block;height:100%;background:var(--rc);}
#root #gamblemodal #gambleodds .gbrow em{font-style:normal;text-align:right;font-variant-numeric:tabular-nums;color:var(--tx-2);}
'@

SubRx @'
#root #hub #hotplanwrap>div>div>div>div:first-child{display:grid!important;grid-template-columns:repeat(9,minmax(0,1fr));gap:8px!important;width:100%;}
'@ @'
#root #hub #hotplanwrap>div>div>div>div:first-child{display:grid!important;grid-template-columns:repeat(9,minmax(0,1fr));gap:8px!important;width:100%;}
#root #hub #hotplanwrap{box-sizing:border-box;padding:0 12px;}   /* v35.xx (cw-menupolish2): the hotbar slots sit on the backpack grid's 12px inset; they ran to the panel edge */
'@

SubRx @'
function renderKitCol(){
'@ @'
// v35.xx (cw-menupolish2), menus master pass 2026-10-28: THE HOTBAR ENDS WHERE THE BACKPACK ROW ENDS. The backpack box scrolls, and on a
// Windows screen its 8px scroll bar takes width from the slots, so on the 12px inset alone the hotbar ran 6px past them at 1080. The hotbar's
// right inset takes the same scroll bar width (none when the box does not scroll). Display only.
// The stash renders while it is still hidden (the terminal adds .on after renderHub), so a ResizeObserver on the box measures again when
// it shows and when its scroll bar comes or goes (its content box narrows); setting the hotbar inset never resizes the box.
var _hotInsetRO=null;
function hotInsetSync(){
  var kg=document.getElementById('kitgrid'), hw=document.getElementById('hotplanwrap'), cs, sb;
  if(!kg||!hw) return;
  if(!_hotInsetRO&&typeof ResizeObserver==='function'){ _hotInsetRO=new ResizeObserver(function(){ try{ hotInsetSync(); }catch(_hr){} }); _hotInsetRO.observe(kg); }
  cs=getComputedStyle(kg);
  sb=Math.max(0,kg.offsetWidth-kg.clientWidth-(parseFloat(cs.borderLeftWidth)||0)-(parseFloat(cs.borderRightWidth)||0));
  hw.style.paddingRight=(12+sb)+'px';
}
function renderKitCol(){
'@

SubRx @'
  renderKitCol();

  shown.forEach(function(k){
'@ @'
  renderKitCol();
  try{ hotInsetSync(); }catch(_his){}   // v35.xx (cw-menupolish2): the hotbar ends on the backpack row, scroll bar or not

  shown.forEach(function(k){
'@

SubRx @'
var VER='35.92';
'@ @'
var VER='35.93';
'@

$pat = "(?m)^  now:'v35\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.93: the gamble shows its odds by rarity and the stash hotbar lines up Check 35.93 fails on v35.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
