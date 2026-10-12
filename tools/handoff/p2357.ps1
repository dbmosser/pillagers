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

# THE BOARD STARTS FRESH IN CREDITS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeBoardLoad(){
  var o=null, r, out=[], i, x;
  try{ o=JSON.parse(localStorage.getItem(ARCADE_BOARD_KEY)||'null'); }catch(_bl){ o=null; }
  r=(o&&Array.isArray(o.rows))?o.rows:[];
  for(i=0;i<r.length;i++){
    x=r[i]; if(!x||typeof x.run!=='string'||!x.run) continue;
    out.push({run:x.run.slice(0,40),i:(typeof x.i==='string')?x.i.slice(0,3).toUpperCase():'',s:Math.max(0,Math.round(+x.s||0)),x:Math.max(0,x.x|0),k:Math.max(0,x.k|0),t:+x.t||0,m:(x.m===1)?1:2});   // v23.54 (arcade30): the mode, an old row is 2 player
  }
  return out;
}
'@ @'
// v23.57, arcade32 (a low finding of the arcade31 review): THE BOARD STARTS FRESH IN CREDITS. Rows saved before the arcade score became
// credits (v23.56) hold scores with loot at one tenth, but read as $ next to full value rows, so BEST EVER and NEW HIGH SCORE compared
// two scales. Every row written from v23.57 on carries the scale tag u:'cr'. On load a row without it is dropped, and the board is saved
// back clean, so the drop happens once. Only the arcade board key changes; his save and normal raids are untouched.
function arcadeBoardLoad(){
  var o=null, r, out=[], i, x, dr=0;
  try{ o=JSON.parse(localStorage.getItem(ARCADE_BOARD_KEY)||'null'); }catch(_bl){ o=null; }
  r=(o&&Array.isArray(o.rows))?o.rows:[];
  for(i=0;i<r.length;i++){
    x=r[i]; if(!x||typeof x.run!=='string'||!x.run) continue;
    if(x.u!=='cr'){ dr++; continue; }   // v23.57 (arcade32): a row from the old scale
    out.push({run:x.run.slice(0,40),i:(typeof x.i==='string')?x.i.slice(0,3).toUpperCase():'',s:Math.max(0,Math.round(+x.s||0)),x:Math.max(0,x.x|0),k:Math.max(0,x.k|0),t:+x.t||0,m:(x.m===1)?1:2,u:'cr'});   // v23.54 (arcade30): the mode, an old row is 2 player; v23.57 (arcade32): the scale tag
  }
  if(dr){ try{ arcadeBoardSave(out); }catch(_bc){} }   // v23.57 (arcade32): saved back clean once
  return out;
}
'@

SubRx @'
    if(!o){ o=m[x.run]={run:x.run,i:x.i||'',s:x.s,x:x.x,k:x.k,t:x.t,m:(x.m===1)?1:2}; out.push(o); continue; }
'@ @'
    if(!o){ o=m[x.run]={run:x.run,i:x.i||'',s:x.s,x:x.x,k:x.k,t:x.t,m:(x.m===1)?1:2,u:'cr'}; out.push(o); continue; }   // v23.57 (arcade32): every saved row carries the credits tag
'@

SubRx @'
  r.push({run:id,i:ini,s:s,x:Math.max(0,(ARCADE.ext|0)+(ARCADE.mateX|0)),k:Math.max(0,(ARCADE.kills|0)+(ARCADE.mateK|0)),t:Date.now(),m:arcadeBoardMode()});   // v23.54 (arcade30): tagged with its mode
'@ @'
  r.push({run:id,i:ini,s:s,x:Math.max(0,(ARCADE.ext|0)+(ARCADE.mateX|0)),k:Math.max(0,(ARCADE.kills|0)+(ARCADE.mateK|0)),t:Date.now(),m:arcadeBoardMode(),u:'cr'});   // v23.54 (arcade30): tagged with its mode; v23.57 (arcade32): and the credits scale
'@

SubRx @'
var VER='23.56';
'@ @'
var VER='23.57';
'@

$pat = "(?m)^  now:'v23\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.57: The arcade party board starts fresh in credits: old scale rows are dropped once, so every score on it is on one scale. Check 23.57 fails on v23.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
