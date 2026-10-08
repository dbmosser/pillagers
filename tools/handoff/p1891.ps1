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

# UNDERCROFT FLOOR: GUN KEYS CAN BE PICKED UP, AND GUN 2 DROPPED ON KEY 1 BECOMES GUN 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(_sl&&_sdk&&!(_sl.k==='gunA'||_sl.k==='gunB')){ G.drag={key:_sdk,fromHot:_H.i,px:mouse.x,py:mouse.y}; blip('pick'); }   // v11.97: a key holding a gun drags on the floor too
'@ @'
if(_sl&&_sdk&&!(_sl.k==='gunA'||_sl.k==='gunB')){ G.drag={key:_sdk,fromHot:_H.i,px:mouse.x,py:mouse.y}; blip('pick'); }   // v11.97: a key holding a gun drags on the floor too
          // v18.91, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". A gun cell on the floor belt (gun 1 or gun 2, on key 1 or 2, or on key 8 or 9 when an item is bound over its own key) took the press and picked nothing up, without a word. It picks up now, as in a raid; the release below says where it went.
          else if(_sl&&_sl.kind==='gun'&&(_sl.k==='gunA'||_sl.k==='gunB')&&!_sl.vacant&&_sl.icon&&_sl.icon!=='fists'&&ITEMS['gun_'+_sl.icon]){ G.drag={key:'gun_'+_sl.icon,gunSlot:_sl.k,fromHot:_H.i,px:mouse.x,py:mouse.y}; blip('pick'); }
'@

SubRx @'
if(d.fromHot===_H.i) return;
'@ @'
// v18.91, his report (2026-10-07): a gun cell dropped on the other gun's key makes it that gun: gun 1 and gun 2 trade places in his hands (P.equipped and P.equippedSec, what the raid starts with), so the key he let go on shows it. Dropped back on its own key, the item bound there goes to the key the gun came from. Anywhere else it is refused in words, on the floor's own line, because say() here writes to the backpack copy, which nothing draws.
          if(d.gunSlot){
            if(d.fromHot===_H.i) return;
            var _hb8s=hotbarSlots(), _hb8t=_hb8s[_H.i], _hb8w=WEAPONS[d.key.slice(4)], _hb8n=(_hb8w&&_hb8w.name)||'That gun', _hb8h=(d.gunSlot==='gunA')?0:1;
            if(_hb8t&&(_hb8t.k==='gunA'||_hb8t.k==='gunB')&&_hb8t.k!==d.gunSlot){
              var _hb8a=P.equipped, _hb8b=P.equippedSec;
              if(!(_hb8a&&_hb8a!=='fists'&&WEAPONS[_hb8a]&&_hb8b&&_hb8b!=='none'&&_hb8b!=='fists'&&WEAPONS[_hb8b])){ hubToast(_hb8n+' is your only gun, so there is no other gun for it to trade places with.'); return; }
              P.equipped=_hb8b; P.equippedSec=_hb8a;
              G.player=hubBagState().player;
              blip('pick'); hubToast(_hb8n+' to slot '+(_H.i+1)+'.');
              return;
            }
            if(_H.i===_hb8h&&d.fromHot>=2&&G.hotAssign&&G.hotAssign[_hb8h]!==undefined&&G.hotAssign[d.fromHot]===undefined){
              var _hb8c=G.hotAssign[_hb8h]; delete G.hotAssign[_hb8h]; G.hotAssign[d.fromHot]=_hb8c;
              blip('pick'); hubToast(_hb8n+' to slot '+(_hb8h+1)+'. '+((ITEMS[_hb8c]&&ITEMS[_hb8c].name)||'Item')+' to slot '+(d.fromHot+1)+'.');
              return;
            }
            hubToast('Keys 1 and 2 are your two guns. Drop it on the other gun to trade them.');
            return;
          }
          if(d.fromHot===_H.i) return;
'@

SubRx @'
if(d.fromHot!==undefined&&G.hotAssign&&!(d.px!==undefined&&Math.sqrt(
'@ @'
// v18.91, his report (2026-10-07): a gun cell let go off the floor belt stays in his hands, and says how to take it out.
          if(d.gunSlot){ if(!(d.px!==undefined&&Math.sqrt((mouse.x-d.px)*(mouse.x-d.px)+(mouse.y-d.py)*(mouse.y-d.py))<=24)) hubToast('To take a gun out of your hands, open it in the armoury on the Stash screen.'); return; }
          if(d.fromHot!==undefined&&G.hotAssign&&!(d.px!==undefined&&Math.sqrt(
'@

SubRx @'
var VER='18.90';
'@ @'
var VER='18.91';
'@

$pat = "(?m)^  now:'v18\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.91: On the Undercroft floor gun keys can be dragged, and gun 2 dropped on key 1 becomes gun 1. Check 18.91 fails on v18.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
