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

# THE SHOP RE-ROLLS EACH RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function renderShop(){
'@ @'
// v26.xx (career6), HIS YES (2026-10-14) to suggestion 35, THE SHOP STOCK THAT RE-ROLLS EACH RAID: "shop stock re-rolls each raid", not by the clock. The counter always has the basics
// (Bandage, Medkit, Ammo Box, Armor Plate, the Scav Pistol and the Compact SMG, the floor you can always buy back to); of the four extras (Smoke Canister, Decoy Beacon, Frag Charge,
// Stim Injector) two are on the counter at a time, and WHICH two is rolled again every time a raid is finished (the run count, P.runs, is the roll number). The roll is a side stream
// (sideStream, SHOP_TAG, the way the run goals are drawn), so it touches no seeded stream and the same roll number always gives the same two. An extra that is out shows greyed in the
// grid with SOLD OUT where its price was, its row says Sold out and cannot be bought, and the ascent check does not offer it. Prices do not change; nothing is cheaper or dearer.
var SHOP_TAG=67, SHOP_PICK=2, SHOP_CORE={bandage:1,medkit:1,ammobox:1,plate:1,pistol:1,smg:1}, SHOP_MEMO={n:-1,set:null};
function shopRollNo(){ return (P&&((+P.runs)|0))|0; }
function shopStockSet(){
  var n=shopRollNo(), pool=[], out={}, i, j, t;
  if(SHOP_MEMO.set&&SHOP_MEMO.n===n) return SHOP_MEMO.set;
  for(i=0;i<SHOP.length;i++) if(SHOP[i]&&!SHOP_CORE[SHOP[i].k]&&SHOP[i].kind!=='pack') pool.push(SHOP[i].k);
  sideStream((Math.imul(n+1,2654435761)>>>0)||1,SHOP_TAG,function(){
    for(i=pool.length-1;i>0;i--){ j=Math.floor(rr()*(i+1)); t=pool[i]; pool[i]=pool[j]; pool[j]=t; }
  });
  for(i=0;i<pool.length&&i<SHOP_PICK;i++) out[pool[i]]=1;
  SHOP_MEMO.n=n; SHOP_MEMO.set=out;
  return out;
}
function shopStocked(o){ return !o||!!SHOP_CORE[o.k]||o.kind==='pack'||!!shopStockSet()[o.k]; }
careerStyle('careercss6','.vcell.sold{opacity:.5}.vcell.sold .vp{color:var(--danger);letter-spacing:.1em}');
function renderShop(){
'@

SubRx @'
    var sic=o.kind==='wep'?o.k:(o.kind==='pack'?'pack':o.k);
'@ @'
    if(!owned&&!shopStocked(o)){ b.textContent='Sold out'; b.disabled=true; b.onclick=null; }   // v26.xx (career6): an extra that is out this raid
    var sic=o.kind==='wep'?o.k:(o.kind==='pack'?'pack':o.k);
'@

SubRx @'
cell.className='vcell'+(i===P._shopSel?' on':'')+(locked?' locked':'')+((o.price>(P.credits||0))?' poor':'');
'@ @'
cell.className='vcell'+(i===P._shopSel?' on':'')+(locked?' locked':'')+((o.price>(P.credits||0))?' poor':'')+(shopStocked(o)?'':' sold');   // v26.xx (career6)
'@

SubRx @'
'<span class="vp">'+o.price.toLocaleString()+'</span>'+
'@ @'
'<span class="vp">'+(shopStocked(o)?o.price.toLocaleString():'SOLD OUT')+'</span>'+
'@

SubRx @'
    if((P.xp||0)<o.rep) return;
    // label and ownership follow the trader
'@ @'
    if((P.xp||0)<o.rep) return;
    if(!shopStocked(o)) return;   // v26.xx (career6): and what is out this raid is not offered here either
    // label and ownership follow the trader
'@

SubRx @'
var VER='27.02';
'@ @'
var VER='27.03';
'@

$pat = "(?m)^  now:'v27\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.03: The shop stock re-rolls after every raid: two of four extras are on the counter. Check 27.03 fails on v27.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
