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

# TRADE IN THE PICKUP STACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(r.T>0&&(it?r.item===it:(!r.item&&r.m===String(m)))){   // the same item while its row is up: one row, counted
'@ @'
    if(r.T>0&&(it?r.item===it:(!r.item&&r.m===String(m)))&&(r.tag||'')===((o&&o.tag)?String(o.tag):'')){   // the same item, going the same way, while its row is up: one row, counted (v22.56, R18: and the same tag, so a sale never adds to a purchase)
'@

SubRx @'
function pickTick(dt){
'@ @'
// v22.56 (R18): the tag on the newest row of an item, set after the grant that pushed it (a gift FROM a teammate, the Survivor).
function pickTag(item,tag){
  var q=G&&G.pick, i;
  if(!q) return;
  for(i=q.length-1;i>=0;i--) if(q[i].item===item&&q[i].T>0){ q[i].tag=String(tag||''); return; }
}
function pickTick(dt){
'@

SubRx @'
    var _full=full;
    say('Sold '+n+' for '+'$'+tot.toLocaleString()+', his '+Math.round(pedBuyRate()*100)+
      ' percent. The Credits ride with you now - walk them out or lose them. Carried '+
      'home whole it was worth '+'$'+_full.toLocaleString()+'.');
'@ @'
    var _full=full;
    // v22.56, the raid text rewrite (R18): TRADE IN THE PICKUP STACK. HIS ORDER (2026-10-09): the raid text reads like a shooter
    // HUD, short callouts and never an explaining sentence. The sale said one sentence of 120 to 135 characters, wrapped over two
    // rows in the middle of the screen. The money is now a +$ row in the pickup stack in the gain colour, tagged CARRIED (it rides
    // with him and pays out only if he walks out, v7.62), and one short line keeps the other half of the trade (v3.27): what the
    // same backpack is worth carried home. The stall panel still shows the carried total (v12.74).
    say('+'+'$'+tot.toLocaleString(),'pick',{tag:'CARRIED',c:'gain'});
    say('SOLD '+n+(n===1?' ITEM':' ITEMS'),'info',{sub:'Worth '+'$'+_full.toLocaleString()+' carried home.'});
'@

SubRx @'
  if((P.credits||0)<st.price){ say('You cannot cover '+'$'+st.price.toLocaleString()+' from banked Credits.'+((G.pedCarry||0)>0?(' The '+'$'+(G.pedCarry||0).toLocaleString()+' on you is not banked until you walk out.'):'')); return; }
'@ @'
  // v22.56 (R18): a caps headline and a short detail, not a sentence of up to 110 characters. It still says the money is banked
  // money, and names the stall money on him that is not banked yet (v12.74).
  if((P.credits||0)<st.price){ say('NOT ENOUGH BANKED CREDITS','info',{sub:'Costs '+'$'+st.price.toLocaleString()+'.'+((G.pedCarry||0)>0?(' '+'$'+(G.pedCarry||0).toLocaleString()+' carried is not banked.'):'')}); return; }
'@

SubRx @'
    G.bag.push(st.k); autoBelt(st.k);
'@ @'
    G.bag.push(st.k); autoBelt(st.k,1);   // v22.56 (R18): quietly; the row below says the slot it took
'@

SubRx @'
  say('Bought '+ITEMS[st.k].name+' for '+'$'+st.price.toLocaleString()+'. '+
      (_pAmmo?((ITEMS[st.k].amt||0)+' rounds into your reserve.')
             :(_bk?('On your tactical belt, key '+_bk+'.'):'In your backpack.')));   // v12.60: say where the rounds actually went
'@ @'
  // v22.56 (R18): the purchase is two rows in the pickup stack, the item tagged where it went (SLOT 6, BACKPACK, or the rounds
  // it put in the reserve, v12.60) and a dim -$ row for the price, instead of a sentence in the middle of the screen.
  say(ITEMS[st.k].name,'pick',{item:st.k,tag:_pAmmo?('+'+(ITEMS[st.k].amt||0)+' ROUNDS'):(_bk?('SLOT '+_bk):'BACKPACK')});
  say('-'+'$'+st.price.toLocaleString(),'pick',{tag:'BOUGHT',c:'dim'});
'@

SubRx @'
    say('Gave '+(ITEMS[go.k]?ITEMS[go.k].name:go.k)+' to '+nm+'.'); return 'gave';
'@ @'
    if(G&&!G.hubFloor&&ITEMS[go.k]) say(ITEMS[go.k].name,'pick',{item:go.k,tag:'GIVEN TO '+String(nm).toUpperCase()});   // v22.56 (R18): a row in the pickup stack
    else say('Gave '+(ITEMS[go.k]?ITEMS[go.k].name:go.k)+' to '+nm+'.');
    return 'gave';
'@

SubRx @'
    say('Took '+it.name+' from '+nm+'.');   // v22.54 (R17): where it went is the tag on its pickup row
'@ @'
    if(G&&!G.hubFloor) pickTag(key,'FROM '+String(nm).toUpperCase());   // v22.56 (R18): its pickup row says who it came from
    else say('Took '+it.name+' from '+nm+'.');
'@

SubRx @'
  var _tail=' He pays you $'+pay.toLocaleString()+(G.strayGave?' and presses a '+ITEMS[gift].name+' into your hands.':'.');
  var c=strayReveal();
  if(c){
    c.revealed=1;
    say('He marks a cache on your map.'+_tail);
    label(e.x,e.y-20,'CACHE MARKED','#e6b4ff',0,true);
  } else {
    say('He has nothing left to tell you, so he gives you what he has.'+_tail);
  }
'@ @'
  // v22.56 (R18): what he pays and what he hands over are rows in the pickup stack tagged FROM THE SURVIVOR, and the cache he
  // marks is one objective line, CACHE MARKED, instead of a sentence of up to 110 characters.
  if(G.strayGave) pickTag(gift,'FROM THE SURVIVOR');
  say('+'+'$'+pay.toLocaleString(),'pick',{tag:'FROM THE SURVIVOR',c:'gain'});
  var c=strayReveal();
  if(c){
    c.revealed=1;
    say('CACHE MARKED','obj');
    label(e.x,e.y-20,'CACHE MARKED','#e6b4ff',0,true);
  }
'@

SubRx @'
var VER='22.55';
'@ @'
var VER='22.56';
'@

$pat = "(?m)^  now:'v22\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.56: Buying, selling, the Survivor pay and gifts show as rows in the pickup stack, with plus and minus money rows. Check 22.56 fails on v22.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
