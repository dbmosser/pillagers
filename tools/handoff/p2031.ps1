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

# A GUEST IS PAID FOR THE RAID IT IS IN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function termsOn(){ if(!Array.isArray(P.terms)) P.terms=[]; return P.terms; }
function hasTerm(id){ return termsOn().indexOf(id)>=0; }
function termsPay(){
  var m=0,t=termsOn();
'@ @'
// v20.31, from the whole-game bug hunt of 2026-10-08 (H27): THE TERMS OF THE RAID YOU ARE IN. A co-op guest's raid is built with
// the host's Terms (netUpStart), but everything after the build read the guest's own signed list: its hazard pay, its XP, its
// conditions panel, its run record, and the hostile pillagers and listener reach decided mid raid. A guest who signed all five
// was paid 140% for a standard raid; a guest who signed none fought heavy patrols for nothing. A raid built with someone else's
// Terms now keeps them (G.terms), and those are read while it runs and as it ends (termsPay(1), termsOf). Solo and the host
// never set G.terms, so they read their own list as before; the Undercroft always reads the player's own.
function termsRaid(){ return (typeof G!=='undefined'&&G&&!G.sim&&Array.isArray(G.terms))?G.terms:null; }
function termsOn(){ var R=termsRaid(); if(R&&!G.over) return R; if(!Array.isArray(P.terms)) P.terms=[]; return P.terms; }
function termsOf(){ return termsRaid()||termsOn(); }   // the raid's own, even as it ends
function hasTerm(id){ return termsOn().indexOf(id)>=0; }
function termsPay(raid){
  var m=0,t=raid?termsOf():termsOn();
'@

SubRx @'
    pendSeed=seed;
    startRaid();
'@ @'
    pendSeed=seed;
    startRaid();
    if(G&&!G.sim) G.terms=P.terms.slice();   // v20.31 (H27): the raid keeps the Terms it was built with, for the pay, the XP and the panel
'@

SubRx @'
return termsOn().join('+')||'none';
'@ @'
return termsOf().join('+')||'none';
'@

SubRx @'
*termsPay())):0);
'@ @'
*termsPay(1))):0);
'@

SubRx @'
  var tPay=termsPay();
'@ @'
  var tPay=termsPay(1);   // v20.31 (H27): the Terms this raid was built with
'@

SubRx @'
for(var tq=0;tq<TERMS.length;tq++) if(hasTerm(TERMS[tq].id)) tn.push(TERMS[tq].name);
'@ @'
for(var tq=0;tq<TERMS.length;tq++) if(termsOf().indexOf(TERMS[tq].id)>=0) tn.push(TERMS[tq].name);
'@

SubRx @'
termPay:tPay,terms:termsOn().slice(),
'@ @'
termPay:tPay,terms:termsOf().slice(),
'@

SubRx @'
var VER='20.30';
'@ @'
var VER='20.31';
'@

$pat = "(?m)^  now:'v20\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.31: In co-op, both players are paid hazard pay for the Terms the raid was actually built with. Check 20.31 fails on v20.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
