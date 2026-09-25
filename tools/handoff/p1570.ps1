$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
          renderHub(); return;
        }
        var why=(from==='rack')?rackPut(ix,key):planPut(ix,key);   // v11.95: a rack gun, like any item
        if(why){ say2(why); try{ sfx('clank'); }catch(e){} return; }
'@ @'
          renderHub(); return;
        }
        // v15.70, grid audit finding: A KEY DRAGGED ONTO A FILLED KEY ON THE STASH SCREEN BELT SWAPS THE TWO KEYS, AND A KEY ON
        // THE GUN IN HIS HANDS CAN BE MOVED LIKE ANY OTHER. A key dragged off another key went through planPut, which never read
        // what the target key held: Medkit on key 3 dropped on Frag on key 4 took key 4, left key 3 empty and the Frag lost its
        // key, where the floor backpack (v14.25) and the raid (v8.04) swap the two. And planPut counts only the stash, so a key
        // on gun 1 or gun 2 (rackPut binds it alone and the gun stays on the rack) could not move: it was refused as not in the
        // stash with a clank, or, with a spare of that gun in the stash, the spare was packed unasked and went up the lift. A key
        // on a gun in his hands now moves through rackPut, which binds it alone, and after a put that took, what the target key
        // held goes back onto the key the drag came from. A drop from the stash, the backpack or the rack is unchanged.
        var _fk=(typeof from==='string'&&from.indexOf('plan:')===0)?+from.slice(5):-1;   // the key it was dragged off
        var _was=(P.hotAssign||{})[ix];
        var _inHand=(_fk>=0&&String(key).indexOf('gun_')===0&&(P.equipped===String(key).slice(4)||P.equippedSec===String(key).slice(4)));
        var why=(from==='rack'||_inHand)?rackPut(ix,key):planPut(ix,key);   // v11.95: a rack gun, like any item
        if(why){ say2(why); try{ sfx('clank'); }catch(e){} return; }
        if(_fk>=0&&_was&&_was!==key){ P.hotAssign[_fk]=_was; saveProfile(); }   // a key dropped on a filled key swaps, as on the floor (v14.25)
'@
SubRx @'
var VER='15.69';
'@ @'
var VER='15.70';
'@

$pat = "(?m)^  now:'v15\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.70: A KEY DRAGGED ONTO A FILLED KEY ON THE STASH SCREEN BELT SWAPS THE TWO KEYS, AND A KEY ON THE GUN IN HIS HANDS CAN BE MOVED LIKE ANY OTHER. On the tactical belt of the Stash screen, a key dragged onto a filled key took that key and left its own empty, so what the other key held lost its key, and a key on the gun in his hands could not be moved at all, or packed a spare of that gun. The two keys now swap, as they do on the floor and in a raid, and a key on the gun in his hands moves like any other and packs nothing. Check 15.70 drags keys on the Stash screen belt onto a filled key and an empty key; it fails on v15.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
