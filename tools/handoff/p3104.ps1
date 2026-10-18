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

# superhot toggle key: named on the F1 list and beside the Settings row, one honest line, and the second window says when the host flips it (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var _shMsg='SUPERHOT '+(CFG.superhot?'ON':'OFF');
      if(G&&!G.over&&!G.sim) say(_shMsg); else if(typeof say2==='function') say2(_shMsg);
'@ @'
      // v30.xx (cw-shkey), HIS NOTE (2026-10-18): "superhot mode needs a toggle key." The key left of 1 has toggled Superhot since v7.23, but nothing on screen named it
      // (only CHANGE KEYS did), and its line could read the wrong state: the lines it said were not replaced, so on, off, on within a second left OFF on top and OFF
      // last in the feed with Superhot on. shSay keeps one line, the state just set; the key is named on the F1 list and beside the Settings row.
      shSay(CFG.superhot);
'@

SubRx @'
['F9','record your play for the title']]]
'@ @'
['F9','record your play for the title'],['`','superhot on/off']]]   // v30.xx (cw-shkey), HIS NOTE (2026-10-18): "superhot mode needs a toggle key." The key left of 1 is named here
'@

SubRx @'
    if(dt.innerHTML!==html) dt.innerHTML=html;
'@ @'
    // v30.xx (cw-shkey), HIS NOTE (2026-10-18): "superhot mode needs a toggle key." The pane that explains a row also names the key that does what the row does.
    if(v&&v.id==='go_superhot') html+='<div class="sdh">key: '+escHtml(keyName('Backquote'))+' (left of 1)</div>';
    if(dt.innerHTML!==html) dt.innerHTML=html;
'@

SubRx @'
function netShTake(v){
  v=v?1:0;
  if(NET.shHost!==0&&NET.shHost!==1) NET.shOwn=CFG.superhot?1:0;
  NET.shHost=v;
'@ @'
// v30.xx (cw-shkey), HIS NOTE (2026-10-18): "superhot mode needs a toggle key." THE ONE SUPERHOT LINE. The key (and the host word on a linked window) says the state it
// set. An older Superhot line is taken out of the left feed first, so the line on screen is always the state now, never "SUPERHOT OFF" last with Superhot on (a repeat
// within a second only refreshed the older line where it stood), and never a count. The message row is keyed, so it is replaced where it stands.
function shSay(on){
  var m='SUPERHOT '+(on?'ON':'OFF'), F, i;
  try{ F=(G&&G.fd&&G.fd.lines)?G.fd.lines:null; if(F) for(i=F.length-1;i>=0;i--) if((/^SUPERHOT (ON|OFF)$/).test(F[i].txt||'')) F.splice(i,1); }catch(_sf){}
  if(G&&!G.over&&!G.sim) say(m,'info',{key:'shtoggle'}); else if(typeof say2==='function') say2(m);
}
function netShTake(v){
  v=v?1:0;
  var _shNew=(NET.shHost===0||NET.shHost===1)&&NET.shHost!==v;   // cw-shkey: the host changed it in the raid, the first word of a party is not news
  if(NET.shHost!==0&&NET.shHost!==1) NET.shOwn=CFG.superhot?1:0;
  NET.shHost=v;
'@

SubRx @'
  return v;
}
function netShDrop()
'@ @'
  if(_shNew&&G&&!G.over&&!G.sim){ try{ shSay(v); }catch(_shs){} }   // cw-shkey: the linked window says it too
  return v;
}
function netShDrop()
'@

SubRx @'
var VER='31.03';
'@ @'
var VER='31.04';
'@

$pat = "(?m)^  now:'v31\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.04: The key left of 1 turns Superhot on and off. It is on the F1 list and beside the Settings row, and the line always shows the state just set. Check 31.04 fails on v31.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
