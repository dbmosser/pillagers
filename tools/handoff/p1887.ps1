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

# A GUN ALREADY IN HIS HANDS, DRAGGED FROM KEY 8 ONTO KEY 1, GOES THERE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(_bx>=0){
'@ @'
// v18.87, his report (2026-10-07): "can't move a gun from slot 8 to slot 1". A gun on key 8 that is already in his hands is not in the backpack (equipFromBag took it out the first time key 8 brought it up), so this drop looked for it there, found nothing, did nothing and said nothing. Keys 1 and 2 show his two guns by p.swapped alone, so turning it over puts the gun on the key he let go on without changing what is in his hands, and the key it came from lets it go, as any item moved between keys does.
          var _r8gk=_dit.gk, _r8on=(_bx<0&&!!_r8gk&&((_pp.wep&&_pp.wep.id===_r8gk)||(_pp.sec&&_pp.sec.id===_r8gk)));
          if(_r8on){
            var _r8w=(_pp.wep&&_pp.wep.id===_r8gk)?_pp.wep:_pp.sec;
            if(_si.icon!==_r8gk&&_pp.wep&&_pp.sec) _pp.swapped=!_pp.swapped;
            var _r8s=hotbarSlots();
            if(_r8s[HC.i]&&_r8s[HC.i].kind==='gun'&&_r8s[HC.i].icon===_r8gk){
              if(d.fromHot!==undefined&&d.fromHot!==HC.i&&G.hotAssign&&G.hotAssign[d.fromHot]===d.key){
                delete G.hotAssign[d.fromHot]; if(G.hotAuto) delete G.hotAuto[d.fromHot];
                if(!G.sim){ var _r8f={}; for(var _r8k in G.hotAssign) if(!G.hotAuto||!G.hotAuto[_r8k]) _r8f[_r8k]=G.hotAssign[_r8k]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_r8f))); try{ saveProfile(); }catch(_r8e){} }
              }
              G.hot=gunCell(); blip('pick');
              say(_r8w.name+' to slot '+(HC.i+1)+'.');
            }
            else say(_r8w.name+' stays where it is: it is your only gun, so there is no other gun for it to trade places with.');
          }
          else if(_bx<0) say(_dit.name+' is no longer in your backpack.');
          if(_bx>=0){
'@

SubRx @'
var VER='18.86';
'@ @'
var VER='18.87';
'@

$pat = "(?m)^  now:'v18\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.87: In a raid, with the mouse or the controller (pad A sends the same mouse release): pick up key 8 holding a gun he has already brought up once, then drop it on key 1. Nothing changes and nothing is said. Key 1 still shows the other gun and key 8 still shows the dragged one. The code is `if(_bx>=0){` with no else, followed by `dropped=true; break;`. Check 18.87 fails on v18.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
