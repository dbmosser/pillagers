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

# ANY GUN ON ANY KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        else say('GUN KEYS ONLY','info',{sub:'DRAG OFF BELT TO STOW'});   // v22.43: the shooter voice
'@ @'
        else {
          // v22.52, the four-gun belt, build 5 (his order of 2026-10-09: the player can load up the belt with all guns or whatever else
          // they want): ANY GUN ON ANY KEY. A gun in his hands dragged onto a key past the gun keys was refused in words (gun keys
          // only). It is now bound there as his key, flushed to his plan as any drag onto the belt is (minus the automatic pins), and
          // its gun key pin comes off, so the gun key it left shows the fill. What he had on that key goes to the key the gun came
          // from, as the trade above sends it. The guns in his hands do not change.
          var _gaA=(G.hotAssign=G.hotAssign||{}), _gaU=(G.hotAuto=G.hotAuto||{}), _gaP=_gaA[_onCell], _gaPu=_gaU[_onCell]?1:0, _gaK, _gaM=null, _gaI;
          for(_gaK in _gaA) if(_gaA[_gaK]===d.key){ delete _gaA[_gaK]; delete _gaU[_gaK]; }
          delete _gaU[_onCell];
          _gaA[_onCell]=d.key;
          if(_gaP!==undefined&&_gaP!==d.key&&d.fromHot!==undefined&&_gaA[d.fromHot]===undefined){
            _gaA[d.fromHot]=_gaP; if(_gaPu) _gaU[d.fromHot]=1;
            _gaI=ITEMS[_gaP]; if(_gaI) _gaM={sub:(_gaI.name+' on key '+(d.fromHot+1)).toUpperCase()};
          }
          for(_gaK in _gaU) if(_gaA[_gaK]===undefined) delete _gaU[_gaK];
          if(!G.sim){ var _gaF={}; for(_gaK in _gaA) if(!_gaU[_gaK]) _gaF[_gaK]=_gaA[_gaK]; P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_gaF))); try{ saveProfile(); }catch(_gaE){} }
          G.hot=gunCell(); blip('pick');
          say((_gw8n+' on key '+(_onCell+1)).toUpperCase(),'info',_gaM);   // the shooter voice
        }
'@

SubRx @'
        // his on the gun key goes to the key the gun came from, as v18.89 sent it. Onto a key past the gun keys it is refused.
'@ @'
        // his on the gun key goes to the key the gun came from, as v18.89 sent it. Onto a key past the gun keys it is bound there
        // as his key (v22.52, below).
'@

SubRx @'
        var _siDerived=!!(_si&&HC.i<GUNKEYS&&_si.kind==='gun');
'@ @'
        // v22.52, the four-gun belt, build 5, decision D2: AN ITEM MAY GO ON AN EMPTY GUN KEY 3 OR 4. A vacant gun key 3 or 4 refused
        // anything but a gun (guns only); an item dropped there now takes it as his key, like any other key (v6.61), and the fill
        // and the gun pins skip a gun key he covered. A gun dropped there still comes up into his hands as below.
        var _siOpen=!!(_si&&HC.i>=2&&HC.i<GUNKEYS&&_si.vacant&&!(_dit&&_dit.use==='gun'));
        var _siDerived=!!(_si&&HC.i<GUNKEYS&&_si.kind==='gun'&&!_siOpen);
'@

SubRx @'
var VER='22.51';
'@ @'
var VER='22.52';
'@

$pat = "(?m)^  now:'v22\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.52: In a raid a gun goes on any key, and an item can go on an empty gun key 3 or 4. Check 22.52 fails on v22.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
