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

# A BACKPACK GUN DROPPED ON KEY 1 LANDS ON KEY 1, NOT KEY 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(!equipFromBag(_bx,_tgt)) say('Cannot equip that right now.');
'@ @'
// v18.88, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". A backpack gun dropped on key 1 while key 2 held Bare Hands went to key 2 instead (the v10.62 free-slot rule, which is for a key press and a pickup), and key 8 kept showing it, so the next try found it out of the backpack and did nothing. A drop goes on the key he let go on: the gun fills the free hand slot, keys 1 and 2 trade places (p.swapped) so it shows where he dropped it and the gun he had stays in his hands, and the key it came from lets it go. A refusal says why.
            var _r9t=(_tgt===2)?_pp.sec:_pp.wep, _r9o=(_tgt===2)?_pp.wep:_pp.sec;
            var _r9f=!!(_r9t&&_r9t.id!=='fists'&&_r9t.mag!==0&&(!_r9o||_r9o.id==='fists'||_r9o.mag===0));
            if(!equipFromBag(_bx,_r9f?(_tgt===2?1:2):_tgt)){
              say(_pp.roll>0?'Cannot equip a gun while rolling.':(G.paused?'Cannot equip a gun while paused.':((_pp.downed||_pp.dying)?'Cannot equip a gun while down.':'Cannot equip that right now.')));
            } else {
              if(_r9f) _pp.swapped=!_pp.swapped;
              if(d.fromHot!==undefined&&G.hotAssign&&G.hotAssign[d.fromHot]===d.key){
                delete G.hotAssign[d.fromHot]; if(G.hotAuto) delete G.hotAuto[d.fromHot];
                if(!G.sim){ var _r9p={}; for(var _r9k in G.hotAssign) if(!G.hotAuto||!G.hotAuto[_r9k]) _r9p[_r9k]=G.hotAssign[_r9k]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_r9p))); try{ saveProfile(); }catch(_r9e){} }
              }
              if(_r9f||G.hot===d.fromHot) G.hot=gunCell();
              if(_r9f){
                var _r9n=(_tgt===2)?_pp.wep:_pp.sec, _r9s=hotbarSlots(), _r9i=-1, _r9q;
                for(_r9q=0;_r9q<_r9s.length;_r9q++) if(_r9s[_r9q]&&(_r9s[_r9q].k==='gunA'||_r9s[_r9q].k==='gunB')&&_r9s[_r9q].icon===_r9t.id){ _r9i=_r9q; break; }
                say(_r9n.name+' to slot '+(HC.i+1)+'.'+(_r9i>=0?(' '+_r9t.name+' to slot '+(_r9i+1)+'.'):''));
              }
            }
'@

SubRx @'
var VER='18.87';
'@ @'
var VER='18.88';
'@

$pat = "(?m)^  now:'v18\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.88: A backpack gun dragged onto key 1 lands on key 1. Check 18.88 fails on v18.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
