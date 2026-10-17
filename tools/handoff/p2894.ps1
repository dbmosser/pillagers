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

# PRE-RAID: PICK HOW MUCH CASH TO TAKE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if((P.credits||0)<st.price){ say('NOT ENOUGH BANKED CREDITS'
'@ @'
  if(G.cash!=null&&G.cash<st.price){ say('NOT ENOUGH CASH ON YOU','info',{sub:'Costs '+'$'+st.price.toLocaleString()+'. Carrying '+'$'+G.cash.toLocaleString()+'.'}); return; }   // v28.xx (cw-precash), HIS ORDER (2026-10-15): "quickly pick how much cash ... to take": a raid that took a set amount of cash can spend no more than that at the stall
  if((P.credits||0)<st.price){ say('NOT ENOUGH BANKED CREDITS'
'@

SubRx @'
  P.credits-=st.price; saveProfile();

'@ @'
  P.credits-=st.price; saveProfile();
  if(G.cash!=null) G.cash=Math.max(0,G.cash-st.price);   // v28.xx (cw-precash)

'@

SubRx @'
  G.carriedIn=bagValue();

'@ @'
  G.carriedIn=bagValue();
  // v28.xx (cw-precash), HIS ORDER (2026-10-15): "On the pre-raid screen ... quickly pick how much cash ... to take". The amount set on the PRE-RAID page (P.takeCashRaid, written when he deploys with MY LOADOUT) is the cash on him: the stall sells him no more than that, and banked Credits stay banked (nothing is lost with it). No pick means no cap.
  G.cash=null;
  if(!G.sim&&P.takeCashRaid!=null) G.cash=Math.max(0,Math.min(P.takeCashRaid|0,P.credits|0));
  P.takeCashRaid=null;

'@

SubRx @'
function packCore(){
'@ @'
// v28.xx (cw-precash), HIS ORDER (2026-10-15): "quickly pick how much cash ... to take". P.takeCash is null for ALL (no cap) or a number of credits; the step is a tenth of the bank, in hundreds.
function cashStep(d){
  var c=P.credits|0, st=Math.max(100,Math.round(c/10/100)*100), cur=(P.takeCash==null)?c:Math.min(P.takeCash|0,c);
  if(d==='all'){ P.takeCash=null; return; }
  cur+=(d>0?st:-st);
  P.takeCash=(cur>=c)?null:Math.max(0,cur);
}
function packCore(){
'@

SubRx @'
  nc=heldCount('core');

'@ @'
  nc=heldCount('core');
  tc=(P.takeCash==null)?null:Math.min(P.takeCash|0,P.credits|0);
  h+='<span class="pkc'+(tc!==null?' on':'')+'" data-cashchip="1"><span class="pkn">CASH</span><button data-cash="-1">-</button><b style="min-width:4.2em">'+(tc===null?'ALL':tc.toLocaleString())+'</b><span style="color:var(--ash)">/'+(P.credits|0).toLocaleString()+'</span><button data-cash="1">+</button><button data-cash="all">MAX</button></span>';

'@

SubRx @'
  var host=document.getElementById('sectorpack'), keys, i, k, h, held, got, nc;
'@ @'
  var host=document.getElementById('sectorpack'), keys, i, k, h, held, got, nc, tc;
'@

SubRx @'
    if(b.getAttribute('data-core')){ if(!packCore()) return; }
'@ @'
    if(b.getAttribute('data-cash')){ cashStep(b.getAttribute('data-cash')==='all'?'all':(+b.getAttribute('data-cash'))); }   // v28.xx (cw-precash)
    else if(b.getAttribute('data-core')){ if(!packCore()) return; }
'@

SubRx @'
    else if(pa){ ks=packList();
'@ @'
    else if(pa){ P.takeCash=(pa==='all')?null:0; ks=packList();
'@

SubRx @'
  kitDeploy();   // v26.xx (kit1): the kit was chosen on this page, so it goes straight up
'@ @'
  P.takeCashRaid=(kitPickOf()==='mine')?P.takeCash:null;   // v28.xx (cw-precash): the cash he picked goes up with MY LOADOUT only
  kitDeploy();   // v26.xx (kit1): the kit was chosen on this page, so it goes straight up
'@

SubRx @'
var VER='28.93';
'@ @'
var VER='28.94';
'@

$pat = "(?m)^  now:'v28\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.94: The PRE-RAID page has a CASH chip: pick how much cash goes up with you to spend at the stall. Check 28.94 fails on v28.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
