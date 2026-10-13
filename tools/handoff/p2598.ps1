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

# THE STASH BELT ROW IN THE SAME FOUR GROUPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
'<div style="display:flex;gap:4px;flex-wrap:wrap">';
'@ @'
'<div style="display:flex;gap:12px;flex-wrap:wrap">';   // v25.xx (belt6c): the four groups of the raid belt
'@

SubRx @'
  for(var i=0;i<HOTBAR_N;i++){
    // THE TWO GUN KEYS. Shown so the numbers on this row are the numbers he will
'@ @'
  var _gh=['','','',''];   // v25.xx (belt6c): each group's keys, laid out below
  for(var i=0;i<HOTBAR_N;i++){
    // THE TWO GUN KEYS. Shown so the numbers on this row are the numbers he will
'@

SubRx @'
    var k=(P.hotAssign||{})[i], it=k?ITEMS[k]:null, _fg=null;
'@ @'
    var k=(P.hotAssign||{})[i], it=k?ITEMS[k]:null, _fg=null;
    if(!it&&i>=GUNKEYS&&_fl[i]&&_fl[i].kind!=='empty'&&!_fl[i].assigned&&_fl[i].icon&&ITEMS[_fl[i].icon]&&ITEMS[_fl[i].icon].use!=='gun') _fg={k:_fl[i].icon,name:escHtml(String(ITEMS[_fl[i].icon].name))};   // v25.xx (belt6c): an unbound throwable, medical or armour key shows what the floor belt shows on it
'@

SubRx @'
h+='<div data-plan="'+i+'" title="'+(it?
'@ @'
_gh[beltGroupOf(i)]+='<div data-plan="'+i+'" title="'+(it?
'@

SubRx @'
      '</div>';
  }
  h+='</div>';
  return h+'</div>';
'@ @'
      '</div>';
  }
  var _gn=['GUNS','THROW','MEDICAL','ARMOUR'], _gi;   // v25.xx (belt6c): the same four groups and labels as the raid belt
  for(_gi=0;_gi<4;_gi++) h+='<div style="background:rgba(20,23,26,.55);border-radius:4px;padding:4px 5px 3px"><div style="display:flex;gap:4px">'+_gh[_gi]+'</div><div style="text-align:center;font-size:11px;letter-spacing:.1em;color:var(--ash);margin-top:2px">'+_gn[_gi]+'</div></div>';
  h+='</div>';
  return h+'</div>';
'@

SubRx @'
      else if(S.count!==null&&S.count!==undefined&&S.kind!=='empty'){   // v19.01: no count on an empty key
'@ @'
      else if(S.count!==null&&S.count!==undefined&&S.kind!=='empty'&&!S.vacant){   // v19.01: no count on an empty key   // v25.xx (belt6c): nor on a vacant gun key
'@

SubRx @'
var VER='25.97';
'@ @'
var VER='25.98';
'@

$pat = "(?m)^  now:'v25\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.98: The Stash belt row now shows the same four labelled groups as the raid bar, with the keys the floor belt would fill. Check 25.98 fails on v25.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
