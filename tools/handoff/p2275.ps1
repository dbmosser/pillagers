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

# AN OFFER IS SHOWN ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // v18.23, FROM THE TRADE AUDIT (2026-10-03): A TRADE THAT ENDS SAYS SO. An offer that ran out, on either side, simply vanished.
  if(gi&&!gi.yes&&(G.t||0)-gi.t>GIFT_T){ G.giftIn=null; try{ say('The offer from '+(netSeatName(gi.from)||'your teammate')+' ran out.'); }catch(_x1){} gi=null; }
  if(go&&(G.t||0)-go.t>GIFT_T+5){ G.giftOut=null; try{ it=ITEMS[go.k]; say((netSeatName(go.to)||'Your teammate')+' did not take the '+(it?it.name:go.k)+'.'); }catch(_x2){} go=null; }
'@ @'
  // v22.75, the raid text rewrite (R30): drawGiftLine only draws. The v18.23 expiry lines (A TRADE THAT ENDS SAYS SO) were said
  // from here, so a frame that did not draw the HUD never ended the offer; they are said from giftTick in the lane tick now.
'@

SubRx @'
  HUDGIFTB=y+LH(7);   // v20.55 (H38): the bottom of this plate, for the controller word
  return s;
}
'@ @'
  HUDGIFTB=y+LH(7);   // v20.55 (H38): the bottom of this plate, for the controller word
  return s;
}
// v22.75, the raid text rewrite (R30): AN OFFER ENDS FROM THE UPDATE. The v18.23 rule stands (a trade that ends says so), from
// msgTick instead of the draw: an offer to this player that ran out is OFFER FROM NAME EXPIRED, and an offer of his that nobody
// took is NAME DID NOT TAKE THE ITEM, each one ally feed row.
function giftTick(){
  var gi, go, it;
  if(typeof G==='undefined'||!G||G.over||!G.player||G.sim) return;
  gi=G.giftIn; go=G.giftOut;
  if(gi&&!gi.yes&&(G.t||0)-gi.t>GIFT_T){ G.giftIn=null; try{ say(('Offer from '+(netSeatName(gi.from)||'your teammate')+' expired').toUpperCase(),'ally'); }catch(_x1){} }
  if(go&&(G.t||0)-go.t>GIFT_T+5){ G.giftOut=null; try{ it=ITEMS[go.k]; say(((netSeatName(go.to)||'Your teammate')+' did not take the '+(it?it.name:go.k)).toUpperCase(),'ally'); }catch(_x2){} }
}
'@

SubRx @'
  pickTick(dt);   // v22.50 (R16): the pickup stack
'@ @'
  pickTick(dt);   // v22.50 (R16): the pickup stack
  giftTick();   // v22.75 (R30): an offer that ran out ends here, not in drawGiftLine
'@

SubRx @'
    netGiftSend(s,{op:'offer',id:G.giftOut.id,k:k});
    say('Offered '+it.name+' to '+nm+'.'); return true;
'@ @'
    netGiftSend(s,{op:'offer',id:G.giftOut.id,k:k});
    return true;   // v22.75 (R30): no Offered line; the offer line under the boss bar says it while it waits
'@

SubRx @'
    G.giftIn={id:String(m.id).slice(0,40),k:key,from:fr,t:G.t};
    say(nm+' offers you '+it.name+'. Press T or '+padB('Y')+' to take it.'); return 'offer';
'@ @'
    G.giftIn={id:String(m.id).slice(0,40),k:key,from:fr,t:G.t};
    return 'offer';   // v22.75 (R30): no offers you line; the offer line names who, what, the one key and the seconds
'@

SubRx @'
var VER='22.74';
'@ @'
var VER='22.75';
'@

$pat = "(?m)^  now:'v22\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.75: A trade offer is shown once, on the offer line, and its end is one short feed row. Check 22.75 fails on v22.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
