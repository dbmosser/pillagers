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

# NO WHITE BARS ANYWHERE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function iconSprite(key,S){
'@ @'
function iconSprite(key,S,np){   // cw-whitebars, his order 10-27 ("remove the white bars under items everywhere"): np paints the sprite without the rank pips
'@

SubRx @'
k=key+'|'+Math.round(S)+'|'+R; e=ICONSPR.m[k];
'@ @'
k=key+'|'+Math.round(S)+'|'+R+(np?'|np':''); e=ICONSPR.m[k];
'@

SubRx @'
drawItemIcon(c2,key,side/2,side/2,S*R);
'@ @'
(np?drawItemIconArt:drawItemIcon)(c2,key,side/2,side/2,S*R);
'@

SubRx @'
function drawIconSprite(c,key,cx,cy,S){
'@ @'
function drawIconSprite(c,key,cx,cy,S,np){
'@

SubRx @'
try{ e=iconSprite(key,S); }catch(_is){ e=null; }
'@ @'
try{ e=iconSprite(key,S,np); }catch(_is){ e=null; }
'@

SubRx @'
if(!e){ drawItemIcon(c,key,cx,cy,S); return false; }
'@ @'
if(!e){ (np?drawItemIconArt:drawItemIcon)(c,key,cx,cy,S); return false; }
'@

SubRx @'
drawIconSprite(ctx,h.k,x+LH(30),y+bh/2,LH(34));
'@ @'
drawIconSprite(ctx,h.k,x+LH(30),y+bh/2,LH(34),1); // cw-whitebars, his order 10-27: no cream rank pips
'@

SubRx @'
drawIconSprite(ctx,k,ix,iy,sz);
'@ @'
drawIconSprite(ctx,k,ix,iy,sz,1);
'@

SubRx @'
if(S.icon){ drawIconSprite(ctx,S.icon,cx2,cy2,bw*0.64); }
'@ @'
if(S.icon){ drawIconSprite(ctx,S.icon,cx2,cy2,bw*0.64,1); }
'@

SubRx @'
try{ e=iconSprite(id,S); }catch(_gi){ e=null; }
'@ @'
try{ e=iconSprite(id,S,1); }catch(_gi){ e=null; }
'@

SubRx @'
drawIconSprite(ctx,G.drag.key,cx,cy,size*.85);
'@ @'
drawIconSprite(ctx,G.drag.key,cx,cy,size*.85,1);
'@

SubRx @'
drawItemIcon(ctx,G.drag.key,mouse.x,mouse.y,ds*0.72);
'@ @'
drawItemIconArt(ctx,G.drag.key,mouse.x,mouse.y,ds*0.72);
'@

SubRx @'
drawIconSprite(ctx,G.player.wep.id,left+72*s,top+80*s,72*s);
'@ @'
drawIconSprite(ctx,G.player.wep.id,left+72*s,top+80*s,72*s,1);
'@

SubRx @'
drawIconSprite(ctx,st.key,tx+tile/2,ty+tile*.47,tile*.62);
'@ @'
drawIconSprite(ctx,st.key,tx+tile/2,ty+tile*.47,tile*.62,1);
'@

SubRx @'
drawIconSprite(ctx,key,dx+72*s,top+56*s,96*s);
'@ @'
drawIconSprite(ctx,key,dx+72*s,top+56*s,96*s,1);
'@

SubRx @'
drawIconSprite(ctx,p.wep.id,x+11+LH(16)*BZ,cy-LH(2)*BZ,LH(30)*BZ);
'@ @'
drawIconSprite(ctx,p.wep.id,x+11+LH(16)*BZ,cy-LH(2)*BZ,LH(30)*BZ,1);
'@

SubRx @'
drawIconSprite(ctx,st.key,tx+TILE/2,ty+TILE/2-LH(2)*BZ,TILE*0.62);
'@ @'
drawIconSprite(ctx,st.key,tx+TILE/2,ty+TILE/2-LH(2)*BZ,TILE*0.62,1);
'@

SubRx @'
if(!S.sold) drawItemIcon(ctx,S.k,x+LH(24),cy-LH(5),LH(18));
'@ @'
if(!S.sold) drawItemIconArt(ctx,S.k,x+LH(24),cy-LH(5),LH(18));
'@

SubRx @'
else drawItemIcon(_wx,_wc[_wi].getAttribute('data-k'),28,28,40);
'@ @'
else drawItemIconArt(_wx,_wc[_wi].getAttribute('data-k'),28,28,40);
'@

SubRx @'
iconImgHTML(keys[k],52)
'@ @'
iconImgHTML(keys[k],52,1)
'@

SubRx @'
iconImgHTML(_lk2,32)
'@ @'
iconImgHTML(_lk2,32,1)
'@

SubRx @'
        lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,32)
'@ @'
        lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,32,1)
'@

SubRx @'
else lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,32)
'@ @'
else lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,32,1)
'@

SubRx @'
iconImgHTML(id,52)
'@ @'
iconImgHTML(id,52,1)
'@

SubRx @'
iconImgHTML(ks[i],56)
'@ @'
iconImgHTML(ks[i],56,1)
'@

SubRx @'
iconImgHTML(k,22)+
'@ @'
iconImgHTML(k,22,1)+
'@

SubRx @'
iconImgHTML(sk,22)+
'@ @'
iconImgHTML(sk,22,1)+
'@

SubRx @'
iconImgHTML(k,30)+(count>1
'@ @'
iconImgHTML(k,30,1)+(count>1
'@

SubRx @'
iconImgHTML(k,30)+(counts[k]>1
'@ @'
iconImgHTML(k,30,1)+(counts[k]>1
'@

SubRx @'
iconImgHTML(_ik,30)
'@ @'
iconImgHTML(_ik,30,1)
'@

SubRx @'
iconImgHTML(GUN_CLASS_ICON[gl[i]],30)
'@ @'
iconImgHTML(GUN_CLASS_ICON[gl[i]],30,1)
'@

SubRx @'
iconImgHTML(wl[cell[i]],30)
'@ @'
iconImgHTML(wl[cell[i]],30,1)
'@

SubRx @'
iconImgHTML(k,(where?22:40))
'@ @'
iconImgHTML(k,(where?22:40),1)
'@

SubRx @'
iconImgHTML(_fg.k,(where?22:40))
'@ @'
iconImgHTML(_fg.k,(where?22:40),1)
'@

SubRx @'
var VER='35.39';
'@ @'
var VER='35.40';
'@

$pat = "(?m)^  now:'v35\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.40: no cream rank bars under item pictures on the raid belt, hand, wheel, backpack, stash, hotbar, pre-raid pack, extracted card, KIA card and the rest of the menus; loot rows keep theirs; the rarity colour borders and the ammo bar stay Check 35.40 fails on v35.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
