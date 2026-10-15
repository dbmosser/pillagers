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

# PLAYER 2 HEARS HOW THE CONVOY AND THE RAMPAGE END (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    a.push([EV_IDS.indexOf(ev.id),ev.n|0,(ev.ph==='warn')?0:((ev.ph==='live')?1:2),Math.round(x),Math.round(y),Math.round(ev.r),+(+ev.t).toFixed(1),+(+ev.lt).toFixed(1),+(+ev.et).toFixed(1),+(+ev.warn).toFixed(1),+(+ev.dur).toFixed(1),+(+ev.fade).toFixed(1),evNetX(ev)]);
'@ @'
    a.push([EV_IDS.indexOf(ev.id),ev.n|0,(ev.ph==='warn')?0:((ev.ph==='live')?1:2),Math.round(x),Math.round(y),Math.round(ev.r),+(+ev.t).toFixed(1),+(+ev.lt).toFixed(1),+(+ev.et).toFixed(1),+(+ev.warn).toFixed(1),+(+ev.dur).toFixed(1),+(+ev.fade).toFixed(1),evNetX(ev)]);
    if((ev.id==='convoy'||ev.id==='rampage')&&ev.d.said){ x=a[a.length-1][12]; if(x) x[(ev.id==='convoy')?5:4]=ev.d.said|0; }   // v28.25 (cloud-coop-event-ends-said), CLOUD HUNT 2026-10-15: the end line the host said goes in the word, so player 2 window says the same one
'@

SubRx @'
    seen[ev.n+id]=1; E.n=Math.max(E.n|0,ev.n+1);
'@ @'
    if(was==='live'&&ph==='end') evPeerEnd(ev,r[12]);   // v28.25 (cloud-coop-event-ends-said), CLOUD HUNT 2026-10-15: player 2 window says the end of an event the way the host does
    seen[ev.n+id]=1; E.n=Math.max(E.n|0,ev.n+1);
'@

SubRx @'
// what a linked window says when a live event starts: the host said it in its own start code
'@ @'
// what a linked window says when a live event ends: the host said it in its own tick or end code   // v28.25 (cloud-coop-event-ends-said), CLOUD HUNT 2026-10-15: CONVOY DOWN, CONVOY AWAY, CONVOY ARRIVED and OVERSEER RETURNS were said in the host window only
function evPeerEnd(ev,X){
  try{
    if(ev.id==='convoy'&&X){ if(X[5]===1) say('CONVOY DOWN','ext',{sub:'SEARCH THE CRATE'}); else if(X[5]===2) say('CONVOY AWAY','info'); else if(X[5]===3) say('CONVOY ARRIVED','info',{sub:'THEY STAY'}); }
    else if(ev.id==='rampage'&&X&&X[4]===1) say('OVERSEER RETURNS','info');
  }catch(_epe){}
}
// what a linked window says when a live event starts: the host said it in its own start code
'@

SubRx @'
      ev.d.over=1; ev.d.won=1;
'@ @'
      ev.d.over=1; ev.d.won=1; ev.d.said=1;   // v28.25 (cloud-coop-event-ends-said), CLOUD HUNT 2026-10-15: remember the end line said (1 CONVOY DOWN) for the word
'@

SubRx @'
      ev.d.over=1; convoyLeave(ev);
'@ @'
      ev.d.over=1; convoyLeave(ev); ev.d.said=(G.ents.indexOf(car)<0)?2:3;   // v28.25 (cloud-coop-event-ends-said), CLOUD HUNT 2026-10-15: remember the end line said (2 CONVOY AWAY, 3 CONVOY ARRIVED) for the word
'@

SubRx @'
      if(b.hp>0){ try{ say('OVERSEER RETURNS','info'); }catch(_re){} }
'@ @'
      if(b.hp>0){ ev.d.said=1; try{ say('OVERSEER RETURNS','info'); }catch(_re){} }   // v28.25 (cloud-coop-event-ends-said), CLOUD HUNT 2026-10-15: remember the end line said for the word
'@

SubRx @'
var VER='28.24';
'@ @'
var VER='28.25';
'@

$pat = "(?m)^  now:'v28\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.25: In co-op, both players now hear when the convoy is down, gets away or arrives and stays, and when the Overseer returns to his lair. Check 28.25 fails on v28.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
