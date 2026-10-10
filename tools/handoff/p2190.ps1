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

# GUN KEYS: THE FLOOR AND THE LOANER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hcReal(_hc[_fh])&&!_hcOnKey(_hc[_fh])) _fp=_fh;
    for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hc[_fh]&&!_hc[_fh].vacant&&!_hcReal(_hc[_fh])) _fp=_fh;
    if(_fp<0&&_hc[1]&&_hc[1].vacant&&!_hcUsed[1]) _fp=1;
'@ @'
    if(G.hubFloor){
      // v21.90, from the review of 21.83: THE UNDERCROFT BELT KEEPS ITS OLD ORDER until the floor edits the gun keys itself: gun 1
      // only on key 1 and gun 2 only on key 2, and a gun whose key holds an item of his goes on to v17.17 below. Filling a covered
      // key 1 put gun 1 on key 2 and sent gun 2 to key 9, where the floor release (v18.91, which goes by gun 1 and gun 2) could
      // bring neither gun back onto key 1; and with no gun 1 it showed gun 2 on key 1 and Bare Hands on key 2.
      if(_fk<2&&!_hcUsed[_fk]&&_hc[_fk]) _fp=_fk;
    } else {
      for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hcReal(_hc[_fh])&&!_hcOnKey(_hc[_fh])) _fp=_fh;
      for(_fh=0;_fh<2&&_fp<0;_fh++) if(!_hcUsed[_fh]&&_hc[_fh]&&!_hc[_fh].vacant&&!_hcReal(_hc[_fh])) _fp=_fh;
      if(_fp<0&&_hc[1]&&_hc[1].vacant&&!_hcUsed[1]) _fp=1;
    }
'@

SubRx @'
  var sw=!!p.swapped, HG=[sw?p.sec:p.wep, sw?p.wep:p.sec];
'@ @'
  var sw=!!p.swapped, HG=[sw?p.sec:p.wep, sw?p.wep:p.sec];
  // v21.90, from the review of 21.83: AT THE RAID START EACH GUN FIRST TAKES ITS OWN KEY (gun 1 key 1, gun 2 key 2) when no key of
  // his covers it, so the raid starts on the keys the Undercroft belt showed: with a Medkit on key 1, gun 2 on key 2 and gun 1 on
  // the last free key (v17.17), not gun 1 on key 2.
  if(o.deploy) for(h=0;h<2&&h<GUNKEYS;h++){
    w=HG[h]; if(!w||w.id==='fists'||w.mag===0||!ITEMS['gun_'+w.id]||A[h]!==undefined) continue;
    has=false; for(k in A) if(A[k]==='gun_'+w.id) has=true;
    if(!has){ A[h]='gun_'+w.id; U[h]=1; }
  }
'@

SubRx @'
    if(at<0&&o.pushed&&o.pushed!==w.id) for(k in A) if(A[k]==='gun_'+o.pushed&&U[k]&&G.bag.indexOf(A[k])>=0){ at=+k; break; }
'@ @'
    // v21.90, from the review of 21.83: the key of the gun pushed out goes only to the gun that just came into his hands
    // (o.arrived), never to a gun already there that lost its own key in the same move.
    if(at<0&&o.pushed&&o.pushed!==w.id&&o.arrived===w.id) for(k in A) if(A[k]==='gun_'+o.pushed&&U[k]&&G.bag.indexOf(A[k])>=0){ at=+k; break; }
'@

SubRx @'
    gunKeysSettle({pushed:_pushId});
'@ @'
    gunKeysSettle({pushed:_pushId,arrived:gk});   // v21.90: the drawn gun is the one that may take the pushed-out key
'@

SubRx @'
        gunKeysSettle({pushed:_gkPush});   // v21.83: the found gun takes a gun key; the gun it pushed out keeps its own
'@ @'
        gunKeysSettle({pushed:_gkPush,arrived:found.id});   // v21.83: the found gun takes a gun key; the gun it pushed out keeps its own (v21.90: named)
'@

SubRx @'
        gunKeysSettle({pushed:_gkPush2});   // v21.83: the found gun takes a gun key; the gun it pushed out keeps its own
'@ @'
        gunKeysSettle({pushed:_gkPush2,arrived:found.id});   // v21.83: the found gun takes a gun key; the gun it pushed out keeps its own (v21.90: named)
'@

SubRx @'
          var _gLost='';
'@ @'
          // v21.90, from the review of 21.83: THE NO KEY LINE IS WORKED OUT AFTER THE DROP, from where the thing the key showed really
          // ended up. It said a loaner had no key when the loaner then took his own gun 2 key, and it named issued kit that was left
          // behind. It names nothing that is gone, nothing a key holds, and no gun a key still shows.
          var _gLost='', _gNoKey=0;
          var _gLostNow=function(){
            if(!_gNoKey||!_gOld) return '';
            var _li=ITEMS[_gOld.a], _lk, _ls;
            if(_li&&_li.use==='gun'){
              if(!((_pp.wep&&_pp.wep.id===_li.gk)||(_pp.sec&&_pp.sec.id===_li.gk))&&G.bag.indexOf(_gOld.a)<0) return '';
              for(_lk in G.hotAssign) if(G.hotAssign[_lk]===_gOld.a) return '';
              _ls=hotbarSlots(); for(_lk=0;_lk<_ls.length;_lk++) if(_ls[_lk]&&_ls[_lk].kind==='gun'&&_ls[_lk].icon===_li.gk) return '';
            }
            return ' '+(String(_si.name||'Gun')+': no key').toUpperCase();
          };
'@

SubRx @'
            else _gLost=' '+(String(_si.name||'Gun')+': no key').toUpperCase();
'@ @'
            else _gNoKey=1;   // v21.90: named once the drop is done (_gLostNow)
'@

SubRx @'
            say(((_gNow&&_gNow.name)||_dit.name)+' to slot '+(HC.i+1)+'.'+_gLost);
'@ @'
            _gLost=_gLostNow();
            say(((_gNow&&_gNow.name)||_dit.name)+' to slot '+(HC.i+1)+'.'+_gLost);
'@

SubRx @'
            var _gSlot=(_gOldHand===1&&!_pp.wepIssued)?1:((_gOldHand===2&&!_pp.secIssued)?2:giveUpSlot());
'@ @'
            // v21.90, from the review of 21.83: THE GUN THE KEY SHOWED IS THE ONE GIVEN UP, issued kit too: a loaner is left behind
            // as v18.88 left it. Issued kit fell to the give-up rule, which put his own other gun, on a key he never touched, into
            // the backpack and kept the loaner.
            var _gSlot=_gOldHand?_gOldHand:giveUpSlot();
'@

SubRx @'
              say(((_gUp&&_gUp.name)||_dit.name)+' to slot '+(HC.i+1)+'.'+_gLost+(_gunKeyHint?' '+_gunKeyHint:''));
'@ @'
              _gLost=_gLostNow();
              say(((_gUp&&_gUp.name)||_dit.name)+' to slot '+(HC.i+1)+'.'+_gLost+(_gunKeyHint?' '+_gunKeyHint:''));
'@

SubRx @'
var VER='21.89';
'@ @'
var VER='21.90';
'@

$pat = "(?m)^  now:'v21\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.90: With an item on key 1 the Undercroft belt shows your guns where it always did, and a gun dropped on a loaner key replaces the loaner. Check 21.90 fails on v21.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
