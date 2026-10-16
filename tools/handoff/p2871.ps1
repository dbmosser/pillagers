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

# SCORE READS IN SP, NOT DOLLARS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeCr(n){ return '$'+arcadeN(n); }
'@ @'
// lean2, HIS ORDER (2026-10-15): "its still really confusing how score is in dollars but it doesn't match loot value etc -- maybe score just needs to be like sp (score
// points)". arcadeCr is the one helper every SCORE figure goes through (the HUD score tile, the ledger score rows, medals, popups, the boards), so it reads N SP now,
// never $N. arcadeMoney is the dollar form for what is still money: the credits, the haul and the raid total. A score point banks as one credit.
function arcadeCr(n){ return arcadeN(n)+' SP'; }
function arcadeMoney(n){ return '$'+arcadeN(n); }
'@

SubRx @'
  function cnt(v,pre){ return '<b data-to="'+(v|0)+'" data-pre="'+(pre||'')+'" data-dl="'+(idx*90)+'">'+(pre||'')+arcadeCr(v)+'</b>'; }
'@ @'
  function cnt(v,pre,m){ return '<b data-to="'+(v|0)+'" data-pre="'+(pre||'')+'" data-dl="'+(idx*90)+'"'+(m?' data-m="1"':'')+'>'+(pre||'')+(m?arcadeMoney(v):arcadeCr(v))+'</b>'; }
'@

SubRx @'
  if(ex) h+=row('cr','<span class="lgt">CREDITS</span><span class="lgl">BANKED</span>'+((fin>0)?cnt(fin,'+'):'<b>+'+arcadeCr(0)+'</b>'));
'@ @'
  if(ex) h+=row('cr','<span class="lgt">CREDITS</span><span class="lgl">BANKED</span>'+((fin>0)?cnt(fin,'+',1):'<b>+'+arcadeMoney(0)+'</b>'));
'@

SubRx @'
<span class="lgl">NOT BANKED</span><b><s>+'+arcadeCr(fin)+'</s> LOST</b>');
'@ @'
<span class="lgl">NOT BANKED</span><b><s>+'+arcadeMoney(fin)+'</s> LOST</b>');
'@

SubRx @'
<b id="haultot" data-pre="">'+arcadeCr(hv)+'</b>');
'@ @'
<b id="haultot" data-pre="">'+arcadeMoney(hv)+'</b>');
'@

SubRx @'
<span class="lgl">VALUE</span><b><s>'+arcadeCr(lostV||x.haul||0)+'</s> LOST</b>');
'@ @'
<span class="lgl">VALUE</span><b><s>'+arcadeMoney(lostV||x.haul||0)+'</s> LOST</b>');
'@

SubRx @'
<span class="lgl">RAID TOTAL</span>'+((tot>0)?cnt(tot,''):('<b>'+arcadeCr(0)+'</b>')));
'@ @'
<span class="lgl">RAID TOTAL</span>'+((tot>0)?cnt(tot,'',1):('<b>'+arcadeMoney(0)+'</b>')));
'@

SubRx @'
function lbCountStart(el,to,delayMs,durMs){
'@ @'
function lbFmt(el,n){ return el.getAttribute('data-m')?arcadeMoney(n):arcadeCr(n); }   // lean2: a figure flagged data-m is money, any other is score
function lbCountStart(el,to,delayMs,durMs){
'@

SubRx @'
  el.textContent=pre+arcadeCr(0);
'@ @'
  el.textContent=pre+lbFmt(el,0);
'@

SubRx @'
    el.textContent=pre+arcadeCr(Math.round((to|0)*(1-Math.pow(1-k,3))));
'@ @'
    el.textContent=pre+lbFmt(el,Math.round((to|0)*(1-Math.pow(1-k,3))));
'@

SubRx @'
el.textContent=(el.getAttribute('data-pre')||'')+arcadeCr(+el.getAttribute('data-to')||0); }
'@ @'
el.textContent=(el.getAttribute('data-pre')||'')+lbFmt(el,+el.getAttribute('data-to')||0); }
'@

SubRx @'
T.push({l:'RAID SCORE',v:arcadeCr((G.cs&&G.cs.s)|0),c:'#e8eef2',s:'CREDITS '+arcadeCr(P.credits|0)
'@ @'
T.push({l:'RAID SCORE',v:arcadeCr((G.cs&&G.cs.s)|0),c:'#e8eef2',s:'CREDITS '+arcadeMoney(P.credits|0)
'@

SubRx @'
T.push({l:'CARRIED',v:'$'+hv.toLocaleString(),c:'#e8eef2',s:'CREDITS '+arcadeCr(P.credits|0)
'@ @'
T.push({l:'CARRIED',v:'$'+hv.toLocaleString(),c:'#e8eef2',s:'CREDITS '+arcadeMoney(P.credits|0)
'@

SubRx @'
var VER='28.70';
'@ @'
var VER='28.71';
'@

$pat = "(?m)^  now:'v28\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.71: Score now reads in SP (score points) everywhere; credits and loot value stay in dollars. Check 28.71 fails on v28.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
