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

# PRE-RAID: A BUY CONTROL ON EACH PACK ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function syncSectorPack(){
'@ @'
/* v28.xx (cw-packbuy), HIS ORDER (2026-10-20): "on the rpre raid screen, next to the pack items, to the right, there should also be an ability to purchase those items (skip some of the guns if they aren't purchaseable)". One price list: the Undercroft counter's SHOP, its stock roll (shopStocked) and the same banked credits (P.credits, stash pays). A gun the counter never sells (blue, purple, gold, the burst carbine) gets no control. */ function packBuyRec(k){ var it=ITEMS[k], i, o; if(!it) return null; for(i=0;i<SHOP.length;i++){ o=SHOP[i]; if(!o) continue; if(o.kind==='item'&&o.k===k) return o; if(o.kind==='wep'&&it.use==='gun'&&it.gk&&it.gk===o.k) return o; } return null; }
function packBuyOk(k){ var o=packBuyRec(k); return (o&&shopStocked(o)&&(P.xp||0)>=o.rep)?o:null; }
function packBuyHtml(k){ var o=packBuyOk(k); if(!o) return ''; return '<button class="srbuy'+(P.credits>=o.price?'':' dis')+'" data-pb="1" data-pan="p">$'+o.price.toLocaleString()+'</button>'; }
function packBuy(k){ var o=packBuyOk(k); if(!o||P.credits<o.price) return false; P.credits-=o.price; P.stash.push(k); shopBought(ITEMS[k].name,o.price,''); saveProfile(); try{ renderHub(); }catch(_bh){} return true; }
function syncSectorPack(){
'@

SubRx @'
>+</button></span></div>';
'@ @'
>+</button></span>'+packBuyHtml(k)+'</div>';
'@

SubRx @'
ev.target.closest('[data-pd],[data-pa],[data-core]')
'@ @'
ev.target.closest('[data-pd],[data-pa],[data-core],[data-pb]')
'@

SubRx @'
if(t.getAttribute('data-core')){ if(!packCore()) return; }
'@ @'
if(t.getAttribute('data-pb')){ ch=t.closest('[data-pk]'); pk=ch?ch.getAttribute('data-pk'):null; if(!pk||!packBuy(pk)) return; }   /* v28.xx (cw-packbuy): too few credits changes nothing */
    else if(t.getAttribute('data-core')){ if(!packCore()) return; }
'@

SubRx @'
try{ syncSectorKit(); }catch(_pk){} try{ refreshInv(); }catch(_pr){}
'@ @'
try{ syncSectorKit(); }catch(_pk){} try{ refreshInv(); }catch(_pr){} try{ if(t.getAttribute('data-pb')&&PAD&&PAD.focus&&!document.contains(PAD.focus)){ var _nb=host.querySelector('[data-pk="'+pk+'"] [data-pb]'); if(_nb) padSetFocus(_nb); } }catch(_pf){}
'@

SubRx @'
pk=row.getAttribute('data-pk'); packSet(pk,packedCount(pk)+mv[0]);
'@ @'
pk=row.getAttribute('data-pk');
    if(cur.getAttribute('data-pb')){ if(mv[0]<0){ nb=row.querySelector('button[data-pd="1"]'); if(nb) padSetFocus(nb); } return true; }   /* v28.xx (cw-packbuy): the row runs stepper, then buy */
    if(mv[0]>0&&cur.getAttribute('data-pd')==='1'){ nb=row.querySelector('[data-pb]'); if(nb){ padSetFocus(nb); return true; } }
    packSet(pk,packedCount(pk)+mv[0]);
'@

SubRx @'
#sectormodal .srprow .st b{ width:30px; text-align:center; font:700 20px var(--f-cond); cursor:pointer; }
'@ @'
#sectormodal .srprow .st b{ width:30px; text-align:center; font:700 20px var(--f-cond); cursor:pointer; } #root #sectormodal .srprow .srbuy{ flex:none; min-width:76px; height:44px; padding:0 10px; background:var(--ui-raised); border:1px solid var(--acc); border-radius:0; color:var(--acc); font:700 18px var(--f-cond); cursor:pointer; } #root #sectormodal .srprow .srbuy.dis{ border-color:var(--ui-line-hi); color:var(--danger); opacity:.65; cursor:default; } #root #sectormodal .srprow .srbuy.padfocus{ outline:2px solid var(--srseat); }
'@

SubRx @'
var VER='33.43';
'@ @'
var VER='33.44';
'@

$pat = "(?m)^  now:'v33\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.44: On the pre-raid page each pack row now has a price button on its right. One press buys one into your stash. Check 33.44 fails on v33.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
