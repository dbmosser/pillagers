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

# A TRADE THAT FAILS SAYS WHY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    out={t:'gift',op:m.op,id:m.id,k:m.k,ib:m.ib,to:m.to,from:fr,hub:m.hub?1:0};   // v18.05: the hub mark rides along
'@ @'
    out={t:'gift',op:m.op,id:m.id,k:m.k,ib:m.ib,to:m.to,from:fr,hub:m.hub?1:0,why:m.why};   // v18.05: the hub mark rides along; v18.23: and the reason
'@

SubRx @'
  if(typeof G==='undefined'||!G||G.over||!G.player) return 'no raid';
'@ @'
  if(typeof G==='undefined'||!G||G.over||!G.player){ if(m.op==='offer'||m.op==='yes') netGiftSend(fr,{op:'no',id:m.id,why:'gone'}); return 'no raid'; }   // v18.23: a window with no raid answers a no with the reason
'@

SubRx @'
  if(m.op==='offer'){
    if(!it) return 'bad';
    G.giftIn={id:String(m.id).slice(0,40),k:key,from:fr,t:G.t};
'@ @'
  if(m.op==='offer'){
    if(!it) return 'bad';
    // v18.23, FROM THE TRADE AUDIT (2026-10-03): A PLAYER WHO IS DOWN CANNOT TAKE, SO THE GIVER IS TOLD AT ONCE instead of waiting out the offer.
    if(G.player.downed){ netGiftSend(fr,{op:'no',id:m.id,why:'down'}); return 'down'; }
    G.giftIn={id:String(m.id).slice(0,40),k:key,from:fr,t:G.t};
'@

SubRx @'
  if(m.op==='no'){ if(G.giftIn&&G.giftIn.id===m.id) G.giftIn=null; say(nm+' could not hand it over.'); return 'no'; }
'@ @'
  if(m.op==='no'){
    if(G.giftIn&&G.giftIn.id===m.id) G.giftIn=null;
    if(G.giftOut&&G.giftOut.id===m.id) G.giftOut=null;   // v18.23: and the giver's open offer closes with the no
    say(m.why==='down'?(nm+' is down and cannot take it.'):(m.why==='gone'?(nm+' is not up top any more.'):(nm+' could not hand it over.')));   // v18.23: the reason, when there is one
    return 'no';
  }
'@

SubRx @'
  gi=G.giftIn; go=G.giftOut;
  if(gi&&!gi.yes&&(t=GIFT_T-((G.t||0)-gi.t))>0){
'@ @'
  gi=G.giftIn; go=G.giftOut;
  // v18.23, FROM THE TRADE AUDIT (2026-10-03): A TRADE THAT ENDS SAYS SO. An offer that ran out, on either side, simply vanished.
  if(gi&&!gi.yes&&(G.t||0)-gi.t>GIFT_T){ G.giftIn=null; try{ say('The offer from '+(netSeatName(gi.from)||'your teammate')+' ran out.'); }catch(_x1){} gi=null; }
  if(go&&(G.t||0)-go.t>GIFT_T+5){ G.giftOut=null; try{ it=ITEMS[go.k]; say((netSeatName(go.to)||'Your teammate')+' did not take the '+(it?it.name:go.k)+'.'); }catch(_x2){} go=null; }
  if(gi&&!gi.yes&&(t=GIFT_T-((G.t||0)-gi.t))>0){
'@

SubRx @'
var VER='18.22';
'@ @'
var VER='18.23';
'@

$pat = "(?m)^  now:'v18\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.23: When a trade does not go through, both players are told why: down, gone, ran out or not taken. Check 18.23 fails on v18.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
