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

# DRAG GUN 2 ONTO KEY 1 TO SWAP KEYS 1 AND 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
else if(_onCell>=0&&_onCell!==d.fromHot) say('Drop it off the belt to stow it in the backpack; its own key brings it up.');
'@ @'
else if(_onCell>=0&&_onCell!==d.fromHot){
        // v18.89, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". A gun in a hand cell dropped on another belt key was always refused, so nothing could change which gun keys 1 and 2 show, and a gun the belt had moved down to key 8 or 9 (because an item is bound over its own key) could never go back. Dropped on the other gun's key, the two keys trade places (p.swapped; the hands do not change). Dropped back on its own key, the item bound there goes to the key the gun came from. Anywhere else it is refused in words, as before.
        var _gw8s=hotbarSlots(), _gw8t=_gw8s[_onCell], _gw8p=G.player, _gw8g=null, _gw8q, _gw8h=(d.gunSlot==='gunA')?0:1;
        for(_gw8q=0;_gw8q<_gw8s.length;_gw8q++) if(_gw8s[_gw8q]&&_gw8s[_gw8q].k===d.gunSlot){ _gw8g=_gw8s[_gw8q]; break; }
        var _gw8n=(_gw8g&&_gw8g.name)||'That gun';
        if(_gw8t&&(_gw8t.k==='gunA'||_gw8t.k==='gunB')&&_gw8t.k!==d.gunSlot&&_gw8p&&_gw8p.wep&&_gw8p.sec){
          _gw8p.swapped=!_gw8p.swapped; G.hot=gunCell(); blip('pick');
          say(_gw8n+' to slot '+(_onCell+1)+'.');
        }
        else if(_onCell===_gw8h&&d.fromHot>=2&&G.hotAssign&&G.hotAssign[_gw8h]!==undefined&&G.hotAssign[d.fromHot]===undefined){
          var _gw8c=G.hotAssign[_gw8h]; G.hotAuto=G.hotAuto||{}; var _gw8a=G.hotAuto[_gw8h];
          delete G.hotAssign[_gw8h]; delete G.hotAuto[_gw8h];
          G.hotAssign[d.fromHot]=_gw8c; if(_gw8a) G.hotAuto[d.fromHot]=1;
          if(!G.sim){ var _gw8f={}; for(var _gw8k in G.hotAssign) if(!G.hotAuto[_gw8k]) _gw8f[_gw8k]=G.hotAssign[_gw8k]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_gw8f))); try{ saveProfile(); }catch(_gw8e){} }
          G.hot=gunCell(); blip('pick');
          say(_gw8n+' to slot '+(_gw8h+1)+'. '+((ITEMS[_gw8c]&&ITEMS[_gw8c].name)||'Item')+' to slot '+(d.fromHot+1)+'.');
        }
        else say('Drop it off the belt to stow it in the backpack; its own key brings it up.');
      }
'@

SubRx @'
var VER='18.88';
'@ @'
var VER='18.89';
'@

$pat = "(?m)^  now:'v18\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.89: Dragging one gun key onto the other swaps keys 1 and 2. Check 18.89 fails on v18.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
