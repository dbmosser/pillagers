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

# A GUN SWAP NAMES THE KEY IT REALLY LANDS ON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          _gw8p.swapped=!_gw8p.swapped; G.hot=gunCell(); blip('pick');
          say(_gw8n+' to slot '+(_onCell+1)+'.');
'@ @'
          _gw8p.swapped=!_gw8p.swapped; G.hot=gunCell(); blip('pick');
          // v19.18, from the review (2026-10-07): the words said the key he dropped on even when the belt shows that gun on another key
          // (a key he bound it to himself keeps showing it, so the moved-down cell is not drawn twice). They now name where it really is.
          var _gw8id=_gw8g&&_gw8g.icon, _gw8z=hotbarSlots(), _gw8at=-1, _gw8o=(_gw8t&&_gw8t.name)||'the other gun';
          if(_gw8z[_onCell]&&_gw8z[_onCell].kind==='gun'&&_gw8z[_onCell].icon===_gw8id) _gw8at=_onCell;
          else for(_gw8q=0;_gw8q<_gw8z.length;_gw8q++) if(_gw8z[_gw8q]&&_gw8z[_gw8q].kind==='gun'&&_gw8z[_gw8q].icon===_gw8id){ _gw8at=_gw8q; break; }
          say((_gw8at===_onCell)?(_gw8n+' to slot '+(_onCell+1)+'.'):(_gw8n+' traded places with '+_gw8o+(_gw8at>=0?('; '+_gw8n+' is on key '+(_gw8at+1)+'.'):'.')));
'@

SubRx @'
              blip('pick'); hubToast(_hb8n+' to slot '+(_H.i+1)+'.');
'@ @'
              // v19.18, from the review (2026-10-07): name the key the gun really shows on, as in a raid.
              var _hb8z=hotbarSlots(), _hb8at=-1, _hb8id=d.key.slice(4), _hb8o=(_hb8t&&_hb8t.name)||'the other gun', _hb8q;
              if(_hb8z[_H.i]&&_hb8z[_H.i].kind==='gun'&&_hb8z[_H.i].icon===_hb8id) _hb8at=_H.i;
              else for(_hb8q=0;_hb8q<_hb8z.length;_hb8q++) if(_hb8z[_hb8q]&&_hb8z[_hb8q].kind==='gun'&&_hb8z[_hb8q].icon===_hb8id){ _hb8at=_hb8q; break; }
              blip('pick'); hubToast((_hb8at===_H.i)?(_hb8n+' to slot '+(_H.i+1)+'.'):(_hb8n+' traded places with '+_hb8o+(_hb8at>=0?('; '+_hb8n+' is on key '+(_hb8at+1)+'.'):'.')));
'@

SubRx @'
var VER='19.17';
'@ @'
var VER='19.18';
'@

$pat = "(?m)^  now:'v19\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.18: Swapping guns on the belt says where the gun really went. Check 19.18 fails on v19.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
