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

# THE GLOW SAYS WHY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  needRefresh();
'@ @'
  needRefresh();
  needHint();
'@

SubRx @'
function careerTick(dt){
'@ @'
// v26.xx (career9), HIS ANSWER (2026-10-14) to the needed-item glow, "not sure how this works": IT SAYS WHY. The first time a shut box that holds a contract item is within 65 metres of you
// (once for the save, P.needTold), one caps callout says CONTRACT ITEM NEARBY over GOLD GLOW MARKS THE BOX. And the item itself says why wherever it shows: its row in the pickup stack
// carries the tag NEEDED . CONTRACT (set when the row is made, so a second one picked up still counts into the same row), and its name line in the backpack carries it in gold.
function needHint(){
  var p=G&&G.player, i, c;
  if(!p||!G.needN||!P||P.needTold||G.sim) return 0;
  for(i=0;i<(G.containers||[]).length;i++){
    c=G.containers[i]; if(!needHolds(c)) continue;
    if(Math.hypot(c.x-p.x,c.y-p.y)<650){
      P.needTold=1; try{ saveProfile(); }catch(_s){}
      try{ say('CONTRACT ITEM NEARBY','obj',{sub:'GOLD GLOW MARKS THE BOX'}); }catch(_sy){}
      return 1;
    }
  }
  return 0;
}
function careerTick(dt){
'@

SubRx @'
var q=(G.pick=G.pick||[]), now=G.t||0, it=(o&&o.item)||'', n=(o&&o.n>0)?Math.round(o.n):1, i, r;
'@ @'
var q=(G.pick=G.pick||[]), now=G.t||0, it=(o&&o.item)||'', n=(o&&o.n>0)?Math.round(o.n):1, i, r;
  if(it&&G.need&&G.need[it]>0&&!G.sim&&!(o&&o.tag)){ var _no={}, _nk; if(o) for(_nk in o) _no[_nk]=o[_nk]; _no.tag='NEEDED \u00b7 CONTRACT'; o=_no; }   // v26.xx (career9): a contract item says why it is gold
'@

SubRx @'
ctx.fillText((sit?sit.name:sst.key)+(sst.idxs.length>1?('  x'+sst.idxs.length):''),x+11,hintY);
'@ @'
ctx.fillText((sit?sit.name:sst.key)+(sst.idxs.length>1?('  x'+sst.idxs.length):''),x+11,hintY);
    if(G.need&&G.need[sst.key]>0){ var _nt=(sit?sit.name:sst.key)+(sst.idxs.length>1?('  x'+sst.idxs.length):''); ctx.fillStyle='#ffd452'; ctx.fillText('NEEDED \u00b7 CONTRACT',x+11+ctx.measureText(_nt).width+LH(12)*BZ,hintY); }   // v26.xx (career9)
'@

SubRx @'
var VER='28.10';
'@ @'
var VER='28.11';
'@

$pat = "(?m)^  now:'v28\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.11: The gold glow says why: a one-time callout and a NEEDED, CONTRACT tag on the item. Check 28.11 fails on v28.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
