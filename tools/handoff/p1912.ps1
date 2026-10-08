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

# A REFUSED GUN KEY DROP LEAVES THE BELT AS IT WAS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          if(_r8on){
            var _r8w=(_pp.wep&&_pp.wep.id===_r8gk)?_pp.wep:_pp.sec;
            if(_si.icon!==_r8gk&&_pp.wep&&_pp.sec) _pp.swapped=!_pp.swapped;
            var _r8s=hotbarSlots();
            if(_r8s[HC.i]&&_r8s[HC.i].kind==='gun'&&_r8s[HC.i].icon===_r8gk){
              if(d.fromHot!==undefined&&d.fromHot!==HC.i&&G.hotAssign&&G.hotAssign[d.fromHot]===d.key){
                delete G.hotAssign[d.fromHot]; if(G.hotAuto) delete G.hotAuto[d.fromHot];

'@ @'
          if(_r8on){
            var _r8w=(_pp.wep&&_pp.wep.id===_r8gk)?_pp.wep:_pp.sec;
            // v19.12, from the review (2026-10-07): the key the drag came from is let go FIRST, tentatively, so a gun cell the belt had
            // moved down (v17.17) can show again on the key it was dropped on; before, its own binding hid it and the drop was refused
            // with p.swapped left flipped, key 1 showing the wrong gun, the trigger on the old cell and the words saying his only gun.
            // A refusal now puts the binding and p.swapped back, keeps the trigger on the gun in his hands and says what happened.
            var _r8sw=_pp.swapped, _r8had=(d.fromHot!==undefined&&d.fromHot!==HC.i&&G.hotAssign&&G.hotAssign[d.fromHot]===d.key), _r8au=(_r8had&&G.hotAuto)?G.hotAuto[d.fromHot]:undefined;
            if(_r8had){ delete G.hotAssign[d.fromHot]; if(G.hotAuto) delete G.hotAuto[d.fromHot]; }
            if(_si.icon!==_r8gk&&_pp.wep&&_pp.sec) _pp.swapped=!_pp.swapped;
            var _r8s=hotbarSlots();
            if(!(_r8s[HC.i]&&_r8s[HC.i].kind==='gun'&&_r8s[HC.i].icon===_r8gk)){
              _pp.swapped=_r8sw; if(_r8had){ G.hotAssign[d.fromHot]=d.key; if(G.hotAuto&&_r8au!==undefined) G.hotAuto[d.fromHot]=_r8au; }
              G.hot=gunCell();
              say((_pp.wep&&_pp.sec&&_pp.wep.id!=='fists'&&_pp.sec.id!=='fists')?(_r8w.name+' cannot go on key '+(HC.i+1)+'; it stays where it is.'):(_r8w.name+' stays where it is: it is your only gun, so there is no other gun for it to trade places with.'));
            }
            else if(_r8s[HC.i]&&_r8s[HC.i].kind==='gun'&&_r8s[HC.i].icon===_r8gk){
              if(_r8had){

'@

SubRx @'
var VER='19.11';
'@ @'
var VER='19.12';
'@

$pat = "(?m)^  now:'v19\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.12: Dragging a gun between belt keys never leaves the belt showing the wrong gun. Check 19.12 fails on v19.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
